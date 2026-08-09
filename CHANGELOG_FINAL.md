# Changelog final

## Titanium Browser Personal — Chromium 151.0.7922.71

- Build source reproductible épinglé au commit Vanadium
  `13c840a88df07096553710c9459b3e2ecd278235`.
- Workflow GitHub-hosted ARM64 uniquement, sans runner auto-hébergé, ARM32 ni AAB.
- Compilation Chromium reprenable entre jobs pour respecter la limite de six heures.
- Package personnel `com.trigg4i.titanium.personal` et nom affiché
  `Titanium Browser Personal`.
- Patches Titanium d'extensions, popups, épinglage, Manifest V2, SAF et navigation privée conservés.
- Validation finale automatisée de l'APK, de l'ABI, de l'alignement et de la signature.
- Signature personnelle persistante fournie exclusivement via les secrets Actions.
- Diagnostics de chaque segment et ZIP de secours produits par le workflow.
- Installation réelle automatisée sur Android 16, lancement, navigation HTTPS,
  rotation et relance validés sans exception fatale détectée.
- Libellé Android final vérifié par `aapt2` : `Titanium Browser Personal`.
