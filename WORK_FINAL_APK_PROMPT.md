# Prompt d’exécution final pour ChatGPT Work

Travaille sur le dépôt GitHub `TRIGG4i/android-titanium-browser` et livre directement la version finale installable du navigateur Android personnel décrit ci-dessous.

## Instruction préalable obligatoire

Lis intégralement `WORK_MASTER_INSTRUCTIONS.md` avant toute action. Considère ce fichier comme la source de vérité du projet. Les anciens fichiers `CODEX_*` sont uniquement historiques.

Ne réponds pas d’abord avec un plan. Ne t’arrête pas après l’audit. Ne demande pas à l’utilisateur d’exécuter les commandes à ta place. Tu as l’autorisation d’auditer et de modifier tout le dépôt, de créer une branche, des commits, des workflows, une pull request, des artefacts et une release, puis de construire et livrer le binaire final.

## Situation de départ vérifiée

Codex n’a effectué aucun développement fonctionnel sur ce dépôt :

- aucun code navigateur personnalisé n’a été ajouté par Codex ;
- aucune pull request n’existe ;
- aucune branche fonctionnelle n’existe ;
- aucun APK personnalisé final n’a été produit ;
- `main` contient seulement la base Titanium et les documents préparatoires ;
- `codex/project-brief` est une branche divergente avec des documents dupliqués et des fichiers temporaires, sans code utile ;
- le workflow actuel utilise encore `self-hosted` par défaut, contient un build planifié, met à jour Vanadium, compile ARM32 + ARM64 + AAB et attend des secrets de signature.

Pars donc de `main`, pas de `codex/project-brief`.

## Objectif final non négociable

Produis maintenant un navigateur Chromium Android personnel, stable, moderne et premium, pour un Samsung Galaxy S22 SCG13 sous Android 16 ARM64, avec comme priorités :

1. prise en charge réelle des extensions Chrome ;
2. installation depuis Chrome Web Store ;
3. gestion via `chrome://extensions` ;
4. popups d’extensions utilisables ;
5. extensions épinglées dans la barre ;
6. Manifest V3, et Manifest V2 lorsque les patches existants le permettent ;
7. chargement d’extensions décompressées ;
8. mode desktop renforcé et cohérent ;
9. profils desktop par site ;
10. profil Zoom Marketplace/Workspace ;
11. profil ChatGPT Work/Codex Web ;
12. compatibilité GitHub, Supabase, Vercel, Google Cloud Console et tableaux de bord desktop ;
13. interface Soft Minimal Premium ;
14. fonctionnement portrait, paysage, clavier, souris et Samsung DeX ;
15. sécurité, confidentialité et absence de télémétrie ajoutée.

L’application est uniquement destinée à l’usage personnel du propriétaire. Aucun backend, publicité, analytics, abonnement, compte propriétaire ou serveur IONOS ne doit être ajouté.

## Résultat obligatoire

Tu dois livrer un véritable fichier APK ARM64 signé et vérifié.

Nom recommandé :

`Titanium-Browser-Personal-final-arm64-v8a.apk`

Si tu choisis un autre nom cohérent, utilise-le partout.

Si l’interface ne peut pas joindre directement un APK, crée et joins :

`Titanium-Browser-Personal-final.zip`

Le ZIP doit obligatoirement contenir :

- l’APK final ;
- `SHA256SUMS.txt` ;
- `INSTALLATION.md` ;
- `FINAL_BUILD_REPORT.md` ;
- `CHANGELOG_FINAL.md` ;
- les informations de version et de licences.

Un ZIP sans APK est interdit.

Publie également, si les autorisations le permettent, l’APK dans une release GitHub privée ou comme artefact GitHub Actions. Ne committe pas le binaire dans Git sauf impossibilité absolue de le transmettre autrement.

## Exécution attendue

### 1. Audit immédiat

Inspecte réellement :

- dépôt et visibilité ;
- branches et commits ;
- fichiers de build ;
- workflows GitHub Actions ;
- `args.gn` ;
- `build.sh` ;
- `common.sh` ;
- `patch.sh` ;
- `.gitmodules` ;
- sous-module Vanadium ;
- ressources Titanium ;
- patches d’extensions ;
- permissions Android ;
- licences ;
- releases et artefacts existants.

Ne transmets pas seulement l’audit. Enchaîne immédiatement sur les modifications.

### 2. Branche de travail

Crée une branche propre depuis `main`, par exemple :

`work/final-browser`

Ignore la branche `codex/project-brief`.

### 3. Build ARM64 sur GitHub uniquement

Aucun serveur auto-hébergé.

Adapte la chaîne pour :

- `runs-on: ubuntu-latest` ;
- cible ARM64 uniquement ;
- APK uniquement ;
- aucun ARM32 ;
- aucun AAB si cela coûte du temps ou du disque ;
- workflow manuel ou déclenchement contrôlé par push ;
- sous-module Vanadium épinglé ;
- aucune mise à jour/push automatique de Vanadium pendant le build ;
- permissions minimales ;
- `timeout-minutes` ;
- `concurrency` ;
- mesures de disque/RAM/temps ;
- nettoyage prudent du runner ;
- logs et artefacts de diagnostic en cas d’échec ;
- artefact APK en cas de succès.

Modifie `build.sh` pour ne plus compiler ARM32 avant ARM64. Utilise directement `target_cpu = "arm64"` et construis `chrome_public_apk`.

Teste réellement le workflow. Lis les logs, corrige les erreurs et relance. Ne t’arrête pas au premier échec.

### 4. Fallback si le runner ne peut pas compiler Chromium

Tu dois d’abord démontrer le blocage avec les mesures et les logs.

Essaie dans cet ordre :

1. ARM64 APK uniquement ;
2. suppression des sorties inutiles ;
3. symboles réduits ;
4. libération sûre de l’espace du runner ;
5. réduction des composants inutiles ;
6. cache raisonnable ;
7. fractionnement techniquement sûr.

Si la compilation source reste objectivement impossible, utilise comme dernier recours la release officielle Titanium la plus récente et vérifiée pour produire un APK fonctionnel, en ne revendiquant que les modifications réellement appliquées. La priorité reste un navigateur installable avec extensions, pas une refonte fictive non compilée.

### 5. Signature finale

Utilise un keystore personnel persistant s’il existe déjà dans les secrets.

Sinon :

- génère un keystore de release personnel dans un environnement privé ;
- ne le committe jamais ;
- signe l’APK ;
- vérifie la signature avec `apksigner verify --verbose --print-certs` ;
- fournis une sauvegarde protégée du keystore séparément pour permettre les futures mises à jour ;
- ne place jamais le mot de passe dans GitHub ou dans les logs ;
- communique le mot de passe uniquement dans la réponse finale privée si nécessaire.

Ne change pas de clé entre les builds finaux.

### 6. Identité

Valeurs par défaut autorisées sans demander :

- nom affiché : `Titanium Browser Personal` ;
- package recommandé : `com.trigg4i.titanium.personal` ;
- description : fork personnel non officiel basé sur Chromium, Vanadium et Titanium Browser.

Si le changement complet de package casse des composants Chromium, conserve l’identifiant existant pour cette version finale et change seulement le nom affiché. Documente-le. La stabilité passe avant le rebranding.

Crée une icône originale premium sans reprendre le logo Chrome. Conserve les crédits et licences.

### 7. Extensions Chrome

Préserve et fiabilise les mécanismes existants, notamment les patches déjà présents dans `patch.sh`.

Valide au minimum :

- Chrome Web Store ;
- bouton d’installation ;
- dialogue de permissions ;
- `chrome://extensions` ;
- activation/désactivation ;
- suppression ;
- détails ;
- options ;
- mode développeur ;
- chargement décompressé via Storage Access Framework ;
- Manifest V3 ;
- Manifest V2 si compatible ;
- autorisation navigation privée ;
- extensions épinglées ;
- popup ;
- clavier dans popup ;
- ouverture d’onglets ;
- persistance après redémarrage ;
- erreurs contrôlées.

Teste plusieurs catégories d’extensions et consigne les résultats réels dans `FINAL_FEATURE_MATRIX.md`.

Ne désactive pas globalement la sécurité pour faire fonctionner une extension.

### 8. Desktop strict

Implémente la meilleure solution techniquement stable pour :

- User-Agent desktop ;
- Client Hints cohérents ;
- mobile désactivé ;
- plateforme cohérente ;
- viewport de bureau ;
- largeur virtuelle ;
- zoom ;
- popups ;
- règles mémorisées par domaine ;
- réglage global, par site et par onglet ;
- profils Android normal, Desktop standard, Windows strict, Linux strict, tablette et personnalisé lorsque réalisable.

Ne te contente pas du User-Agent si Chromium permet de traiter les autres signaux.

### 9. Profils spéciaux

Crée et teste des profils pour :

#### Zoom

- `zoom.us`
- `marketplace.zoom.us`
- `developers.zoom.us`

Objectif : rendre la section Build accessible lorsqu’elle est bloquée uniquement par la détection mobile. Tester formulaires, OAuth, uploads, téléchargements, popups, cookies, caméra et microphone.

#### ChatGPT Work et Codex Web

Optimiser :

- affichage desktop ;
- largeur de panneau ;
- zoom mémorisé ;
- orientation paysage ;
- uploads/downloads ;
- OAuth GitHub ;
- popups ;
- clavier/souris ;
- session persistante ;
- Samsung DeX.

Ne prétends pas émuler l’application Codex desktop. Optimise réellement l’interface Web.

#### Outils de développement

Tester :

- GitHub ;
- Supabase ;
- Vercel ;
- Google Cloud Console ;
- Slack API ;
- autres tableaux de bord complexes utiles.

### 10. Fonctions navigateur complètes

Conserve et fiabilise toutes les fonctions stables possibles :

- onglets ;
- groupes d’onglets si stable ;
- navigation privée ;
- favoris ;
- historique ;
- téléchargements ;
- partage ;
- recherche dans la page ;
- PDF ;
- impression ;
- caméra ;
- microphone ;
- géolocalisation ;
- upload ;
- presse-papiers ;
- restauration de session ;
- mots de passe et autofill Android ;
- permissions par site ;
- cookies ;
- JavaScript ;
- DNS sécurisé si disponible ;
- politique WebRTC ;
- suppression des données ;
- page d’accueil ;
- moteur de recherche ;
- thème ;
- zoom et taille de texte ;
- raccourcis clavier ;
- clic droit et souris ;
- Samsung DeX ;
- installation de sites comme applications lorsque Chromium le permet.

N’ajoute aucun bouton non fonctionnel.

### 11. Interface premium

Applique après validation des fonctions essentielles un design Soft Minimal Premium :

- minimaliste ;
- moderne ;
- clair ;
- peu chargé ;
- Material 3 personnalisé ;
- clair/sombre/système ;
- barres compactes ;
- animations discrètes ;
- excellente lisibilité ;
- portrait/paysage/DeX ;
- accès simple aux extensions ;
- onglets propres ;
- paramètres organisés ;
- accessibilité et tailles tactiles suffisantes.

Ne crée pas une nouvelle couche WebView ou Compose qui contourne Chromium. Modifie proprement l’interface native existante et ses ressources.

### 12. Sécurité et confidentialité

Vérifie :

- TLS et certificats ;
- sandbox ;
- permissions ;
- intents ;
- composants exportés ;
- navigation privée ;
- téléchargements ;
- stockage ;
- installations hors boutique ;
- absence de secret ;
- absence de télémétrie ajoutée ;
- absence de proxy ou backend ;
- absence de logs sensibles.

Préserve les licences GPLv2 et tierces.

### 13. Tests

Exécute autant de tests automatiques et instrumentés que l’environnement permet.

Valide :

- build propre ;
- ABI ARM64 ;
- signature ;
- installation sur émulateur si disponible ;
- démarrage ;
- navigation HTTPS ;
- rotation ;
- restauration ;
- extensions ;
- desktop strict ;
- téléchargements ;
- uploads ;
- OAuth ;
- popups ;
- modes clair/sombre ;
- clavier/souris ;
- absence de crash critique.

Si un test exige le Galaxy S22 physique, prépare une checklist manuelle ultra simple, mais ne bloque pas la livraison de l’APK.

### 14. Documentation finale

Crée et remplis :

- `FINAL_BUILD_REPORT.md` ;
- `FINAL_FEATURE_MATRIX.md` ;
- `FINAL_KNOWN_LIMITATIONS.md` ;
- `INSTALLATION.md` ;
- `UPDATE_GUIDE.md` ;
- `CHANGELOG_FINAL.md` ;
- `LICENSES_AND_CREDITS.md` si nécessaire.

Indique les faits vérifiés, pas des promesses.

## Critères d’acceptation du binaire

Avant de déclarer la mission terminée, vérifie obligatoirement :

- APK présent ;
- taille non nulle ;
- ABI ARM64 ;
- package connu ;
- version connue ;
- signature vérifiée ;
- SHA-256 calculé ;
- fichier téléchargeable ;
- commit source connu ;
- rapport final présent ;
- aucun secret dans le dépôt ;
- ZIP de secours contenant réellement l’APK.

## Format obligatoire de ta réponse finale

Commence par :

- `APK final construit : OUI` ou `NON` ;
- nom du fichier ;
- version ;
- taille ;
- SHA-256 ;
- signature vérifiée ;
- commit source ;
- lien/pièce jointe de téléchargement.

Puis donne :

1. le lien ou la pièce jointe APK ;
2. le ZIP de secours ;
3. les étapes d’installation ;
4. le résumé des fonctions réellement présentes ;
5. les limites réelles ;
6. la sauvegarde de signature ;
7. les rares actions manuelles restantes.

Ne réponds pas uniquement avec du code source, un plan ou une promesse. Continue jusqu’à avoir produit le binaire final ou jusqu’à avoir épuisé toutes les voies autorisées, avec preuves techniques précises du blocage. La cible normale de cette mission est `APK final construit : OUI`.