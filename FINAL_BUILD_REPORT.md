# Rapport de build final

## Statut réel

- APK final construit : **oui**
- APK : `Titanium-Browser-Personal-final-arm64-v8a.apk`
- Taille : `324267809` octets
- SHA-256 : `755eb2d2523de833122ab6da8b5bb28d870b33e19a29591c47ec0c3ffa29913a`
- Commit source ayant produit l'APK : `b90814911309d9f5ca658a4d27c7f9e90ffab8ae`
- Run source : [GitHub Actions 31314699195](https://github.com/TRIGG4i/android-titanium-browser/actions/runs/31314699195)
- Version Chromium/application : `151.0.7922.71`
- Version code : `792207174`
- Commit Vanadium : `13c840a88df07096553710c9459b3e2ecd278235`
- Cible GN : `chrome_public_apk`
- Package : `com.trigg4i.titanium.personal`
- Nom Android : `Titanium Browser Personal`
- ABI : `arm64-v8a` uniquement
- minSdk : `29`
- targetSdk : `36`
- compileSdk : `37`
- Construction : runner GitHub hébergé `ubuntu-24.04`, sans runner auto-hébergé

## Construction source

Le workflow a récupéré Chromium `151.0.7922.71`, appliqué la série de patches
Vanadium épinglée puis les patches Titanium et personnels, généré GN pour
`target_cpu = "arm64"`, et compilé Chromium complet vers `chrome_public_apk`.
Aucun APK Chromium précompilé n'a servi au livrable final.

Le graphe Chromium dépassant six heures, la sortie `out/Default` a été reprise
entre des jobs GitHub hébergés avec une clé dérivée des entrées de build. Le run
source de référence `31271527519` a achevé le graphe en quatre segments. Le run
final `31314699195` a repris le dernier checkpoint compatible, invalidé
explicitement la ressource Android de marque, achevé le graphe puis régénéré
l'APK. L'assertion `aapt2` sur le libellé final a réussi. Le mécanisme
d'invalidation reste dans les entrées de build afin qu'une reprise du même
checkpoint ne puisse pas réintroduire l'ancien libellé.

## Signature et intégrité

La signature finale utilise la clé personnelle persistante stockée uniquement
dans les secrets Actions et dans la sauvegarde privée séparée du dépôt.

- `apksigner verify --verbose --print-certs` : succès
- Schéma APK Signature Scheme v3 : `true`
- Nombre de signataires : `1`
- Algorithme : RSA, `4096` bits
- SHA-256 du certificat : `74a5f0e71a63d20aba6995142b0e77bc7c03088c162deccf312bc22195c2c066`
- `zipalign -c -P 16 4` : succès
- Test CRC ZIP de l'APK : `4134` entrées, aucune entrée corrompue
- Test CRC du ZIP de livraison : aucune entrée corrompue
- ABI extraite : uniquement `arm64-v8a`

La somme recalculée localement est identique à `SHA256SUMS.txt` produit par le
runner.

## Installation automatisée

Le run [GitHub Actions 31321093699](https://github.com/TRIGG4i/android-titanium-browser/actions/runs/31321093699)
a testé exactement l'artefact et le SHA-256 ci-dessus sur Android 16 Google APIs
avec KVM et `libndk_translation.so` :

- `adb install --no-streaming` : `Success` ;
- package installé : `com.trigg4i.titanium.personal` ;
- `primaryCpuAbi=arm64-v8a` ;
- version installée : `151.0.7922.71` (`792207174`) ;
- lancement par l'activité `LAUNCHER` : processus actif (PID `3365`) ;
- ouverture de `https://example.com/` : `Status: ok` ;
- activité Chromium personnelle visible et reprise au premier plan ;
- rotation paysage : capture produite ;
- arrêt puis relance : nouveau processus actif (PID `5006`) ;
- aucune exception fatale de l'application détectée dans `logcat`.

Les captures montrent le navigateur Chromium complet, la navigation vers
`example.com` et l'interface en paysage. Ce test automatisé prouve
l'installabilité du paquet ARM64 ; la checklist fonctionnelle étendue reste à
exécuter sur le Samsung Galaxy S22 cible pour les extensions, DeX, caméra,
microphone et OAuth.

## Portée

Les fonctions marquées « présentes dans les sources » dans
`FINAL_FEATURE_MATRIX.md` n'ont pas été présentées comme testées lorsqu'aucun
scénario réel ne les a exécutées. Les limites restantes sont consignées dans
`FINAL_KNOWN_LIMITATIONS.md`.
