# CiscoBackup.sh

## Auteur

* Jonmar Corpuz

## Description

Ce script sert à extraire une copie du fichier de configuration d'un switch ou routeur Cisco par SSH vers la machine Ubuntu où le script a été exécuté.

## Prérequis

* Un client Ubuntu avec SSHPass et Expect d'installés.
* Au moins un appareil Cisco avec SSH et SCP de configuré et qui possède un utilisateur avec un privilège de 15.

## Entrées nécessaires

* Un fichier texte qui contiendra l'adresse IP de l'appareil Cisco, ainsi que le username et son mot de passe que ce script va utiliser pour se connecter à l'appareil par SSH.

## Sorties produites

* Un fichier texte qui contiendra une copie du fichier de configuration de l'appareil Cisco par appareil spécifiée dans le fichier texte

## Syntax

* Voici la syntax pour bien exécuter le script: 

```bash
./projet_final_pt1.sh -f <fichier_texte>
```

* Voici la syntax pour chaque ligne dans votre fichier de texte que vous allez fournir au script:

```text
<adresse_ip> <username> <password>
[adresse_ip] [username] [password]
[...]
```

## Exemple

1. Vous allez créer un fichier de texte "DEMO.txt" qui contient les lignes suivantes concernant l'adresse IP, le nom d'utilisateur et le mot de passe de l'appareil Cisco:
```txt
10.10.1.100 bob cisco
10.10.1.200 alice cisco
```

2. Vous allez exécuter le script en fournissant le fichier de texte que vous venez de créer avec la commande suivante: 
```bash
./projet_final_pt1.sh -f DEMO.txt
```

3. Le script va vous produire une copie du fichier de configuration de chaque appareil que vous avez spécifié avec le fichier de texte. 
```bash
10.10.1.100_2024-01-01:01:01:01.bak
10.10.1.200_2024-01-01:01:02:02.bak
```
