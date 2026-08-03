# Instructions maîtresses pour ChatGPT Work

> Projet : navigateur Chromium Android personnel avec extensions Chrome et expérience desktop renforcée
>
> Dépôt : `TRIGG4i/android-titanium-browser`
>
> Téléphone cible : Samsung Galaxy S22 SCG13, Android 16, ARM64
>
> Livrable obligatoire : APK final ARM64 réellement construit, signé, vérifié et installable

---

## 0. Autorité de ce document

Ce fichier est la source de vérité principale pour ChatGPT Work sur ce projet.

Il remplace, pour l’exécution par Work, les anciens fichiers destinés à Codex. Les fichiers `CODEX_MASTER_INSTRUCTIONS.md`, `CODEX_PROMPT.md`, `CODEX_USAGE.md` et `README_CODEX.md` peuvent être consultés comme historique, mais ils ne doivent pas limiter ni interrompre l’exécution demandée ici.

Work doit lire intégralement ce document avant toute action, puis exécuter `WORK_FINAL_APK_PROMPT.md` sans s’arrêter à un plan, un audit, une maquette, une liste de tâches ou une simple proposition de code.

L’utilisateur donne à Work l’autorisation de :

- auditer tous les fichiers, branches, commits, sous-modules, scripts et workflows du dépôt ;
- rechercher la documentation technique actuelle nécessaire ;
- modifier tous les fichiers utiles ;
- créer, renommer ou supprimer des fichiers devenus inutiles ;
- créer une branche de travail, des commits et une pull request si l’outil l’exige ;
- adapter profondément les scripts de compilation et les patches Chromium ;
- lancer les builds et les tests disponibles ;
- télécharger les artefacts produits ;
- corriger les erreurs de manière autonome ;
- recommencer les builds autant que nécessaire dans les limites disponibles ;
- produire directement la version finale de l’APK.

Ne demander une validation intermédiaire que si une décision impossible à déduire empêche réellement la construction d’un APK. Dans tous les autres cas, choisir l’option la plus robuste, expliquer brièvement l’hypothèse dans le rapport et continuer.

---

## 1. État réel du dépôt au début de la mission

### 1.1 Ce que Codex a réellement fait

Au moment de la rédaction de ce document, Codex n’a produit aucune modification fonctionnelle du navigateur.

État constaté :

- la branche principale est `main` ;
- les derniers commits de `main` ajoutent uniquement des documents destinés à Codex ;
- aucune pull request n’existe ;
- aucune branche de développement fonctionnelle issue de Codex n’existe ;
- la branche `codex/project-brief` ne contient que des documents dupliqués et des fichiers temporaires, sans code navigateur utile ;
- aucun APK personnalisé final n’a été produit par Codex ;
- aucun build témoin personnalisé n’a été validé.

Work doit donc reprendre le projet à partir de la base technique existante de Titanium Browser, et non à partir d’un travail de développement supposément accompli par Codex.

### 1.2 Workflow actuel

Le fichier `.github/workflows/build.yml` est encore proche de l’amont et présente notamment les caractéristiques suivantes :

- `self-hosted` est la valeur par défaut du runner ;
- un déclenchement planifié existe ;
- le workflow met à jour le sous-module Vanadium et peut pousser automatiquement un commit ;
- il compile un APK ARM32, un APK ARM64 et un AAB ;
- il publie une release ;
- il attend les secrets `LOCAL_TEST_JKS` et `STORE_TEST_JKS` ;
- il dispose de permissions d’écriture étendues.

Ce workflow n’est pas encore adapté au besoin actuel.

### 1.3 Script de build actuel

Le script `build.sh` :

- télécharge Chromium à la version indiquée par Vanadium ;
- récupère `depot_tools` ;
- applique les patches Vanadium ;
- applique ensuite `patch.sh` et les ressources Titanium ;
- compile d’abord ARM32, puis ARM64 ;
- compile aussi un AAB ;
- signe les sorties avec les données décodées par `common.sh`.

Pour la version personnelle demandée, la cible prioritaire et obligatoire est uniquement `arm64-v8a` au format APK.

### 1.4 Base fonctionnelle existante à préserver

Le dépôt contient déjà une base précieuse. Elle comprend ou tente déjà de fournir :

- Chromium comme moteur complet, et non Android WebView ;
- les patches de sécurité Vanadium ;
- la prise en charge d’extensions Chromium sur Android ;
- `chrome://extensions` ;
- l’installation depuis le Chrome Web Store en mode desktop ;
- le chargement d’une extension décompressée via le sélecteur Android ;
- des correctifs Manifest V2 ;
- des correctifs pour les popups d’extensions ;
- un conteneur d’extensions dans la barre d’outils ;
- la saisie clavier dans les popups ;
- l’utilisation en navigation privée ;
- plusieurs corrections Android et Chromium ;
- des fonctions développeur expérimentales déjà activées dans `patch.sh`.

Work doit comprendre et conserver ces mécanismes. Il ne faut pas les remplacer par une WebView ou par un navigateur simplifié.

### 1.5 Identité actuelle

Le fichier `args.gn` utilise encore notamment :

- `chrome_public_manifest_package = "io.github.jqssun.helium"` ;
- `is_desktop_android = true` ;
- une cible initiale ARM ;
- un build officiel ;
- les codecs propriétaires Chromium ;
- des valeurs fictives pour les clés Google.

Work doit auditer toutes les conséquences d’un éventuel changement d’identifiant avant de modifier le package.

### 1.6 Visibilité du dépôt

L’intention de l’utilisateur est que le dépôt soit privé et réservé à son usage personnel. Au dernier audit, le dépôt était encore public.

Si Work dispose réellement d’une action sûre pour modifier la visibilité, il doit passer le dépôt en privé avant de déposer des éléments personnels. Si l’action n’est pas disponible, ne pas bloquer le développement : signaler clairement à la fin que la visibilité doit être changée manuellement.

Aucun secret, keystore ou mot de passe ne doit jamais être ajouté au dépôt, qu’il soit public ou privé.

---

## 2. Mission finale

Transformer le dépôt actuel en une application Android personnelle, stable et directement installable, reposant sur Chromium complet et offrant :

1. la meilleure prise en charge réaliste des extensions Chrome sur Android ;
2. une expérience desktop renforcée et configurable ;
3. une interface minimaliste, moderne et premium ;
4. une utilisation confortable en portrait, paysage, tablette et Samsung DeX ;
5. un espace de travail optimisé pour ChatGPT Work, Codex Web, GitHub, Zoom Marketplace et les tableaux de bord desktop ;
6. toutes les options utiles pouvant être intégrées sans compromettre la stabilité, la sécurité ou la maintenabilité ;
7. un APK final ARM64 réellement construit et vérifié.

La priorité absolue est un binaire fonctionnel. Une fonction réellement testée vaut mieux qu’une longue liste d’options théoriques non compilées.

---

## 3. Définition stricte de « terminé »

Le projet n’est pas terminé tant que Work n’a pas produit un livrable binaire.

### 3.1 Livrable principal obligatoire

Produire l’un des fichiers suivants :

- `Titanium-Browser-Personal-final-arm64-v8a.apk` ;
- ou un nom final cohérent choisi par Work après audit.

L’APK doit être :

- destiné à ARM64 ;
- signé ;
- installable sur Android 16 ;
- vérifié avec `apksigner verify` ;
- accompagné de son SHA-256 ;
- construit à partir de l’état final du dépôt ;
- dépourvu de secrets intégrés ;
- dépourvu de télémétrie ajoutée par le fork personnel.

### 3.2 Fallback de transport

Si l’interface Work ne peut pas joindre directement un fichier `.apk`, fournir :

- `Titanium-Browser-Personal-final.zip` contenant l’APK ;
- le fichier `SHA256SUMS.txt` ;
- `INSTALLATION.md` ;
- `BUILD_REPORT.md` ;
- `CHANGELOG_FINAL.md` ;
- les mentions de licences utiles.

Un ZIP qui ne contient pas d’APK n’est pas un livrable acceptable.

### 3.3 Livraison GitHub complémentaire

Lorsque les autorisations le permettent, publier également le binaire comme :

- artefact GitHub Actions ;
- ou release GitHub privée ;
- ou les deux.

Ne pas committer l’APK directement dans l’historique Git, sauf impossibilité absolue de le transmettre autrement. Préférer les artefacts et les releases.

### 3.4 Preuves de validation

Le rapport final doit contenir au minimum :

- commit exact ayant produit l’APK ;
- version Chromium ;
- version Vanadium ou commit du sous-module ;
- ABI ;
- minSdk et targetSdk ;
- identifiant de package final ;
- nom et version de l’application ;
- taille de l’APK ;
- empreinte SHA-256 du fichier ;
- résultat de la vérification de signature ;
- résultat des tests automatiques exécutés ;
- fonctions réellement testées ;
- limites connues ;
- procédure d’installation.

### 3.5 Interdiction de faux succès

Ne jamais déclarer que l’APK est final si :

- aucun fichier APK n’a été construit ;
- le build a échoué ;
- l’APK n’est pas signé ;
- la signature n’a pas été vérifiée ;
- le fichier produit est vide, corrompu ou destiné à une mauvaise ABI ;
- seules des modifications de code ou une maquette ont été produites.

---

## 4. Contraintes non négociables

### 4.1 Infrastructure

- Aucun serveur IONOS.
- Aucun runner auto-hébergé.
- Aucun ordinateur personnel exigé.
- Utiliser Work, le dépôt GitHub, les runners GitHub hébergés et les ressources cloud immédiatement accessibles.
- Ne pas demander à l’utilisateur d’installer un environnement Linux lourd sur son téléphone.

### 4.2 Architecture

- Conserver Chromium complet.
- Ne pas remplacer Chromium par Android WebView.
- Ne pas créer un navigateur factice enveloppant uniquement un site.
- Ne pas tenter de réécrire Chromium ou un moteur JavaScript depuis zéro.
- Préserver la chaîne de patches Chromium, Vanadium et Titanium autant que possible.
- Préserver la possibilité de reprendre les mises à jour de sécurité de l’amont.

### 4.3 Confidentialité

- Aucun compte propriétaire ajouté.
- Aucun backend personnel.
- Aucune publicité.
- Aucune télémétrie personnalisée.
- Aucun analytics.
- Aucun SDK marketing.
- Aucun envoi de données vers un domaine créé pour ce projet.
- Aucun jeton GitHub, OpenAI ou Google inclus dans l’APK.

### 4.4 Marques et licences

- Ne pas utiliser le logo Google Chrome.
- Ne pas présenter l’application comme une version officielle de Chrome, Vanadium ou Titanium.
- Conserver les crédits et licences de Chromium, Vanadium, GrapheneOS, Titanium et des dépendances.
- Respecter la GPLv2 et les licences tierces.
- Le caractère personnel du projet n’autorise pas la suppression des mentions légales.

### 4.5 Sécurité

- Ne pas désactiver globalement la validation TLS.
- Ne pas accepter tous les certificats.
- Ne pas désactiver la sandbox Chromium.
- Ne pas désactiver les protections Android pour faciliter une option visuelle.
- Ne pas permettre silencieusement l’installation de n’importe quel CRX provenant d’un domaine arbitraire.
- Ne pas exposer un port de débogage à distance par défaut.
- Ne pas écrire de mots de passe, cookies, tokens ou contenu privé dans les logs.

### 4.6 Qualité

- Aucun écran factice.
- Aucun bouton sans action.
- Aucun réglage qui ne modifie rien.
- Aucun `TODO` critique dans la version finale.
- Aucun `|| true` masquant une erreur critique du build.
- Aucun test annoncé sans preuve d’exécution.
- Aucun contournement fragile fondé uniquement sur une chaîne User-Agent si des Client Hints doivent aussi être cohérents.

---

## 5. Méthode d’exécution de Work

Work doit fonctionner comme un responsable technique autonome chargé de livrer le produit.

### 5.1 Première passe : audit exhaustif mais rapide

Examiner au minimum :

- `README.md` ;
- `LICENSE` ;
- `.gitmodules` ;
- `args.gn` ;
- `.gclient` ;
- `build.sh` ;
- `common.sh` ;
- `patch.sh` ;
- `.github/workflows/*.yml` ;
- le sous-module `vanadium` et son commit épinglé ;
- les dossiers `res`, `titanium`, `patches` et les éventuels sous-projets ;
- les commits récents ;
- les branches ;
- les anciennes releases ;
- les éventuels artefacts Actions ;
- les fichiers Codex déjà présents.

Produire mentalement une carte des patches et des dépendances. Ne pas s’arrêter pour transmettre cette carte avant d’agir.

### 5.2 Deuxième passe : construire une base installable

Avant la refonte profonde, faire fonctionner un build ARM64 reproductible sur les ressources disponibles. Corriger la chaîne de build jusqu’à obtenir un APK installable.

### 5.3 Troisième passe : implémentation complète

Implémenter ensuite toutes les fonctions prioritaires et les options stables décrites dans ce document. Regrouper les modifications par lots logiques et testables.

### 5.4 Quatrième passe : durcissement

Effectuer :

- revue de sécurité ;
- revue des permissions ;
- revue des intents ;
- revue des installations d’extensions ;
- tests de migration ;
- tests de crash ;
- vérification de signature ;
- vérification de l’APK final.

### 5.5 Cinquième passe : livraison

Construire le binaire final, produire les rapports, joindre le fichier et donner des instructions très simples d’installation.

Work ne doit pas s’arrêter après une seule erreur. Il doit lire les logs, corriger, relancer et continuer tant qu’une voie raisonnable existe.

---

## 6. Stratégie de branche et de commits

### 6.1 Branche recommandée

Créer une branche propre depuis `main`, par exemple :

`work/final-browser`

Ne pas baser le travail sur `codex/project-brief`, car cette branche est divergente et ne contient aucun code utile.

### 6.2 Commits

Créer des commits cohérents, par exemple :

1. `build: support GitHub-hosted ARM64 builds`
2. `build: add persistent personal signing flow`
3. `extensions: stabilize install, toolbar and popup behavior`
4. `desktop: add strict desktop identities and per-site profiles`
5. `ui: apply premium mobile and DeX interface`
6. `privacy: harden permissions and remove unwanted telemetry`
7. `test: add smoke tests and APK verification`
8. `release: prepare final personal APK`

Work peut adapter le découpage. Le but est de garder des points de retour clairs.

### 6.3 Fusion

Fusionner dans `main` uniquement lorsque :

- le build final réussit ;
- l’APK est disponible ;
- les changements ont été relus ;
- aucune régression critique connue n’est laissée volontairement.

Si Work ne peut pas fusionner automatiquement, laisser une pull request prête à fusionner et livrer quand même l’APK construit depuis son commit final.

---

## 7. Chaîne de compilation à produire

### 7.1 Workflow final

Créer ou remplacer proprement un workflow, idéalement `.github/workflows/final-build.yml`, avec :

- `workflow_dispatch` ;
- éventuellement un déclenchement contrôlé sur la branche de travail pour permettre à Work de lancer le build par un push ;
- `runs-on: ubuntu-latest` ;
- aucun runner auto-hébergé ;
- `timeout-minutes` raisonnable et inférieur à la limite de la plateforme ;
- `concurrency` pour éviter deux builds lourds simultanés ;
- checkout récursif des sous-modules ;
- commit Vanadium épinglé ;
- aucune mise à jour automatique ni push du sous-module pendant le build final ;
- permissions minimales ;
- mesures de disque, RAM, CPU et durée ;
- nettoyage prudent du runner avant le checkout Chromium si nécessaire ;
- conservation des logs utiles en cas d’échec ;
- artefact final conservé quelques jours ;
- publication de release uniquement pour un build final validé.

### 7.2 Nettoyage du runner

La compilation Chromium est lourde. Work doit mesurer l’environnement réel plutôt que se fier à une estimation.

Il peut supprimer uniquement les composants préinstallés du runner qui ne sont pas nécessaires, par exemple certains SDK ou images volumineuses. Il doit :

- afficher `df -h` avant et après ;
- éviter de supprimer les outils requis par Chromium ;
- ne pas utiliser une action tierce opaque sans audit ;
- ne pas casser `git`, Python, Java, Clang, Ninja, GN ou les dépendances Android ;
- nettoyer les sorties temporaires après usage.

### 7.3 Build ARM64 uniquement

Le build final doit viser :

- `target_cpu = "arm64"` ;
- `chrome_public_apk` ;
- un seul APK ARM64 ;
- aucun APK ARM32 ;
- aucun AAB sauf si sa création n’ajoute pratiquement aucun coût et ne menace pas le build principal ;
- symboles réduits pour économiser le disque, tout en conservant suffisamment de diagnostics ;
- aucun composant inutilisé évident.

Adapter `build.sh` pour éviter de compiler d’abord ARM32.

### 7.4 Reproductibilité

- Épingler les versions utilisées.
- Enregistrer la version Chromium.
- Enregistrer le commit Vanadium.
- Enregistrer le commit du dépôt.
- Éviter un `git checkout latest tag` non déterministe dans le build final.
- Séparer explicitement une future tâche de mise à jour de la tâche de build.

### 7.5 Fallback si le build source dépasse les ressources

Ne pas abandonner immédiatement.

Ordre des solutions :

1. réduire les cibles à ARM64 APK uniquement ;
2. libérer l’espace du runner ;
3. réduire les symboles et sorties temporaires ;
4. éviter les composants Chromium non nécessaires à Android ;
5. réutiliser les mécanismes officiels de cache seulement s’ils restent dans les quotas ;
6. fractionner les préparations et conserver des artefacts raisonnables si cela est techniquement viable ;
7. utiliser une release amont Titanium récente comme base binaire uniquement si la reconstruction source reste objectivement impossible avec les ressources autorisées.

Le fallback binaire doit être transparent. Il ne faut pas prétendre avoir intégré un patch profond qui n’a pas été recompilé. Dans ce cas, privilégier un APK amont fonctionnel, correctement vérifié et éventuellement configuré, plutôt qu’un faux APK personnalisé cassé.

### 7.6 Signature personnelle

Le but est de permettre les mises à jour ultérieures sans désinstaller l’application.

Ordre de préférence :

1. utiliser un keystore personnel déjà disponible dans des secrets GitHub, si les secrets existent et sont valides ;
2. sinon générer un nouveau keystore de release dans l’environnement privé de Work ;
3. ne jamais committer le keystore ;
4. signer avec les schémas Android appropriés ;
5. vérifier la signature ;
6. livrer à l’utilisateur une sauvegarde du keystore dans un ZIP protégé, séparé du dépôt ;
7. communiquer le mot de passe uniquement dans la réponse finale privée, jamais dans GitHub ou dans les logs.

Si Work ne peut pas transporter sûrement le keystore, utiliser une signature personnelle stable dans le build et expliquer précisément la conséquence pour les futures mises à jour. Ne pas générer une clé différente à chaque tentative.

---

## 8. Identité finale recommandée

Afin de ne pas bloquer sur une question de marque, utiliser par défaut :

- nom affiché : `Titanium Browser Personal` ;
- nom court possible : `Titanium Personal` ;
- package recommandé : `com.trigg4i.titanium.personal`.

Si une modification complète du package introduit des régressions Chromium difficiles à résoudre, conserver temporairement l’identifiant actuel tout en changeant seulement le nom affiché. Dans ce cas, expliquer la limite dans le rapport.

L’écran « À propos » doit indiquer clairement :

- fork personnel non officiel ;
- basé sur Chromium, Vanadium et Titanium Browser ;
- crédits et licences ;
- version Chromium ;
- version de l’application ;
- date de build ;
- commit source.

Créer une icône originale simple et premium, sans copier Chrome. Si aucun générateur d’image n’est disponible, produire une icône vectorielle géométrique propre à partir de ressources SVG/XML créées dans le dépôt.

---

## 9. Fonctionnalités navigateur obligatoires

### 9.1 Navigation générale

Conserver ou fiabiliser :

- barre d’adresse et recherche ;
- navigation précédente et suivante ;
- rechargement et arrêt ;
- nouvel onglet ;
- onglets multiples ;
- grille d’onglets ;
- fermeture et restauration ;
- onglets privés ;
- favoris ;
- historique ;
- téléchargements ;
- partage Android ;
- recherche dans la page ;
- impression et export PDF lorsque Chromium le permet ;
- ouverture dans une autre application ;
- sélecteur de fichiers Android ;
- caméra et microphone ;
- géolocalisation avec consentement ;
- presse-papiers avec permissions adaptées ;
- restauration de session après redémarrage ;
- gestion des liens profonds et intents sans faille de sécurité.

### 9.2 Paramètres utiles

Exposer proprement les paramètres disponibles et fiables :

- moteur de recherche ;
- page d’accueil ;
- comportement au démarrage ;
- thème système, clair et sombre ;
- position de la barre en haut ou en bas si la base Chromium le permet ;
- zoom de page ;
- taille du texte ;
- blocage des popups ;
- cookies et cookies tiers ;
- JavaScript ;
- permissions par site ;
- téléchargements ;
- navigation privée ;
- DNS sécurisé si disponible ;
- politique WebRTC ;
- mots de passe et autofill compatibles Android ;
- suppression des données ;
- import et export de favoris lorsque possible ;
- paramètres développeur derrière une section avancée.

Ne pas créer de bouton cosmétique sans effet réel.

### 9.3 Interface clavier, souris et DeX

Supporter autant que possible :

- `Ctrl+L` ;
- `Ctrl+T` ;
- `Ctrl+W` ;
- `Ctrl+Shift+T` ;
- `Ctrl+Tab` ;
- `Ctrl+F` ;
- `Ctrl+D` ;
- `Ctrl+R` ;
- `Alt+Left` et `Alt+Right` ;
- clic droit ;
- survol ;
- molette ;
- glisser-déposer lorsque Chromium Android le prend en charge ;
- redimensionnement correct en fenêtre DeX ;
- barre d’onglets adaptée en grand écran si la base le permet sans réécriture fragile.

---

## 10. Extensions Chrome : priorité absolue

### 10.1 Installation

Le navigateur final doit permettre autant que possible :

- installation depuis Chrome Web Store ;
- bouton d’installation fonctionnel en mode desktop ;
- installation depuis Microsoft Edge Add-ons et Opera Add-ons uniquement lorsque les contrôles de domaine existants le permettent ;
- chargement d’une extension décompressée via Storage Access Framework ;
- gestion d’un fichier CRX lorsque le flux est sécurisé ;
- affichage clair de la demande de permissions ;
- refus propre en cas d’incompatibilité.

### 10.2 Gestion

Fiabiliser :

- `chrome://extensions` ;
- activation et désactivation ;
- suppression ;
- page de détails ;
- page d’options ;
- autorisation en navigation privée ;
- accès aux fichiers locaux lorsque demandé ;
- autorisations par site ;
- mise à jour ;
- mode développeur ;
- chargement décompressé ;
- erreurs et avertissements visibles.

### 10.3 Barre et popups

- bouton Extensions accessible ;
- extensions épinglées ;
- lancement d’une action ;
- popup visible, redimensionnée et scrollable ;
- clavier fonctionnel dans la popup ;
- fermeture correcte ;
- ouverture d’un onglet ou d’une fenêtre demandée par l’extension ;
- thème clair et sombre ;
- comportement correct avec barre d’adresse basse ;
- absence de crash si l’extension ne fournit pas d’action.

### 10.4 Manifest V3 et Manifest V2

- Manifest V3 doit être prioritaire et pleinement pris en charge selon Chromium.
- Conserver Manifest V2 uniquement dans les limites des patches existants et sans dégrader dangereusement le moteur.
- Indiquer clairement dans le rapport les limites dues à l’évolution de Chromium.

### 10.5 Compatibilité réaliste

Certaines extensions ne fonctionneront jamais totalement sur Android si elles exigent :

- Native Messaging avec un exécutable desktop ;
- un pilote système ;
- une application Windows ou macOS installée ;
- une API Google réservée à Chrome officiel ;
- des DevTools desktop non présents ;
- un système de fichiers desktop complet.

Ne pas masquer ces limites.

### 10.6 Matrice minimale de tests

Tester plusieurs catégories, en privilégiant des extensions connues et actuelles :

- bloqueur de contenu Manifest V3 ;
- gestionnaire de mots de passe ;
- scripts utilisateurs ;
- thème sombre ;
- extension avec popup ;
- extension avec page d’options ;
- extension ouvrant un nouvel onglet ;
- extension Manifest V2 si encore installable.

Pour chaque test, documenter :

- installation ;
- permissions ;
- icône ;
- popup ;
- fonction principale ;
- persistance après redémarrage ;
- navigation privée ;
- erreurs ;
- classification : pleinement fonctionnelle, limitée, installable mais inutilisable, incompatible.

---

## 11. Mode desktop renforcé

### 11.1 Principe

Le mode desktop ne doit pas se limiter à changer le texte du User-Agent.

Le profil doit agir de façon cohérente sur les signaux contrôlables :

- User-Agent ;
- User-Agent Client Hints ;
- indication mobile ;
- plateforme ;
- viewport ;
- largeur de mise en page ;
- échelle ;
- comportement des fenêtres et popups ;
- capacités de pointeur lorsqu’un matériel externe est présent ;
- persistance par domaine.

Ne pas créer de contradictions absurdes entre les signaux.

### 11.2 Profils disponibles

Créer si techniquement stable :

1. `Android normal` ;
2. `Desktop standard` ;
3. `Desktop Windows strict` ;
4. `Desktop Linux strict` ;
5. `Tablette` ;
6. `Personnalisé`.

Le profil personnalisé peut exposer :

- User-Agent ;
- plateforme ;
- largeur virtuelle ;
- zoom ;
- popups ;
- cookies tiers ;
- orientation préférée.

### 11.3 Règles par site

Permettre :

- activation par onglet ;
- mémorisation par domaine ;
- suppression d’une règle ;
- liste des domaines configurés ;
- réinitialisation ;
- priorité claire entre réglage global, règle du site et choix de l’onglet.

### 11.4 Zoom Marketplace et Zoom Workspace

Créer un profil optimisé pour :

- `zoom.us` ;
- `marketplace.zoom.us` ;
- `developers.zoom.us` ;
- les sous-domaines requis observés pendant les tests.

Objectif concret : éviter le message qui recommande de construire les applications sur desktop et rendre accessibles les outils de création lorsqu’ils sont seulement masqués par la détection mobile.

Le profil doit tester :

- identité Windows desktop cohérente ;
- mobile désactivé ;
- viewport de bureau ;
- popups autorisées ;
- cookies nécessaires ;
- upload et download ;
- caméra et microphone à la demande ;
- OAuth ;
- menus et formulaires de création.

Si Zoom bloque une fonction côté serveur indépendamment du navigateur, le documenter sans prétendre avoir contourné le serveur.

### 11.5 ChatGPT Work et Codex Web

Ajouter un profil ou raccourci « Workspace » pour les domaines OpenAI pertinents.

Le mode doit privilégier :

- affichage desktop ;
- bonne largeur de panneau ;
- zoom mémorisé ;
- cookies et sessions persistants ;
- uploads et downloads ;
- OAuth GitHub ;
- popups ;
- clavier matériel ;
- orientation paysage ;
- fonctionnement en Samsung DeX ;
- restauration de l’onglet.

Ne pas prétendre transformer Codex Web en application Codex desktop. Le but est de rendre l’expérience Web aussi complète et confortable que possible.

### 11.6 Autres profils utiles

Tester des règles pour :

- GitHub ;
- Supabase ;
- Vercel ;
- Google Cloud Console ;
- Slack API ;
- Microsoft Azure Portal ;
- outils administratifs nécessitant un grand viewport.

---

## 12. Mode application Web et espace de travail

Lorsque Chromium le permet sans fragiliser la base, ajouter :

- installation d’un site sur l’écran d’accueil ;
- ouverture standalone ;
- raccourcis préconfigurés optionnels ;
- mode plein écran ;
- persistance du profil desktop par application Web ;
- icône et nom du site ;
- restauration de session ;
- possibilité d’ouvrir temporairement la barre du navigateur.

Créer une page de nouvel onglet sobre avec des raccourcis modifiables. Ne pas imposer de services externes.

Raccourcis initiaux possibles :

- Work ;
- Codex Web ;
- GitHub ;
- Zoom Marketplace ;
- Supabase ;
- Vercel.

Ils doivent pouvoir être retirés.

---

## 13. Design final

### 13.1 Direction

Style : Soft Minimal Premium Android.

- minimaliste ;
- moderne ;
- très clair ;
- espaces généreux mais efficaces ;
- formes arrondies mesurées ;
- ombres légères ;
- animations discrètes ;
- excellente lisibilité ;
- modes clair, sombre et système ;
- adaptation edge-to-edge ;
- cohérence avec Material 3 sans apparence générique ;
- aucune surcharge décorative.

### 13.2 Interdictions visuelles

- pas de dégradés agressifs ;
- pas de glassmorphism excessif ;
- pas de neumorphisme lourd ;
- pas d’ombres massives ;
- pas de menu rempli d’options dupliquées ;
- pas de barres trop hautes ;
- pas d’icônes ambiguës sans accessibilité.

### 13.3 Barre principale

Concevoir une barre compacte contenant selon le contexte :

- retour ;
- champ adresse/recherche ;
- sécurité du site ;
- rechargement ou arrêt ;
- extensions ;
- compteur d’onglets ;
- menu.

Permettre le positionnement haut ou bas si l’architecture actuelle le supporte proprement.

### 13.4 Onglets

- grille fluide ;
- aperçu lisible ;
- fermeture rapide ;
- annulation après fermeture ;
- recherche dans les onglets ;
- onglets privés clairement distingués ;
- groupe d’onglets si la fonction Chromium est stable ;
- présentation adaptée aux grands écrans et DeX.

### 13.5 Extensions

Créer un accès simple :

- liste des extensions épinglées ;
- bouton toutes les extensions ;
- état activé ou désactivé ;
- raccourci vers la gestion ;
- popup adaptée ;
- indication d’erreur non intrusive.

### 13.6 Paramètres

Organiser les réglages en sections courtes :

- Général ;
- Apparence ;
- Desktop ;
- Profils de sites ;
- Extensions ;
- Confidentialité et sécurité ;
- Téléchargements ;
- Autorisations ;
- Accessibilité ;
- Développeur ;
- À propos et licences.

### 13.7 Accessibilité

- libellés accessibles ;
- ordre de focus cohérent ;
- tailles tactiles suffisantes ;
- contraste ;
- support du zoom texte ;
- navigation au clavier ;
- TalkBack lorsque possible ;
- aucune information transmise uniquement par couleur.

---

## 14. Confidentialité et sécurité

### 14.1 Réseau

- conserver la validation normale des certificats ;
- conserver les protections HTTPS ;
- ne pas introduire de proxy propriétaire ;
- ne pas intercepter le trafic ;
- préserver les politiques WebRTC configurables ;
- proposer DNS sécurisé seulement via les mécanismes Chromium.

### 14.2 Extensions

- afficher les permissions ;
- autoriser la révocation ;
- ne pas auto-installer une extension tierce sans consentement ;
- ne pas intégrer une liste cachée d’extensions ;
- conserver les protections contre les installations arbitraires ;
- vérifier les flux hors boutique.

### 14.3 Intents Android

- valider les schémas ;
- éviter les intents dangereux ;
- protéger les `file://` et `content://` ;
- limiter l’exposition des activités ;
- auditer les composants exportés ;
- tester les liens externes.

### 14.4 Permissions

Ne demander que les permissions requises, au moment utile. Auditer particulièrement :

- caméra ;
- microphone ;
- localisation ;
- notifications ;
- stockage ;
- téléchargements ;
- presse-papiers ;
- Bluetooth si présent ;
- installation de packages, qui ne doit pas être demandée sans nécessité.

### 14.5 Données

- pas de logs contenant des données personnelles ;
- données privées isolées ;
- effacement fonctionnel ;
- navigation privée testée ;
- absence de capture involontaire d’écran privé si une protection existe ;
- sauvegardes Android examinées et configurées consciemment.

---

## 15. Tests et validation

### 15.1 Tests de build

- compilation propre depuis un checkout neuf ;
- build ARM64 ;
- vérification des dépendances ;
- contrôle de l’espace disque ;
- absence de fichier secret ;
- vérification de l’APK avec `aapt`, `apkanalyzer` ou outils équivalents ;
- `apksigner verify --verbose --print-certs` ;
- calcul SHA-256.

### 15.2 Tests de démarrage

- installation ;
- premier lancement ;
- onboarding éventuel ;
- ouverture d’une page HTTPS ;
- navigation ;
- rotation ;
- redémarrage ;
- restauration de session ;
- absence de crash évident.

Si Work ne dispose pas d’un téléphone physique, utiliser un émulateur ARM64 ou les tests disponibles, puis indiquer clairement les tests nécessitant une validation manuelle sur le Galaxy S22.

### 15.3 Tests d’extensions

- Chrome Web Store ;
- `chrome://extensions` ;
- activation ;
- désactivation ;
- suppression ;
- popup ;
- page d’options ;
- persistance ;
- navigation privée ;
- extension décompressée ;
- erreur contrôlée d’une extension incompatible.

### 15.4 Tests desktop

- Zoom Marketplace ;
- Work ;
- Codex Web ;
- GitHub ;
- Supabase ;
- Vercel ;
- formulaires ;
- uploads ;
- downloads ;
- OAuth ;
- popups ;
- viewport ;
- règles par site.

### 15.5 Tests UI

- portrait ;
- paysage ;
- mode sombre ;
- mode clair ;
- police agrandie ;
- clavier virtuel ;
- clavier physique ;
- souris ;
- Samsung DeX ou fenêtre redimensionnable ;
- appui long et menus contextuels.

### 15.6 Tests de régression

- navigation privée ;
- téléchargements ;
- favoris ;
- historique ;
- permissions ;
- certificats ;
- liens externes ;
- lecture vidéo ;
- audio ;
- WebRTC ;
- PDF ;
- formulaires ;
- multi-onglets.

---

## 16. Documentation finale à produire

Créer dans le dépôt :

- `FINAL_BUILD_REPORT.md` ;
- `FINAL_FEATURE_MATRIX.md` ;
- `FINAL_KNOWN_LIMITATIONS.md` ;
- `INSTALLATION.md` ;
- `UPDATE_GUIDE.md` ;
- `CHANGELOG_FINAL.md` ;
- `LICENSES_AND_CREDITS.md` si la documentation actuelle n’est pas suffisante.

Le rapport doit distinguer :

- fait vérifié ;
- test automatique ;
- test manuel ;
- fonction non testée ;
- limite connue ;
- recommandation future.

Ne pas gonfler artificiellement la liste de fonctions.

---

## 17. Critères de priorité en cas de conflit

Si deux objectifs entrent en conflit, appliquer l’ordre suivant :

1. obtenir un APK installable ;
2. sécurité et intégrité du navigateur ;
3. extensions Chrome ;
4. mode desktop strict ;
5. compatibilité Work, Codex Web et Zoom ;
6. stabilité générale ;
7. téléchargements, uploads, OAuth et permissions ;
8. ergonomie téléphone, paysage et DeX ;
9. design premium ;
10. fonctions secondaires.

Ne jamais sacrifier le build et la stabilité pour une animation ou une refonte cosmétique.

---

## 18. Gestion des blocages

### 18.1 Accès Internet

Work doit utiliser son accès Internet et les sources officielles nécessaires. Si une URL précise échoue :

- essayer une autre source officielle ;
- utiliser GitHub, Chromium, GrapheneOS ou la documentation Android ;
- réessayer avec une méthode différente ;
- conserver les versions déjà épinglées si l’amont est temporairement inaccessible.

### 18.2 Limites de runner

Si le runner manque de disque ou de temps :

- mesurer ;
- optimiser ;
- relancer ;
- réduire la cible ;
- supprimer les sorties inutiles ;
- ne pas basculer vers IONOS ;
- utiliser le fallback binaire seulement après avoir démontré le blocage du build source.

### 18.3 Fonctions impossibles

Si une fonction dépend d’une API desktop absente sur Android :

- ne pas créer un faux bouton ;
- classer la fonction comme incompatible ;
- fournir la meilleure alternative intégrée ;
- continuer les autres fonctions.

### 18.4 Questions à l’utilisateur

Ne poser une question que si :

- un secret doit être fourni et aucune solution sûre autonome n’existe ;
- une autorisation explicite de compte est indispensable ;
- deux choix irréversibles ont des conséquences importantes impossibles à départager.

Le nom, les couleurs, la structure des menus ou les détails mineurs ne doivent pas interrompre la mission. Utiliser les valeurs par défaut de ce document.

---

## 19. Format de la réponse finale de Work

La réponse finale doit commencer par l’état réel :

- `APK final construit : oui/non` ;
- nom du fichier ;
- version ;
- taille ;
- SHA-256 ;
- signature vérifiée : oui/non ;
- emplacement du téléchargement ;
- commit source.

Puis fournir :

1. lien ou pièce jointe vers l’APK ;
2. lien ou pièce jointe vers le ZIP de secours ;
3. instructions d’installation très simples ;
4. résumé des fonctions ;
5. limites connues ;
6. emplacement de la sauvegarde de signature ;
7. éventuelle action manuelle restante, notamment passer le dépôt en privé.

Ne pas terminer par une promesse de construire plus tard. Le fichier binaire doit être le résultat de la mission présente.

---

## 20. Directive finale

Work ne doit pas répondre par :

- un simple plan ;
- une étude de faisabilité ;
- un cahier des charges ;
- une liste de commandes à exécuter par l’utilisateur ;
- une maquette ;
- des fichiers source non compilés uniquement ;
- un rapport affirmant que tout est prêt alors qu’aucun APK n’existe.

Work doit auditer, modifier, construire, corriger, vérifier et livrer.

Le résultat recherché est un navigateur Chromium Android personnel final, réellement installable, optimisé pour les extensions Chrome et les interfaces desktop, accompagné d’un APK ARM64 signé et d’un ZIP de secours.