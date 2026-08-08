# Rapport de build final

## Statut

Ce document appartient au commit source de la construction. Les champs de
preuve ci-dessous doivent être remplacés par les résultats exacts du workflow
GitHub Actions avant la livraison finale.

- APK final construit : en cours
- APK : `Titanium-Browser-Personal-final-arm64-v8a.apk`
- Version Chromium : `151.0.7922.71`
- Commit Vanadium : `13c840a88df07096553710c9459b3e2ecd278235`
- ABI attendue : `arm64-v8a` uniquement
- Package attendu : `com.trigg4i.titanium.personal`
- Cible GN : `chrome_public_apk`
- Runner : GitHub-hosted `ubuntu-24.04`
- Commit source, taille, SHA-256, minSdk, targetSdk et certificat : en attente du build validé

## Méthode de construction

Le workflow reconstruit Chromium depuis le tag épinglé, applique les patches
Vanadium puis Titanium, et compile seulement `chrome_public_apk` pour ARM64.
Comme un build propre dépasse la limite de six heures d'un job hébergé GitHub,
la sortie GN/Ninja est arrêtée proprement avant cette limite, mise en cache avec
une clé dérivée des entrées de build, puis reprise par le job hébergé suivant.

Une étape finale distincte signe l'APK avec la clé personnelle persistante
stockée dans les secrets Actions, vérifie ZIP/APK, l'alignement, l'ABI, les
métadonnées `aapt2`, la signature `apksigner` et calcule le SHA-256.

## Portée des validations

- Vérifications statiques du dépôt : effectuées.
- Compilation source ARM64 : en cours.
- Signature et `apksigner verify --verbose --print-certs` : en attente.
- Installation automatisée : en attente.
- Tests manuels sur Samsung Galaxy S22 SCG13 : requis après livraison, selon la checklist de `FINAL_FEATURE_MATRIX.md`.

Ce rapport ne doit pas être interprété comme une preuve de succès avant que les
champs ci-dessus et les artefacts de validation aient été remplis.
