## Introduction

Etudiant à SUPINFO ? **iBooster** est une application vous permettant de naviguer plus facilement sur campus-booster via une application mobile native.

## iBooster

#### Compatibilité
OS4 -> Seulement pour les OS 4.2.1 sur iPhone 3G et iPod Touch 2G. Non recommandé pour les autres versions et appareils. Non disponible sur l'App Store.  
Current -> Version en cours (bientôt disponible sur l'App Store), compatible iOS 5.1+ sur 3GS, iPhone 4/4S/5, iPad 1/2/Retina

#### Compilation
Ouvrir le .xcodeproj de la version que vous voulez (Current, OS4), et cliquez simplement sur "Run".

*Note : Comme pour toute application iOS, pour déployer sur un appareil depuis xcode, il faut un compte développeur payant.*

## Comment ça marche ?
Le projet est séparé en plusieurs parties, dont une commune à toutes les applications (iBoosterToolkit).

La page voulue de campus-booster est chargée dans une webview en fond (invisible). jQuery et iBoosterToolkit y sont injectés et la méthode voulue est appellée.  

#### iBoosterToolkit 

Cette bibliothèque Javascript réutilisable parse la page affichée et renvoie les données formatées en JSON

*Note : Une réécriture d'iBoosterToolkit qui ne se repose pas sur jQuery est prévue, mais pas prioritaire.*

##Bibliothèques utilisées

[tonisalae/TSMiniWebBrowser](https://github.com/tonisalae/TSMiniWebBrowser) Navigateur web in-app

[chrismiles/CMPopTipView](https://github.com/chrismiles/CMPopTipView) Popups des evenements du calendrier

[muhku/calendar-ui](https://github.com/muhku/calendar-ui) Vues du planning

[cybergarage/iCal4ObjC](https://github.com/cybergarage/iCal4ObjC) Parser iCal pour le planning

