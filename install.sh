#!/bin/bash

# ============================================================================
# DBBackup CLI - Script d'installation
# ============================================================================

set -euo pipefail

# Configuration
INSTALL_DIR="/usr/local/lib/dbbackup-cli"
BIN_LINK="/usr/bin/dbbackup"
# Note: Remplacer par l'URL réelle du dépôt si nécessaire
RAW_URL="https://raw.githubusercontent.com/kaelianbaudelet/dbbackup-cli/main"

# Couleurs
RED='\033[0;31m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
NC='\033[0m'

echo -e "${BLUE}=== Installation de DBBackup CLI ===${NC}"

# Vérification des privilèges root
if [[ $EUID -ne 0 ]]; then
   echo -e "${RED}Erreur : Ce script doit être exécuté en tant que root (utilisez sudo).${NC}" 
   exit 1
fi

# Déterminer si on installe depuis un répertoire local ou à distance
SOURCE_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
IS_LOCAL=false
if [[ -f "$SOURCE_DIR/dbbackup" && -d "$SOURCE_DIR/lib" ]]; then
    IS_LOCAL=true
fi

# Création des répertoires
echo -e "Création du répertoire d'installation : ${YELLOW}$INSTALL_DIR${NC}"
mkdir -p "$INSTALL_DIR/lib"
mkdir -p "$INSTALL_DIR/config"
mkdir -p "$INSTALL_DIR/logs"
mkdir -p "$INSTALL_DIR/backups"

if $IS_LOCAL; then
    echo -e "Installation depuis les fichiers locaux..."
    cp -r "$SOURCE_DIR/lib/." "$INSTALL_DIR/lib/"
    cp "$SOURCE_DIR/dbbackup" "$INSTALL_DIR/"
    # On ne remplace pas la config existante si elle est déjà là
    if [[ -d "$SOURCE_DIR/config" ]]; then
        cp -rn "$SOURCE_DIR/config/." "$INSTALL_DIR/config/" || true
    fi
else
    echo -e "Installation à distance depuis GitHub..."
    echo -e "${YELLOW}Note : Téléchargement des composants nécessaires...${NC}"
    
    # Télécharger le binaire principal
    curl -sSL "$RAW_URL/dbbackup" -o "$INSTALL_DIR/dbbackup"
    
    # Télécharger les bibliothèques
    LIBS=("config.sh" "remote.sh" "backup.sh" "encryption.sh" "transfer.sh" "schedule.sh" "restore.sh")
    for lib in "${LIBS[@]}"; do
        curl -sSL "$RAW_URL/lib/$lib" -o "$INSTALL_DIR/lib/$lib"
    done
    
    # Tentative de téléchargement de la config par défaut
    curl -sSL "$RAW_URL/config/dbbackup.conf" -o "$INSTALL_DIR/config/dbbackup.conf" || echo "Configuration par défaut non trouvée, elle sera générée au premier lancement."
fi

# Permissions
echo "Configuration des permissions..."
chmod +x "$INSTALL_DIR/dbbackup"

# Support multi-utilisateurs : on autorise l'écriture dans les dossiers de données
echo "Application des permissions multi-utilisateurs..."
chmod 777 "$INSTALL_DIR/config" "$INSTALL_DIR/logs" "$INSTALL_DIR/backups"

# Création du lien symbolique
echo -e "Création du lien dans ${YELLOW}$BIN_LINK${NC}"
ln -sf "$INSTALL_DIR/dbbackup" "$BIN_LINK"

echo -e "\n${GREEN}✔ Installation terminée avec succès !${NC}"
echo -e "Vous pouvez maintenant utiliser la commande '${BLUE}dbbackup${NC}'."
echo -e "Répertoire de configuration : ${YELLOW}$INSTALL_DIR/config${NC}"
