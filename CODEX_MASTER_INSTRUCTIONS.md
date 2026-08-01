# Instructions maîtresses pour Codex

## 1. Mission

Tu reprends le dépôt `TRIGG4i/android-titanium-browser` afin d’en faire un navigateur Chromium Android personnel, réservé à un seul utilisateur.

L’objectif prioritaire n’est pas de créer un navigateur généraliste destiné au public. Il faut produire un navigateur privé, minimaliste et premium qui donne sur Android l’expérience Web la plus proche possible d’un ordinateur de bureau, avec une prise en charge réelle des extensions Chrome.

Le téléphone cible principal est un Samsung Galaxy S22 SCG13 sous Android 16, architecture ARM64.

## 2. Résultat attendu

Le projet est réussi lorsque l’utilisateur peut installer l’APK sur son téléphone puis :

1. ouvrir le Chrome Web Store ;
2. installer, activer, désactiver et gérer des extensions ;
3. utiliser `chrome://extensions` ;
4. ouvrir correctement les fenêtres popup des extensions ;
5. épingler ou lancer facilement une extension depuis l’interface ;
6. naviguer avec un mode ordinateur réellement renforcé ;
7. utiliser les interfaces Web qui réservent certaines fonctions aux ordinateurs, notamment Zoom App Marketplace et Zoom Workspace ;
8. utiliser correctement GitHub, Supabase, Vercel, Google Cloud Console et d’autres tableaux de bord complexes ;
9. profiter d’une interface claire, moderne, peu chargée et agréable en portrait, paysage, avec clavier, souris et Samsung DeX.

Ne promets jamais une compatibilité absolue avec toutes les extensions ou tous les sites. Mesure la compatibilité réelle par des tests.

## 3. Contraintes non négociables

- Aucun serveur personnel, runner auto-hébergé ou infrastructure IONOS.
- Utiliser uniquement le dépôt GitHub, GitHub Actions hébergé et les ressources disponibles immédiatement.
- Le projet est destiné à un usage strictement personnel.
- Ne pas ajouter de télémétrie propriétaire, publicité, compte utilisateur, abonnement, paiement, backend, synchronisation cloud ou analytics.
- Ne jamais inclure de clé privée, keystore, mot de passe, jeton ou secret dans le dépôt ou les journaux GitHub Actions.
- Préserver les licences, copyrights et crédits de Chromium, Vanadium, GrapheneOS et Titanium.
- Ne pas utiliser le nom, le logo ou les éléments de marque de Google Chrome.
- Ne pas réécrire un moteur de navigateur depuis zéro.
- Ne pas remplacer Chromium par Android WebView.
- Ne pas supprimer les mécanismes d’extensions existants tant qu’ils n’ont pas été compris et testés.
- Ne pas effectuer une refonte visuelle massive avant d’obtenir un build témoin installable.
- Ne pas casser la possibilité de récupérer les mises à jour de sécurité de Chromium, Vanadium ou Titanium.

## 4. Base technique actuelle

Le dépôt est un fork de Titanium Browser for Android. Il utilise notamment :

- Chromium comme moteur ;
- Vanadium comme sous-module et source de correctifs de sécurité ;
- des scripts qui téléchargent Chromium puis appliquent les patches ;
- des correctifs Android spécifiques aux extensions ;
- la prise en charge de `chrome://extensions` ;
- l’installation depuis le Chrome Web Store en mode ordinateur ;
- le chargement d’extensions décompressées ;
- des adaptations pour les popups, la barre d’outils et Manifest V2.

Commence par auditer le dépôt réel. Ne te fie pas uniquement à ce document. Vérifie les scripts, patches, sous-modules, workflows, licences, fichiers de configuration et commits récents.

## 5. Stratégie obligatoire

Travaille en plusieurs phases courtes, testables et réversibles. Chaque phase doit produire un commit clair, un rapport synthétique et, quand cela est pertinent, un APK ARM64.

Avant toute modification importante :

1. inspecte l’état du dépôt ;
2. établis les faits, inconnues et risques ;
3. repère les dépendances entre Chromium, Vanadium et les patches Titanium ;
4. vérifie les limites du runner GitHub hébergé ;
5. choisis l’approche la moins fragile ;
6. conserve un historique propre permettant de revenir en arrière.

Tu peux modifier profondément le dépôt si nécessaire, mais uniquement après avoir sécurisé un build de référence et compris la chaîne de patchs.

## 6. Phase 0 : sécuriser un build témoin

### 6.1 Objectif

Produire un APK ARM64 installable sans serveur auto-hébergé et sans modifier encore l’identité ou l’interface du navigateur.

### 6.2 GitHub Actions

Adapte le workflow pour fonctionner sur un runner GitHub hébergé standard.

Exigences initiales :

- `runs-on: ubuntu-latest` ;
- déclenchement manuel avec `workflow_dispatch` ;
- désactiver temporairement le déclenchement planifié afin de ne pas consommer inutilement les minutes du dépôt privé ;
- ne pas mettre à jour ni pousser automatiquement le sous-module Vanadium pendant un build normal ;
- utiliser un commit Vanadium épinglé afin que le build soit reproductible ;
- limiter les permissions du workflow au strict nécessaire ;
- utiliser une règle `concurrency` qui annule l’ancien build manuel si un nouveau démarre ;
- fixer un délai maximal inférieur à la limite du runner GitHub ;
- conserver les artefacts peu de jours afin d’économiser le quota de stockage ;
- ne pas utiliser de cache géant incompatible avec le quota du compte ;
- nettoyer prudemment les logiciels préinstallés inutiles du runner si l’espace disque est insuffisant ;
- afficher avant et après les étapes lourdes l’espace disque, la RAM et la durée écoulée ;
- ne jamais masquer une erreur de build par `|| true` sur une étape critique.

### 6.3 Réduction du build initial

Le premier build doit viser uniquement :

- `arm64-v8a` ;
- un APK, sans AAB ;
- le navigateur principal, sans variantes inutiles ;
- aucun APK `armeabi-v7a`.

Adapte proprement les scripts pour permettre ensuite d’ajouter d’autres cibles, mais ne compile pas ce dont le Galaxy S22 n’a pas besoin.

### 6.4 Signature

Pour le build témoin, utilise une solution de signature de développement installable et documentée. Ensuite, prépare un workflow compatible avec un keystore persistant fourni exclusivement par les GitHub Actions Secrets.

Ne génère pas à chaque build une nouvelle clé aléatoire destinée aux APK de long terme, car cela empêcherait les mises à jour par-dessus l’application déjà installée.

Ne commit jamais le keystore.

### 6.5 Critères de validation

Le build témoin est validé uniquement si :

- le workflow termine réellement avec succès ;
- l’APK ARM64 est récupérable comme artefact ;
- l’APK s’installe sur le Galaxy S22 ;
- le navigateur démarre sans crash ;
- une page Web normale s’ouvre ;
- `chrome://extensions` s’ouvre ;
- une extension simple peut être installée et lancée.

Si le runner standard ne dispose pas d’assez de disque, de RAM ou de temps, ne prétends pas que le build est possible. Fournis les mesures exactes et cherche d’abord des optimisations compatibles avec GitHub Actions standard : réduction des cibles, suppression sûre des paquets préinstallés, build incrémental au sein d’un même job, diminution des symboles, artefacts minimaux et suppression des sorties temporaires. N’introduis aucun serveur externe.

## 7. Phase 1 : fiabiliser les extensions

### 7.1 Fonctions prioritaires

- installation depuis le Chrome Web Store ;
- installation depuis un dossier décompressé via Storage Access Framework ;
- prise en charge correcte de Manifest V3 ;
- conservation de Manifest V2 lorsque les patches actuels le permettent ;
- page de gestion des extensions adaptée au téléphone ;
- activation, désactivation et suppression ;
- détails et autorisations ;
- autorisation en navigation privée ;
- épinglage d’extensions ;
- lancement d’une popup depuis la barre ;
- dimensions de popup adaptées à un écran mobile ;
- clavier fonctionnel dans les popups ;
- ouverture des onglets et fenêtres demandés par les extensions ;
- persistance correcte après fermeture et redémarrage du navigateur ;
- journal de diagnostic exploitable lorsqu’une extension échoue.

### 7.2 Matrice de tests

Teste au minimum plusieurs catégories distinctes :

- bloqueur de contenu compatible avec la version de Chromium ;
- gestionnaire de mots de passe ;
- extension de scripts utilisateurs ;
- extension de productivité légère ;
- extension avec popup ;
- extension qui ouvre une page d’options ;
- extension Manifest V3 ;
- extension Manifest V2 si prise en charge.

Pour chaque extension, consigne : installation, icône, popup, permissions, persistance, fonctionnement principal, erreurs et limites.

N’utilise pas les extensions comme prétexte pour diminuer la sécurité générale du navigateur. Toute exception d’installation hors boutique doit être limitée, visible et justifiée.

## 8. Phase 2 : mode ordinateur renforcé

Le mode ordinateur doit agir de manière cohérente sur plusieurs signaux. Changer seulement le texte du User-Agent est insuffisant.

### 8.1 Fonctions

- mode ordinateur par onglet ;
- possibilité de mémoriser le choix par domaine ;
- mode ordinateur renforcé pour certains domaines ;
- User-Agent desktop cohérent ;
- Client Hints cohérents avec le profil choisi ;
- indication mobile désactivée quand le mode renforcé est actif ;
- plateforme annoncée de manière cohérente ;
- viewport virtuel configurable ;
- échelle de page réglable ;
- comportement correct des popups et fenêtres secondaires ;
- menus contextuels adaptés ;
- support du survol, de la souris, du clic droit et du clavier physique lorsque le matériel est présent ;
- téléversement de fichiers, téléchargement, caméra, microphone, presse-papiers et sélecteurs de fichiers fonctionnels ;
- profils par site faciles à réinitialiser.

Évite les incohérences absurdes entre User-Agent, Client Hints, APIs disponibles et dimensions. Le but est la compatibilité, pas une collection de faux signaux contradictoires.

### 8.2 Profil Zoom

Crée un profil expérimental pour :

- `zoom.us` ;
- `marketplace.zoom.us` ;
- `developers.zoom.us` ;
- les domaines liés nécessaires après observation du trafic réel.

Le profil doit tester au minimum :

- plateforme Windows ou Linux desktop cohérente ;
- mobile désactivé ;
- viewport équivalent à un écran de bureau ;
- fenêtres et popups autorisées ;
- cookies nécessaires ;
- caméra et microphone à la demande ;
- téléchargements et téléversements ;
- fonctionnement des pages de création et de gestion d’applications.

Le critère concret est que la section de construction d’applications Zoom ne soit plus désactivée uniquement parce que le navigateur est détecté comme mobile. Si Zoom applique un blocage côté serveur fondé sur d’autres éléments, documente-le honnêtement.

## 9. Phase 3 : interface minimaliste et premium

La refonte ne commence qu’après validation des fonctions principales.

### 9.1 Direction visuelle

Style cible : Soft Minimal Premium Android.

- interface moderne, claire et très peu chargée ;
- Material 3 personnalisé, sans rendu Android générique ;
- grands espaces utiles ;
- cartes et menus arrondis avec modération ;
- ombres légères ;
- animations fluides mais discrètes ;
- excellente lisibilité ;
- modes clair et sombre ;
- adaptation portrait, paysage, tablette et Samsung DeX ;
- commandes faciles à atteindre sur téléphone ;
- pas de dégradés criards, glassmorphism excessif, grosses ombres ou décor superflu.

### 9.2 Interface recommandée

Barre principale compacte :

- retour ;
- adresse et recherche ;
- rechargement contextuel ;
- accès aux extensions ;
- compteur d’onglets ;
- menu.

Gestion des onglets :

- grille rapide ;
- recherche ;
- fermeture simple ;
- restauration de session ;
- interface desktop en paysage ou DeX si possible sans fragiliser Chromium.

Espace extensions :

- extensions installées ;
- état actif ou inactif ;
- bouton de lancement ;
- épinglage ;
- permissions ;
- accès au Web Store ;
- installation manuelle ;
- diagnostic succinct.

Paramètres :

- mode ordinateur ;
- profils de sites ;
- largeur virtuelle et zoom ;
- extensions ;
- confidentialité ;
- téléchargements ;
- autorisations ;
- apparence ;
- informations et licences.

Ne crée pas une couche Compose séparée au-dessus du navigateur si elle duplique ou fragilise l’architecture Chromium. Modifie les composants natifs existants de manière maintenable.

## 10. Identité de l’application

Ne renomme pas immédiatement le package, les namespaces et toutes les ressources avant le build témoin.

Après validation fonctionnelle :

1. propose quelques noms courts et juridiquement prudents ;
2. attends le choix du propriétaire avant le renommage final ;
3. crée ensuite une identité originale ;
4. conserve dans l’application une page claire de crédits et licences ;
5. ne prétends pas que le navigateur est Google Chrome, Titanium officiel ou Vanadium officiel.

## 11. Sécurité et confidentialité

- HTTPS et certificats : conserver les protections Chromium.
- Safe Browsing et fonctions comparables : ne pas désactiver sans raison démontrée.
- Extensions : limiter les installations hors boutique aux flux explicitement validés.
- Navigation privée : tester l’isolation réelle.
- Permissions : demander au moment utile et permettre la révocation.
- Journaux : ne pas enregistrer de mots de passe, cookies, jetons ou contenu privé.
- Téléchargements : vérifier le nom, le type MIME et l’emplacement.
- Liens externes et intents : conserver les protections contre les schémas dangereux.
- Ne pas contourner les protections Android pour obtenir un simple effet visuel.

## 12. Compatibilité réaliste

Classe chaque extension testée dans une des catégories suivantes :

- pleinement fonctionnelle ;
- fonctionnelle avec limites ;
- installable mais inutilisable ;
- incompatible.

Certaines extensions desktop peuvent dépendre de Native Messaging, d’un exécutable Windows, d’un système de fichiers desktop, de services Google réservés à Chrome officiel ou d’APIs absentes sur Android. Ne tente pas de simuler ces dépendances sans étude sérieuse.

## 13. Méthode de travail de Codex

Tu as l’autorisation d’auditer et de modifier tout le dépôt nécessaire à l’objectif. Utilise ton autonomie, mais respecte cet ordre :

1. audit ;
2. build témoin ;
3. tests extensions ;
4. mode ordinateur renforcé ;
5. interface ;
6. identité ;
7. durcissement et documentation.

À chaque étape :

- annonce brièvement le sous-objectif ;
- inspecte les fichiers concernés ;
- explique les risques principaux ;
- modifie directement les fichiers ;
- exécute les validations disponibles ;
- examine les logs complets en cas d’échec ;
- corrige la cause racine plutôt que de masquer le symptôme ;
- committe avec un message précis ;
- mets à jour `PROJECT_STATUS.md` ;
- indique clairement ce qui est prouvé, supposé ou encore non testé.

Ne demande une intervention humaine que pour une action réellement impossible à effectuer : choix final du nom, création ou ajout d’un secret GitHub, installation et test physique sur le téléphone, ou validation d’une permission externe.

## 14. Fichiers de suivi à créer

Crée et maintiens :

- `PROJECT_STATUS.md` : état réel, dernière version testée, blocages et prochaine action ;
- `DECISIONS.md` : décisions d’architecture et raisons ;
- `TEST_MATRIX.md` : appareils, sites et extensions testés ;
- `BUILD.md` : procédure GitHub Actions et récupération de l’APK ;
- `SECURITY.md` : politique de sécurité adaptée à ce fork personnel ;
- `THIRD_PARTY_NOTICES.md` : crédits et licences, sans supprimer les fichiers d’origine.

## 15. Livrable final

Le livrable final doit comprendre :

- un dépôt propre et reproductible ;
- un workflow GitHub Actions manuel ;
- un APK ARM64 signé de manière stable ;
- une procédure simple pour déclencher le build et télécharger l’APK ;
- les extensions principales testées ;
- le mode ordinateur renforcé ;
- le profil Zoom testé ;
- une interface premium fonctionnelle ;
- la documentation des limites ;
- un plan clair pour récupérer les mises à jour de sécurité en amont.

## 16. Première instruction à exécuter maintenant

Commence immédiatement par l’audit complet de la chaîne de build et des patches. Ensuite, prépare le plus petit changement possible permettant un build manuel ARM64 sur `ubuntu-latest`, sans serveur auto-hébergé, sans build ARM32, sans AAB, sans publication automatique et sans refonte visuelle.

Ne passe à aucune autre phase avant d’avoir produit soit :

- un APK témoin réellement construit et installable ;

ou

- un rapport d’échec précis comportant les mesures de disque, RAM, temps, étape fautive, cause racine probable et meilleures solutions restant compatibles avec GitHub Actions hébergé.
