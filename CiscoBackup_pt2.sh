#!/usr/bin/expect -f

# 
set ip_address [lindex $argv 0]
set username [lindex $argv 1]
set password [lindex $argv 2]

# Établir une connexion SSH avec l'appareil Cisco
spawn ssh $username@$ip_address -o "KexAlgorithms=diffie-hellman-group-exchange-sha1,diffie-hellman-group1-sha1,diffie-hellman-group14-sha1" -o "Ciphers=aes128-ctr,aes192-ctr,aes256-ctr,aes128-cbc,3des-cbc" -o "StrictHostKeyChecking=No"

# 
expect "assword:" 
send "$password\r"

#
expect "#" 
send "copy running-config flash:backup-config\r"

#
expect "Destination filename \[backup-config\]?"
send "\r"
expect "Do you want to over write \[confirm\]"
send "\r"

#
expect "bytes copied in" 
send "exit\r"

#
expect eof

# Copier la copie du fichier de configuration de l'appareil avec SCP
spawn scp -o "KexAlgorithms=diffie-hellman-group-exchange-sha1,diffie-hellman-group1-sha1,diffie-hellman-group14-sha1" -o "Ciphers=aes128-ctr,aes192-ctr,aes256-ctr,aes128-cbc,3des-cbc" -o "StrictHostKeyChecking=No" $username@$ip_address:flash:/backup-config .

#
expect "assword:" 
send "$password\r"

#
expect eof
