#!/bin/bash

# ========================================================================================
# Auteur: Jonmar Corpuz
# ----------------------------------------------------------------------------------------
# Objectif(s):
#   * Extraire une copie du fichier de configuration d'un appareil vers une machine client
#
# ----------------------------------------------------------------------------------------
# Version: 1 
# Dernièrement modifié le: 24 mai 2024
#
# ========================================================================================

# ================ ÉTAPE 1: DÉCLARER LES OPTIONS ET LES VARIABLES ========================

# Définir les options pour ce script
while getopts ":f:" opt; do
    case $opt in
        f) file="$OPTARG"
        ;;
        \?) echo -e "${ROUGE}Usage: ./projet_final_pt1.sh -f <fichier_texte>${BLANC}" && exit 1
        ;;
        :) echo -e "${ROUGE}ERREUR: L'option -$OPTARG nécéssite un argument.${BLANC}" && exit 1
        ;;
    esac
done

# Déclarer les variables que ce script va utiliser
ADRESSE_IPV4="^((25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.){3}(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)$"
TEMPS_EXACT=$(date '+%Y-%m-%d_%H:%M:%S')
BLANC="\033[0m"
ROUGE="\033[0;31m"
JAUNE="\033[1;33m"
VERT="\033[0;32m"

# ======================= ÉTAPE 2: VÉRIFICATIONS GÉNÉRALES ===============================

if [ $OPTIND -eq 1 ]; then
    echo -e "${ROUGE}Usage: ./projet_final_pt1.sh -f <fichier_texte>${BLANC}" && exit 1
fi

# Vérifier que l'utilisateur a bien fourni un fichier text
if [ ! -s "$file" ]; then
    echo -e "${ROUGE}ERREUR: Le fichier texte fourni est vide.${BLANC}" && exit 1
fi

# Vérifier si SSHpass est installé sur la machine
if man sshpass &> /dev/null; then
    echo -e "${VERT}SSHpass est déjà installé.${BLANC}"
else
    echo -e "${JAUNE}Installation de SSHpass.${BLANC}"
    sudo apt -y install sshpass &> /dev/null
fi

# Vérifier si Expect est installé sur la machine
if man expect &> /dev/null; then
    echo -e "${VERT}Expect est déjà installé.${BLANC}"
else
    echo -e "${JAUNE}Installation d'Expect.${BLANC}"
    sudo apt -y install expect &> /dev/null
fi

# ========== ÉTAPE 3: COPIER LE FICHIER DE CONFIGURATION DE CHAQUE APPAREIL ==============

# Faire une copie du fichier de configuration de chaque appareil dans le fichier texte 
while read -r ip_address username password ; do
    
    # Vérifier que l'adresse IP dans le fichier text fourni est véritablement une adresse IPv4
    if [[ $ip_address =~ $ADRESSE_IPV4 ]] && [[ ${#ip_address} -le 15 ]]; then
        echo ""
    else
        echo -e "${ROUGE}ERREUR: L'adresse fournie n'est pas une adresse IPv4 valide${BLANC}" && exit 1
    fi 

    # S'assurer qu'on peut se connecter avec l'appareil Cisco par SSH
    sshpass -p "$password" ssh -o "KexAlgorithms=diffie-hellman-group-exchange-sha1,diffie-hellman-group1-sha1,diffie-hellman-group14-sha1" -o "Ciphers=aes128-ctr,aes192-ctr,aes256-ctr,aes128-cbc,3des-cbc" -o "StrictHostKeyChecking=No" -T $username@$ip_address << EOF
     exit
EOF
    
    if [ $? -eq 0 ]; then    
        echo -e "${VERT}Une connexion SSH a été bien établie avec $ip_address.${BLANC}" && echo ""
    else
        echo -e "${ROUGE}ERREUR: Votre machine n'a pas pu se connecter avec $ip_address par SSH.${BLANC}" && exit 1
    fi
    
    echo -e "${JAUNE}ATTENTION: Veuillez laisser le script s'exécuter tout seul!${BLANC}"
    
    # Éxécuter le script Expect qui va aller chercher le fichier de configuration de l'appareil Cisco
    expect ./ExpectScript.sh "$ip_address" "$username" "$password" 
    
    # Renommer la copie
    copie="${ip_address}_${TEMPS_EXACT}.bak"
    mv backup-config $copie

done < $file

echo -e "${VERT}Le script a fini d'exécuter avec success${BLANC}!" && echo "Now exiting..."
exit 0
