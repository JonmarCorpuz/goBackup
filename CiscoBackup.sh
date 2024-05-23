#!/bin/bash

# ========================================================================================
# Auteur: Jonmar Corpuz
# ----------------------------------------------------------------------------------------
# Objectif(s):
#   * Extraire une copie du fichier de configuration d'un appareil vers un client
# ========================================================================================

# ================ ÉTAPE 1: DÉCLARER LES OPTIONS ET LES VARIABLES ========================

# Définir les options pour ce script
while getopts ":f:" opt; do
    case $opt in
        f) file="$OPTARG"
        ;;
        \?) echo "Usage: ./projet_final_pt1.sh -f <fichier_authentification>" && exit 1
        ;;
        :) echo "Option -$OPTARG requires an argument." && exit 1
        ;;
    esac
done

# Déclarer les variables que ce script va utiliser
ipv4_address="^((25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.){3}(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)$"
temps_exact=$(date '+%Y-%m-%d_%H:%M:%S')
copie_template="${CurrentDate}_$1.tar.gz"
fichier_type=$(file -b --mime-type "$file")

# ======================= ÉTAPE 2: VÉRIFICATIONS GÉNÉRALES ===============================

# Vérifier que le fichier fourni est un fichier text
if [ "$fichier_type" != "text/plain" ]; then
    echo "ERREUR: Le fichier donné n'est pas un fichier text." && exit 1
fi

# Vérifier que l'utilisateur a bien fourni un fichier text
if [ -z "$file" ]; then
    echo "Usage: ./projet_final_pt1.sh -f <fichier_authentification>" && exit 1
fi

# Vérifier si SSHpass est installé sur la machine
if man sshpass &> /dev/null; then
    echo "SSHpass est déjà installé." && echo ""
else
    sudo apt -y install sshpass &> /dev/null
fi

# Vérifier si Expect est installé sur la machine
if man expect &> /dev/null; then
    echo "Expect est déjà installé." && echo ""
else
    sudo apt -y install expect &> /dev/null
fi

# ========== ÉTAPE 3: COPIER LE FICHIER DE CONFIGURATION DE CHAQUE APPAREIL ==============

# Faire une copie du fichier de configuration de chaque appareil dans le fichier texte 
while read -r ip_address username password ; do
    
    # Vérifier que l'adresse IP dans le fichier text fourni est véritablement une adresse IPv4
    if [[ $ip_address =~ $ipv4_address ]] && [[ ${#ip_address} -le 15 ]]; then
        echo "OK"
    else
        echo "ERREUR" && exit 1
    fi 

    # S'assurer qu'on peut se connecter avec l'appareil Cisco par SSH
    sshpass -p "$password" ssh -o "KexAlgorithms=diffie-hellman-group-exchange-sha1,diffie-hellman-group1-sha1,diffie-hellman-group14-sha1" -o "Ciphers=aes128-ctr,aes192-ctr,aes256-ctr,aes128-cbc,3des-cbc" -o "StrictHostKeyChecking=No" -T $username@$ip_address << EOF
     exit
EOF
    
    if [ $? -eq 0 ]; then    
        echo "Une connexion SSH a été bien établie avec $ip_address." && echo ""
    else
        echo "ERREUR: Votre machine n'a pas pu se connecter avec $ip_address par SSH." && exit 1
    fi
    
    # Éxécuter le script Expect qui va aller chercher le fichier de configuration de l'appareil Cisco
    expect ./ExpectScript.sh "$ip_address" "$username" "$password" 
    
    # Renommer la copie
    copie="${ip_address}_${temps_exact}.bak"
    mv backup-config $copie

done < $file
