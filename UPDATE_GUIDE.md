# Guide de mise à jour

1. Mettre à jour explicitement le commit Vanadium et la version Chromium.
2. Rejouer les patches sur un checkout propre et corriger tout conflit sans masquer d'erreur.
3. Construire uniquement l'APK ARM64 avec le workflow final hébergé GitHub.
4. Réutiliser impérativement la même sauvegarde de keystore et le même alias.
5. Vérifier ABI, package, version, alignement, signature et SHA-256.
6. Installer avec `adb install -r` sur un appareil de test avant diffusion.
7. Mettre à jour les rapports et la matrice avec les seuls tests réellement exécutés.

Perdre la clé personnelle empêche de publier une mise à jour installable par-dessus
la version existante. Le keystore et son mot de passe ne doivent jamais être
committés, copiés dans un ticket ou imprimés dans des logs.
