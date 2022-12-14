#!/bin/bash -e

if [ "$UID" -ne 0 ]; then
  echo "Merci d'exécuter en root"
  exit 1
fi

# Principaux paramètres
tput setaf 7; read -p "Entrer le mot de passe root de la base de données: " ROOT_DB_PASS
tput setaf 7; read -p "Entrer le mot de passe glpi de la base de données: " GLPI_DB_PASS
tput setaf 7; read -p "Entrer l'adresse IP du serveur GLPI: " IP

tput setaf 2; echo ""

apt-get update && sudo apt-get upgrade -y


# Ajout de la variable PATH qui peux poser problème
export PATH=$PATH:/usr/local/sbin
export PATH=$PATH:/usr/sbin
export PATH=$PATH:/sbin

# Installation de Apache
apt-get install apache2 -y

# Activation de Apache2
systemctl enable apache2

# Installation de MariaDB
apt-get install mariadb-server -y

# Installationdes modules annexes
apt-get install php libapache2-mod-php -y
apt-get install php-{ldap,imap,apcu,xmlrpc,curl,common,gd,json,mbstring,mysql,xml,intl,zip,bz2} -y

# Changement du mdp de la base de données MySQL
mysql_secure_installation <<EOF
y
ROOT_DB_PASS
ROOT_DB_PASS
y
y
y
y
EOF

# Configuration de la base de données
mysql -uroot -p'$ROOT_DB_PASS' -e "drop database if exists glpidb;"
mysql -uroot -p'$ROOT_DB_PASS' -e "drop user if exists glpi@localhost;"
mysql -uroot -p'$ROOT_DB_PASS' -e "create database glpidb character set utf8 collate utf8_bin;"
mysql -uroot -p'$ROOT_DB_PASS' -e "grant all on glpidb.* to 'glpi'@'%' identified by '"$GLPI_DB_PASS"' with grant option;"
mysql -uroot -p'$ROOT_DB_PASS' -e "flush privileges;"

# Récupération de la dernière version de GLPI
cd /tmp
wget https://github.com/glpi-project/glpi/releases/download/10.0.2/glpi-10.0.2.tgz
tar -xzvf glpi-10.0.2.tgz
rm -R /var/www/html/*
cp -R glpi/* /var/www/html/
chown -R www-data:www-data /var/www/html/
chmod -R 775 /var/www/html/

systemctl restart apache2
systemctl restart mariadb




clear
echo "-------------------------------------------------"
tput bold; tput setaf 7; echo "       => Installation terminée <=       "
tput setaf 7; echo ""
tput setaf 7; echo "URL du serveur glpi: http://"$IP"/"
tput setaf 7; echo "Adresse serveur SQL: 127.0.0.1"
tput setaf 7; echo "Utilisateur de la base de données: glpi"
tput setaf 7; echo "Mot de passe de l'utilisateur SQL: $GLPI_DB_PASS"
tput setaf 7; echo "Nom de la base créée: glpidb"
tput setaf 7; echo ""


tput setaf 7; echo ""
tput setaf 7; echo ""
tput bold; tput setaf 6; echo "       By ASPARTAX42       "
tput setaf 2; echo ""
