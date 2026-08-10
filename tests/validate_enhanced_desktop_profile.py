#!/usr/bin/env python3
"""Runtime validation of Titanium's enhanced desktop profile via ADB + CDP."""

from __future__ import annotations

import argparse
import json
import re
import subprocess
import time
import urllib.request
import xml.etree.ElementTree as ET
from pathlib import Path
from typing import Any

import websocket


ZOOM_URL = "https://marketplace.zoom.us/"
PERSISTENCE_URL = "https://example.com/"
ZOOM_MOBILE_MESSAGE = (
    "We recommend building apps on desktop, as we are still implementing the mobile experience."
)


def adb(*args: str, timeout: int = 60) -> str:
    result = subprocess.run(
        ["adb", *args],
        check=True,
        text=True,
        stdout=subprocess.PIPE,
        stderr=subprocess.STDOUT,
        timeout=timeout,
    )
    return result.stdout.strip()


def wait_for_debug_endpoint(timeout: int = 90) -> list[dict[str, Any]]:
    deadline = time.monotonic() + timeout
    last_error = ""
    while time.monotonic() < deadline:
        try:
            with urllib.request.urlopen(
                "http://127.0.0.1:9222/json/list", timeout=3
            ) as response:
                targets = json.load(response)
            if any(target.get("type") == "page" for target in targets):
                return targets
        except Exception as exc:  # endpoint is absent while Chrome starts
            last_error = str(exc)
        time.sleep(1)
    raise RuntimeError(f"Chrome DevTools endpoint did not appear: {last_error}")


class Cdp:
    def __init__(self) -> None:
        targets = wait_for_debug_endpoint()
        target = next(item for item in targets if item.get("type") == "page")
        self.ws = websocket.create_connection(
            target["webSocketDebuggerUrl"],
            timeout=10,
            origin="http://localhost:9222",
        )
        self.next_id = 1
        self.events: list[dict[str, Any]] = []

    def close(self) -> None:
        self.ws.close()

    def call(self, method: str, params: dict[str, Any] | None = None) -> dict[str, Any]:
        call_id = self.next_id
        self.next_id += 1
        self.ws.send(json.dumps({"id": call_id, "method": method, "params": params or {}}))
        while True:
            payload = json.loads(self.ws.recv())
            if payload.get("id") == call_id:
                if "error" in payload:
                    raise RuntimeError(f"CDP {method} failed: {payload['error']}")
                return payload.get("result", {})
            self.events.append(payload)

    def drain_until(self, event_method: str, timeout: int = 45) -> None:
        deadline = time.monotonic() + timeout
        while time.monotonic() < deadline:
            self.ws.settimeout(max(0.2, deadline - time.monotonic()))
            try:
                payload = json.loads(self.ws.recv())
            except websocket.WebSocketTimeoutException:
                continue
            self.events.append(payload)
            if payload.get("method") == event_method:
                return
        raise RuntimeError(f"Timed out waiting for CDP event {event_method}")

    def navigate(self, url: str) -> None:
        self.call("Network.enable", {"maxTotalBufferSize": 10_000_000})
        self.call("Page.enable")
        self.events.clear()
        self.call("Page.navigate", {"url": url})
        self.drain_until("Page.loadEventFired", timeout=90)
        time.sleep(3)
        self.ws.settimeout(0.2)
        while True:
            try:
                self.events.append(json.loads(self.ws.recv()))
            except websocket.WebSocketTimeoutException:
                break

    def evaluate(self, expression: str) -> Any:
        result = self.call(
            "Runtime.evaluate",
            {
                "expression": expression,
                "awaitPromise": True,
                "returnByValue": True,
            },
        )
        remote = result["result"]
        if remote.get("subtype") == "error":
            raise RuntimeError(remote.get("description", "JavaScript evaluation failed"))
        return remote.get("value")


PROFILE_EXPRESSION = r"""
(() => {
  const uaData = navigator.userAgentData;
  const highEntropy = uaData
    ? uaData.getHighEntropyValues([
        'architecture', 'bitness', 'formFactors', 'fullVersionList',
        'model', 'platformVersion', 'wow64'
      ])
    : Promise.resolve({});
  return highEntropy.then(high => ({
    url: location.href,
    userAgent: navigator.userAgent,
    uaDataMobile: uaData ? uaData.mobile : null,
    uaDataPlatform: uaData ? uaData.platform : null,
    uaDataHighEntropy: high,
    navigatorPlatform: navigator.platform,
    innerWidth: window.innerWidth,
    clientWidth: document.documentElement.clientWidth,
    devicePixelRatio: window.devicePixelRatio,
    screenWidth: screen.width,
    screenHeight: screen.height,
    narrowMobileLayout: matchMedia('(max-width: 768px)').matches,
    orientationType: screen.orientation ? screen.orientation.type : null,
    orientationAngle: screen.orientation ? screen.orientation.angle : null,
    title: document.title,
    bodyTextLength: document.body ? document.body.innerText.length : 0,
    mobileBlockingMessageVisible:
      document.body ? document.body.innerText.includes(%s) : false
  }));
})()
""" % json.dumps(ZOOM_MOBILE_MESSAGE)


def assert_enhanced(profile: dict[str, Any], context: str) -> None:
    ua = profile["userAgent"]
    assert "Windows NT 10.0; Win64; x64" in ua, (context, profile)
    assert "Mobile" not in ua and "Android" not in ua, (context, profile)
    assert profile["uaDataMobile"] is False, (context, profile)
    assert profile["uaDataPlatform"] == "Windows", (context, profile)
    assert profile["navigatorPlatform"] == "Win32", (context, profile)
    assert min(profile["innerWidth"], profile["clientWidth"]) >= 1280, (context, profile)
    assert profile["narrowMobileLayout"] is False, (context, profile)
    form_factors = profile["uaDataHighEntropy"].get("formFactors")
    if form_factors is not None:
        assert "Desktop" in form_factors and "Mobile" not in form_factors, (context, profile)


def ui_xml() -> ET.Element:
    adb("shell", "uiautomator", "dump", "/sdcard/titanium-window.xml", timeout=30)
    xml = adb("exec-out", "cat", "/sdcard/titanium-window.xml", timeout=30)
    return ET.fromstring(xml[xml.index("<?xml") :])


def bounds_center(bounds: str) -> tuple[int, int]:
    match = re.fullmatch(r"\[(\d+),(\d+)\]\[(\d+),(\d+)\]", bounds)
    if not match:
        raise RuntimeError(f"Invalid UI bounds: {bounds}")
    left, top, right, bottom = map(int, match.groups())
    return (left + right) // 2, (top + bottom) // 2


def tap_matching(predicate, description: str) -> None:
    root = ui_xml()
    for node in root.iter("node"):
        if predicate(node.attrib):
            x, y = bounds_center(node.attrib["bounds"])
            adb("shell", "input", "tap", str(x), str(y))
            return
    visible = [
        (node.attrib.get("text"), node.attrib.get("content-desc"), node.attrib.get("resource-id"))
        for node in root.iter("node")
        if node.attrib.get("text") or node.attrib.get("content-desc")
    ]
    raise RuntimeError(f"Could not find {description}; visible nodes: {visible}")


def enable_enhanced_from_menu() -> None:
    tap_matching(
        lambda attrs: "menu_button" in attrs.get("resource-id", "")
        or "more options" in attrs.get("content-desc", "").lower(),
        "Titanium app-menu button",
    )
    time.sleep(1)
    tap_matching(
        lambda attrs: attrs.get("text", "").strip() == "Enhanced desktop"
        or "turn on enhanced desktop" in attrs.get("content-desc", "").lower(),
        "Enhanced desktop menu item",
    )
    time.sleep(8)


def request_headers(cdp: Cdp, host: str) -> dict[str, str]:
    request_ids: set[str] = set()
    merged: dict[str, str] = {}
    for event in cdp.events:
        if event.get("method") != "Network.requestWillBeSent":
            continue
        params = event["params"]
        request = params["request"]
        if host in request.get("url", "") and params.get("type") == "Document":
            request_ids.add(params["requestId"])
            merged.update({key.lower(): str(value) for key, value in request["headers"].items()})
    for event in cdp.events:
        if event.get("method") != "Network.requestWillBeSentExtraInfo":
            continue
        params = event["params"]
        if params.get("requestId") in request_ids:
            merged.update({key.lower(): str(value) for key, value in params["headers"].items()})
    return merged


def document_response(cdp: Cdp, host: str) -> dict[str, Any]:
    responses = []
    for event in cdp.events:
        if event.get("method") != "Network.responseReceived":
            continue
        params = event["params"]
        response = params["response"]
        if host in response.get("url", "") and params.get("type") == "Document":
            responses.append(
                {
                    "url": response["url"],
                    "status": response["status"],
                    "mimeType": response.get("mimeType"),
                }
            )
    if not responses:
        raise AssertionError(f"No document response captured for {host}")
    return responses[-1]


def launch(package: str, url: str) -> None:
    adb("shell", "am", "force-stop", package)
    adb(
        "shell",
        "am",
        "start",
        "-W",
        "-a",
        "android.intent.action.VIEW",
        "-d",
        url,
        "-p",
        package,
        timeout=90,
    )
    wait_for_debug_endpoint()


def main() -> None:
    parser = argparse.ArgumentParser()
    parser.add_argument("--package", default="com.trigg4i.titanium.personal")
    parser.add_argument("--output", type=Path, required=True)
    args = parser.parse_args()

    adb(
        "shell",
        "sh",
        "-c",
        "printf '%s\\n' 'chrome --disable-fre --no-first-run "
        "--remote-debugging-port=9222 --remote-allow-origins=*' "
        "> /data/local/tmp/chrome-command-line",
    )
    adb("forward", "--remove", "tcp:9222") if "tcp:9222" in adb("forward", "--list") else None
    adb("forward", "tcp:9222", "localabstract:chrome_devtools_remote")

    results: dict[str, Any] = {}
    launch(args.package, PERSISTENCE_URL)
    cdp = Cdp()
    cdp.navigate(PERSISTENCE_URL)
    results["before_manual_enable"] = cdp.evaluate(PROFILE_EXPRESSION)
    cdp.close()

    enable_enhanced_from_menu()
    cdp = Cdp()
    results["manual_enable"] = cdp.evaluate(PROFILE_EXPRESSION)
    assert_enhanced(results["manual_enable"], "manual enable")
    cdp.close()

    launch(args.package, PERSISTENCE_URL)
    cdp = Cdp()
    cdp.navigate(PERSISTENCE_URL)
    results["after_restart"] = cdp.evaluate(PROFILE_EXPRESSION)
    assert_enhanced(results["after_restart"], "persistence after restart")

    adb("shell", "settings", "put", "system", "accelerometer_rotation", "0")
    adb("shell", "settings", "put", "system", "user_rotation", "1")
    time.sleep(5)
    results["landscape"] = cdp.evaluate(PROFILE_EXPRESSION)
    assert_enhanced(results["landscape"], "landscape")
    assert "landscape" in results["landscape"]["orientationType"], results["landscape"]

    adb("shell", "settings", "put", "system", "user_rotation", "0")
    time.sleep(5)
    results["portrait"] = cdp.evaluate(PROFILE_EXPRESSION)
    assert_enhanced(results["portrait"], "portrait")
    assert "portrait" in results["portrait"]["orientationType"], results["portrait"]

    adb("shell", "input", "keyevent", "KEYCODE_TAB")
    adb("shell", "input", "keyevent", "KEYCODE_DPAD_DOWN")
    results["input_smoke_process"] = adb("shell", "pidof", args.package)

    cdp.navigate(ZOOM_URL)
    results["zoom"] = cdp.evaluate(PROFILE_EXPRESSION)
    assert_enhanced(results["zoom"], "Zoom Marketplace automatic rule")
    headers = request_headers(cdp, "marketplace.zoom.us")
    results["zoom_request_headers"] = headers
    response = document_response(cdp, "marketplace.zoom.us")
    results["zoom_document_response"] = response
    assert "Windows NT 10.0; Win64; x64" in headers.get("user-agent", ""), headers
    assert headers.get("sec-ch-ua-mobile") == "?0", headers
    assert headers.get("sec-ch-ua-platform") == '"Windows"', headers
    assert 200 <= response["status"] < 400, response
    assert results["zoom"]["url"].startswith("https://marketplace.zoom.us/"), results["zoom"]
    assert results["zoom"]["title"].strip(), results["zoom"]
    assert results["zoom"]["bodyTextLength"] > 100, results["zoom"]
    assert results["zoom"]["mobileBlockingMessageVisible"] is False, results["zoom"]
    cdp.close()

    args.output.parent.mkdir(parents=True, exist_ok=True)
    args.output.write_text(json.dumps(results, indent=2, sort_keys=True) + "\n", encoding="utf-8")
    print(json.dumps(results, indent=2, sort_keys=True))


if __name__ == "__main__":
    main()
