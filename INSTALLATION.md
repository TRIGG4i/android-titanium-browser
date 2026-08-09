# Installation

## Installation directe

1. Télécharger `Titanium-Browser-Personal-final-arm64-v8a.apk` sur le Samsung Galaxy S22.
2. Ouvrir le fichier depuis **Mes fichiers** ou le navigateur.
3. Si Android le demande, autoriser temporairement cette source à installer des applications.
4. Confirmer l'installation, puis ouvrir **Titanium Browser Personal**.
5. Retirer l'autorisation d'installation à la source si elle n'est plus nécessaire.

Le package est `com.trigg4i.titanium.personal`, la version est
`151.0.7922.71` et l'APK est exclusivement ARM64 (`arm64-v8a`). Une version signée avec
une autre clé ou utilisant un autre package ne peut pas être installée comme une
mise à jour par-dessus celle-ci.

## Installation avec ADB

```shell
adb install Titanium-Browser-Personal-final-arm64-v8a.apk
```

Pour une future mise à jour signée avec la même clé :

```shell
adb install -r Titanium-Browser-Personal-final-arm64-v8a.apk
```

Vérifier le SHA-256 avec `SHA256SUMS.txt` avant l'installation. La valeur
attendue pour cette version est :

```text
755eb2d2523de833122ab6da8b5bb28d870b33e19a29591c47ec0c3ffa29913a
```
