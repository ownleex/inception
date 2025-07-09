#!/bin/bash

# Script pour consolider le contenu de tous les fichiers dans master_code.txt
# Auteur: Script généré pour le projet Inception
# Date: $(date)

# Nom du fichier de sortie
OUTPUT_FILE="master_code.txt"

# Couleurs pour l'affichage
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${BLUE}=== Script de consolidation de code ===${NC}"
echo -e "${YELLOW}Début de la consolidation...${NC}"

# Supprimer le fichier de sortie s'il existe déjà
if [ -f "$OUTPUT_FILE" ]; then
    rm "$OUTPUT_FILE"
    echo -e "${YELLOW}Ancien fichier $OUTPUT_FILE supprimé${NC}"
fi

# Créer l'en-tête du fichier master
{
    echo "======================================================"
    echo "           CONSOLIDATION DE TOUS LES FICHIERS"
    echo "======================================================"
    echo "Généré le: $(date)"
    echo "Répertoire: $(pwd)"
    echo "======================================================"
    echo ""
} >> "$OUTPUT_FILE"

# Compteurs
file_count=0
total_lines=0

# Obtenir le nom du script actuel
SCRIPT_NAME=$(basename "$0")

# Fonction pour traiter un fichier
process_file() {
    local file_path="$1"
    local relative_path="${file_path#./}"
    local filename=$(basename "$file_path")
    
    # Ignorer le script lui-même
    if [ "$filename" = "$SCRIPT_NAME" ]; then
        echo -e "${YELLOW}Ignoré (script lui-même): $relative_path${NC}"
        return
    fi
    
    # Ignorer certains types de fichiers
    case "$file_path" in
        *.git*|*.DS_Store|*master_code.txt|*.log|*.tmp|*.swp|*.swo)
            return
            ;;
        */node_modules/*|*/vendor/*|*/.env*)
            return
            ;;
    esac
    
    # Vérifier si c'est un fichier texte
    if file "$file_path" | grep -q "text\|empty"; then
        echo -e "${GREEN}Traitement: $relative_path${NC}"
        
        # Ajouter l'en-tête du fichier
        {
            echo ""
            echo "======================================================"
            echo "FICHIER: $relative_path"
            echo "======================================================"
            echo ""
        } >> "$OUTPUT_FILE"
        
        # Ajouter le contenu du fichier
        if [ -s "$file_path" ]; then
            cat "$file_path" >> "$OUTPUT_FILE"
            lines=$(wc -l < "$file_path")
            total_lines=$((total_lines + lines))
        else
            echo "[FICHIER VIDE]" >> "$OUTPUT_FILE"
        fi
        
        # Ajouter un séparateur
        {
            echo ""
            echo "======================================================"
            echo ""
        } >> "$OUTPUT_FILE"
        
        file_count=$((file_count + 1))
    else
        echo -e "${YELLOW}Ignoré (fichier binaire): $relative_path${NC}"
    fi
}

# Parcourir récursivement tous les fichiers
echo -e "${BLUE}Parcours des fichiers...${NC}"

# Utiliser find pour parcourir récursivement
while IFS= read -r -d '' file; do
    process_file "$file"
done < <(find . -type f -print0 2>/dev/null)

# Ajouter un résumé à la fin
{
    echo ""
    echo "======================================================"
    echo "                    RÉSUMÉ"
    echo "======================================================"
    echo "Nombre de fichiers traités: $file_count"
    echo "Nombre total de lignes: $total_lines"
    echo "Date de génération: $(date)"
    echo "======================================================"
} >> "$OUTPUT_FILE"

# Affichage final
echo ""
echo -e "${GREEN}=== Consolidation terminée ===${NC}"
echo -e "${GREEN}Fichiers traités: $file_count${NC}"
echo -e "${GREEN}Lignes totales: $total_lines${NC}"
echo -e "${GREEN}Fichier de sortie: $OUTPUT_FILE${NC}"

# Afficher la taille du fichier généré
if [ -f "$OUTPUT_FILE" ]; then
    file_size=$(du -h "$OUTPUT_FILE" | cut -f1)
    echo -e "${GREEN}Taille du fichier: $file_size${NC}"
fi

echo -e "${BLUE}=== Script terminé ===${NC}"