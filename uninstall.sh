#!/bin/bash

# ============================================================================
# DBBackup CLI - Script de désinstallation
# ============================================================================

set -euo pipefail

# Configuration
INSTALL_DIR="/usr/local/lib/dbbackup-cli"
BIN_LINK="/usr/bin/dbbackup"

# Couleurs
RED='\033[0;31m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
NC='\033[0m'

echo -e "${BLUE}=== Désinstallation de DBBackup CLI ===${NC}"

# Vérification des privilèges root
if [[ $EUID -ne 0 ]]; then
   echo -e "${RED}Erreur : Ce script doit être exécuté en tant que root (utilisez sudo).${NC}" 
   exit 1
fi

# Confirmation
echo -e "${YELLOW}Attention : Cela va supprimer le binaire et les fichiers de bibliothèque.${NC}"
read -p "Voulez-vous également supprimer les configurations et les sauvegardes ? (y/N) " -n 1 -r
echo
KEEP_DATA=true
if [[ $REPLY =~ ^[Yy]$ ]]; then
    KEEP_DATA=false
fi

# Suppression du lien symbolique
if [[ -L "$BIN_LINK" ]]; then
    echo "Suppression du lien symbolique $BIN_LINK..."
    rm "$BIN_LINK"
fi

# Suppression des fichiers
if [[ -d "$INSTALL_DIR" ]]; then
    if $KEEP_DATA; then
        echo "Suppression du binaire et de la bibliothèque (conservation de config/ et backups/)..."
        rm -f "$INSTALL_DIR/dbbackup"
        rm -rf "$INSTALL_DIR/lib"
    else
        echo "Suppression complète de $INSTALL_DIR..."
        rm -rf "$INSTALL_DIR"
    fi
fi

echo -e "\n${GREEN}✔ Désinstallation terminée.${NC}"
