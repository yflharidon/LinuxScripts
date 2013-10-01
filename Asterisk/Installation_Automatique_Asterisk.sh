#!/bin/bash
#Installation automatique d'Asterisk 1.8 ou 11 avec DAHDI et googleTTS
#Yves-François L'HARIDON
#yves-francois.lharidon.com
#Version 1.0

#=============================================================================
# Liste des packages à installer: A adapter a vos besoins !
LISTE=" build-essential linux-headers-`uname -r` libxml2-dev libncurses5-dev  
libsqlite3-dev libssl-dev perl libwww-perl sox mpg123 "
#=============================================================================

# Test que le script est lance en root
if [ $EUID -ne 0 ]; then
  echo "Le script doit être lancé en root: # sudo $0" 1>&2
  exit 1
fi

# Update & Upgrade
echo -e "\033[34m========================================================================================================\033[0m"
echo -e "Mise à jour de la liste des dépôts et Mise à jour du système"
echo -e "\033[34m========================================================================================================\033[0m"
apt-get update && apt-get -y upgrade

clear
# Installation des packages
echo -e "\033[34m========================================================================================================\033[0m"
echo -e "Installation des packages suivants : $LISTE"
echo -e "\033[34m========================================================================================================\033[0m"
apt-get -y install $LISTE

# DAHDI
echo -e "\033[34m========================================================================================================\033[0m"
echo -e "Voulez-vous installer DAHDI (Y/n):"
echo -e "\033[34m========================================================================================================\033[0m"
read InstallDAHDI
: ${InstallDAHDI:="Y"}

if [[ ${InstallDAHDI} == [Yy] ]]; then
	mkdir /usr/src/asterisk
	cd /usr/src/asterisk
	wget http://downloads.asterisk.org/pub/telephony/dahdi-linux-complete/dahdi-linux-complete-current.tar.gz
	tar xvzf dahdi-linux-complete-current.tar.gz
	cd dahdi-linux-complete*
	make all
	make install
	make config
	/etc/init.d/dahdi start	
fi
######

# Installation d Asterisk
echo -e "\033[34m========================================================================================================\033[0m"
echo -e "Voulez-vous installer quelle version d'Asterisk ? "
echo -e "1 - Version 1.8"
echo -e "2 - Version 11"
echo -e "\033[34m========================================================================================================\033[0m"
read InstallAsterisk
: ${InstallAsterisk:="1"}

if [[ ${InstallAsterisk} == [1] ]]; then
	echo -e "\033[34m========================================================================================================\033[0m"
	echo -e "Installation d'Asterisk 1.8"
	echo -e "\033[34m========================================================================================================\033[0m"
	sleep 1
	cd /usr/src/asterisk
	wget http://downloads.asterisk.org/pub/telephony/asterisk/asterisk-1.8-current.tar.gz
	tar xvzf asterisk-1.8-current.tar.gz
	cd asterisk-1.8*
	./configure
	make menuselect.makeopts
	menuselect/menuselect --enable app_meetme --enable CORE-SOUNDS-FR-ULAW --enable MOH-OPSOUND-ULAW --enable EXTRA-SOUNDS-FR-ULAW menuselect.makeopts
	make
	make install
	make samples
	make config
	/etc/init.d/asterisk start
	
fi

if [[ ${InstallAsterisk} == [2] ]]; then
	echo -e "\033[34m========================================================================================================\033[0m"
	echo -e "Installation d'Asterisk"
	echo -e "\033[34m========================================================================================================\033[0m"
	
	sleep 1
	cd /usr/src/asterisk
	wget http://downloads.asterisk.org/pub/telephony/asterisk/asterisk-11-current.tar.gz
	tar xvzf asterisk-11-current.tar.gz
	cd asterisk-11*
	./configure
	make menuselect.makeopts
	menuselect/menuselect --enable app_meetme --enable CORE-SOUNDS-FR-ULAW --enable MOH-OPSOUND-ULAW --enable EXTRA-SOUNDS-FR-ULAW menuselect.makeopts
	make
	make install
	make samples
	make config
	/etc/init.d/asterisk start
	
fi
######


# Google TTS
echo -e "\033[34m========================================================================================================\033[0m"
echo -e "Voulez-vous installer Google TTS (Y/n):"
echo -e "\033[34m========================================================================================================\033[0m"
read InstallGTTS
: ${InstallGTTS:="Y"}

if [[ ${InstallGTTS} == [Yy] ]]; then
	cd /var/lib/asterisk/agi-bin
	wget https://raw.github.com/zaf/asterisk-googletts/master/googletts.agi
	chmod +x googletts.agi
fi
######

# Fin d installation
echo -e "\033[34m========================================================================================================\033[0m"
echo -e "Lancement d'Asterisk"
echo -e "\033[34m========================================================================================================\033[0m"
sleep 2
asterisk -cvvvvvvvvvvr
######
 
exit