#!/bin/bash

ADDON_DIRECTORY=/storage/.kodi/addons/script.gamestarter/
# Script for checking for updates 
kodi-send --action=Notification"(Gamestarter,Checking for updates...,4000,/storage/.kodi/addons/script.gamestarter/icon.png)"

kodi-send --action="xbmc.ActivateWindow(busydialog)"

# comprobar que changelog de internet y local son iguales
# wget --no-check-certificate -O $ADDON_DIRECTORY/changelog_latest.txt https://raw.githubusercontent.com/bite-your-idols/Gamestarter-Pi/master/script.gamestarter/changelog.txt
VERSION_LOCAL=$(head -c 6 $ADDON_DIRECTORY/changelog.txt) 
# VERSION_ONLINE=$(head -c 6 $ADDON_DIRECTORY/changelog_latest.txt) 
VERSION_ONLINE="v2.7.0"
echo $VERSION_LOCAL
echo $VERSION_ONLINE


if [[ $VERSION_LOCAL == $VERSION_ONLINE ]]
then
   # echo "Gamestarter is up to date"
   kodi-send --action=Notification"(Gamestarter,Gamestarter is up to date,6000,/storage/.kodi/addons/script.gamestarter/icon.png)"
else
	kodi-send --action=Notification"(Gamestarter,Updating...,6000,/storage/.kodi/addons/script.gamestarter/icon.png)"
	if [[ $VERSION_LOCAL == "v2.4.0" ]] 
	then
      rm -rf /storage/.config/retroarch/cores
		cp -rf /storage/.config/retroarch /storage/.kodi/userdata/addon_data/script.gamestarter
		rm -rf /storage/.config/retroarch
		cp -rf /storage/.config/emulationstation /storage/.kodi/userdata/addon_data/script.gamestarter
		rm -rf /storage/.config/emulationstation
		rm /storage/.kodi/userdata/addon_data/plugin.program.advanced.launcher/launchers.xml
		mv /storage/.config/advancedlauncher/launchers.xml /storage/.kodi/userdata/addon_data/plugin.program.advanced.launcher/launchers.xml
		rm /storage/.emulationstation
		rm -rf /storage/.config/advancedlauncher
		rm /storage/.config/gamestarter.log
	fi

   #sacar solo los valores de la version p.e. "2.3"
   #VERSION_UPDATE=$(head -c 4 $ADDON_DIRECTORY/changelog_latest.txt) 
   #VERSION_UPDATE=$(tail -c 5 $VERSION_UPDATE)
   VERSION_UPDATE=${VERSION_ONLINE:1:3}
   #sacar la veriosnd el addon OLE/LE8alpha
   ADDON_VERSION=$(head -c 8 $ADDON_DIRECTORY/resources/bin/installed)
   #asi sabemos que version del zip descargar
   echo "VERSION DEL ADDON: " $ADDON_VERSION
   echo "ACTUALIZAR A: " $VERSION_UPDATE
   wget --no-check-certificate -O /storage/gamestarter-update.zip https://github.com/bite-your-idols/Gamestarter-Pi/releases/download/$VERSION_UPDATE/script.gamestarter-v$VERSION_UPDATE-$ADDON_VERSION.zip
   unzip /storage/gamestarter-update.zip -d /storage/gamestarter-update
   rm /storage/gamestarter-update.zip
   # movemos la carpeta del addon nueva y nos aseguramos que sobreescribe lo que tiene que sobreescribir
   cp -r /storage/gamestarter-update/script.gamestarter /storage/.kodi/addons/
   
   #forzamos la reinstalacion al iniciar el addon
   rm $ADDON_DIRECTORY/resources/bin/installed
   #borramos la carpeta de archivos de actualizacion
   rm -rf /storage/gamestarter-update
   kodi-send --action=Notification"(Gamestarter,Gamestarter Updated,6000,/storage/.kodi/addons/script.gamestarter/icon.png)"
fi

rm $ADDON_DIRECTORY/changelog_latest.txt

kodi-send --action="xbmc.Dialog.Close(busydialog)"
