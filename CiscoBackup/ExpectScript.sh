#!/usr/bin/expect -f

# Déclarer des variables pour l'adresse IP, le nom d'utilisateur et le mot de passe
set ip_address [lindex $argv 0]
set username [lindex $argv 1]
set password [lindex $argv 2]

# Établir une connexion SSH avec l'appareil Cisco
spawn ssh $username@$ip_address -o "KexAlgorithms=diffie-hellman-group-exchange-sha1,diffie-hellman-group1-sha1,diffie-hellman-group14-sha1" -o "Ciphers=aes128-ctr,aes192-ctr,aes256-ctr,aes128-cbc,3des-cbc" -o "StrictHostKeyChecking=No"

# Attendre l'invité du mot de passe et envoyer le mot de passe
expect "assword:" 
send "$password\r"

# Attendre l'invité du terminal de commande
expect "#" 
send "copy running-config flash:backup-config\r"

# Attendre la confirmation de l'emplacement de destination et confirmer
expect "Destination filename \[backup-config\]?"
send "\r"
expect "Do you want to over write \[confirm\]"
send "\r"

# Attendre la fin de la copie et quitter le terminal de commande
expect "bytes copied in" 
send "exit\r"

# Attendre la fin de la session SSH
expect eof

# Copier la copie du fichier de configuration de l'appareil avec SCP
spawn scp -o "KexAlgorithms=diffie-hellman-group-exchange-sha1,diffie-hellman-group1-sha1,diffie-hellman-group14-sha1" -o "Ciphers=aes128-ctr,aes192-ctr,aes256-ctr,aes128-cbc,3des-cbc" -o "StrictHostKeyChecking=No" $username@$ip_address:flash:/backup-config .

# Attendre l'invité du mot de passe pour SCP et envoyer le mot de passe
expect "assword:" 
send "$password\r"

# Attendre la fin de la session SCP
expect eof
