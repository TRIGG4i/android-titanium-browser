# Limites connues

- Les extensions exigeant Native Messaging, un exécutable desktop, un pilote
  système, des DevTools desktop complets ou des API réservées à Chrome officiel
  peuvent rester incompatibles sur Android.
- La conservation de Manifest V2 dépend de patches de compatibilité et ne
  garantit pas le fonctionnement de toutes les extensions anciennes.
- Un profil desktop ne peut pas contourner une restriction appliquée côté
  serveur par Zoom, OpenAI ou un autre service.
- Les clés Google du build sont volontairement fictives. Les services dépendant
  d'API Google propriétaires réservées à Chrome officiel peuvent être limités.
- La validation automatisée ne remplace pas les essais caméra, microphone,
  OAuth, Samsung DeX et extensions sur le Galaxy S22 cible.
- L'installation, le lancement, HTTPS, la rotation et la relance ont été testés
  sur un émulateur Android 16 x86_64 utilisant la traduction ARM64. Un essai sur
  le Galaxy S22 ARM64 physique reste recommandé avant usage quotidien.
- Le libellé Android/launcher est `Titanium Browser Personal`, mais quelques
  textes d'aide ou d'onboarding hérités peuvent encore employer le nom amont
  court `Titanium`. Cette limite est cosmétique et ne change ni le package ni la
  signature.
- L'écran « À propos », les crédits affichés dans l'application et la date de
  build n'ont pas été inspectés manuellement pendant le smoke test.
- GitHub refuse le passage direct en privé car le dépôt est un fork public.
  L'action manuelle restante est d'utiliser **Settings → General → Danger Zone
  → Leave fork network**, en acceptant la perte permanente des métadonnées du
  fork, puis de passer le dépôt autonome en privé. Aucune release publique n'a
  été créée ; l'artefact Actions validé et les fichiers locaux assurent la
  livraison entre-temps.
- Le dépôt doit rester sans keystore ni mot de passe. La sauvegarde de signature
  est livrée séparément et doit être conservée pour toutes les mises à jour.
