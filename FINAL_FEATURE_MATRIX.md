# Matrice fonctionnelle finale

Les statuts distinguent la présence vérifiée dans les sources d'un test réel du
binaire. Aucun comportement non exécuté n'est présenté comme validé.

| Domaine | État avant test APK | Preuve actuelle | Validation finale requise |
|---|---|---|---|
| Chromium complet | Présent dans la chaîne source | Cible GN `chrome_public_apk`, base Chromium 151 | Démarrage et navigation HTTPS |
| Architecture ARM64 | Configurée | `target_cpu = "arm64"` | `zipinfo` : seulement `arm64-v8a` |
| Chrome Web Store | Implémentation amont Titanium conservée | Patches et documentation Titanium | Installation réelle d'une extension MV3 |
| `chrome://extensions` | Implémentation conservée | Patches UI/extensions | Activation, détails, options et suppression |
| Extension décompressée SAF | Correctif source présent | Correctif `VirtualDocumentPath` dans `patch.sh` | Charger un dossier d'extension |
| Manifest V3 | Pris en charge par Chromium | Base Chromium | Installer et exécuter une extension MV3 |
| Manifest V2 | Compatibilité forcée dans les sources | Modifications de l'API et du gestionnaire MV2 | Installer une extension MV2 compatible |
| Popups d'extensions | Correctifs source présents | Ancrage, viewport et clavier dans `patch.sh` | Popup, saisie clavier, fermeture |
| Extensions épinglées | Correctifs source présents | Conteneur toolbar et préférence d'épinglage | Épingler, exécuter et persister |
| Extensions en navigation privée | Correctifs source présents | Process manager et fenêtre privée | Autorisation, ouverture et redémarrage |
| Installation Opera/Edge | Domaines explicitement autorisés | Liste bornée dans `patch.sh` | Installation et dialogue de permissions |
| Mode desktop | Base desktop Android activée | `is_desktop_android = true` | UA, Client Hints et viewport par site |
| Zoom Marketplace | Non validé | Aucun faux résultat annoncé | Formulaires, OAuth, popup, upload/download |
| ChatGPT/Codex Web | Non validé | Aucun faux résultat annoncé | Session, OAuth GitHub, fichiers, clavier/DeX |
| GitHub/Supabase/Vercel | Non validé | Aucun faux résultat annoncé | Navigation desktop, formulaires et OAuth |
| Navigation privée | Base Chromium + correctifs présents | Patches Titanium | Démarrage, fermeture et absence de crash |
| Téléchargements/uploads | Base Chromium | Cible navigateur complète | Fichiers réels et permissions Android |
| Caméra/micro/localisation | Base Chromium | Manifest généré par Chromium | Consentement et révocation par site |
| Clavier/souris/DeX | Base desktop Android | `is_desktop_android = true` | Checklist sur appareil/DeX |
| Nom personnel | Configuré dans les sources | Ressources `Titanium Browser Personal` | Libellé après installation |
| Package personnel | Configuré dans GN | `com.trigg4i.titanium.personal` | `aapt2 dump badging` |

## Checklist manuelle Galaxy S22

1. Installer l'APK et ouvrir une page HTTPS.
2. Tester nouvel onglet, retour, rechargement, favoris, historique et téléchargement.
3. Ouvrir `chrome://extensions`, installer une extension MV3 puis tester popup et options.
4. Charger une extension décompressée via le sélecteur Android.
5. Tester une fenêtre privée avec une extension explicitement autorisée.
6. Tester Zoom Marketplace, ChatGPT/Codex Web et GitHub en mode desktop.
7. Tester portrait, paysage, thème sombre, clavier Bluetooth, souris et Samsung DeX.
8. Redémarrer l'application et vérifier onglets, session, règles de site et extensions.
