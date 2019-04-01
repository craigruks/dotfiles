#!/bin/bash

# to maintain cask: `brew update && brew cleanup && brew cask cleanup`
# to search for new ones https://caskroom.github.io/search
#
# to update a cask: `brew cu [cask-name]` per https://github.com/buo/homebrew-cask-upgrade

# allow admins to manage homebrew's local install directory
sudo chgrp -R admin /usr/local
sudo chmod -R g+w /usr/local

# install cask itself
brew tap caskroom/cask
# add ability to upgrade casks
brew tap buo/cask-upgrade

# browsers
# brew cask install firefox
brew cask install google-chrome

# cloud
brew cask install dropbox
brew cask install google-drive

# daily
brew cask install 1password
brew cask install alfred
brew cask install spectacle

# dev
brew cask install adobe-creative-cloud
brew cask install adobe-illustrator-cc
brew cask install adobe-indesign-cc
brew cask install adobe-photoshop-cc
brew cask install adobe-photoshop-lightroom
brew cask install gitbox
brew cask install gitup
brew cask install imageoptim
brew cask install iterm2
brew cask install ngrok
brew cask install osxfuse
# brew cask install postgres
brew cask install postico
brew cask install qlmarkdown
brew cask install quiver
brew cask install rested
brew cask install sublime-text
brew cask install transmit4
brew cask install virtualbox
# --- trying out:
# brew cask install google-cloud-sdk

# maintenance
# brew cask install apptrap
brew cask install carbon-copy-cloner
brew cask install cleanmymac
# brew cask install coconutbattery  # check iphone battery
brew cask install daisydisk

# media
brew cask install flash-player  # for spotify
# brew cask install keepingyouawake
brew cask install lastfm
brew cask install macdown
brew cask install microsoft-office
# brew cask install plex-media-server
brew cask install spotify
brew cask install vlc

# security
brew cask install knockknock
brew cask install little-snitch
brew cask install lockdown  # https://github.com/SummitRoute/osxlockdown
brew cask install malwarebytes-anti-malware

# social
brew cask install franz
brew cask install skype
brew cask install slack

# # usenet
# # brew cask install couchpotato
# # brew cask install sabnzbd
# # brew cask install sonarr
# # brew cask install utorrent
# # brew cask install unrarx
# brew cask install viscosity


# # Not on cask but I want regardless.

# # day one
# # docker https://docs.docker.com/docker-for-mac/install/#download-docker-for-mac
# # feedly
# # gotomeeting
# # icon slate
# # microsoft remote desktop
# # monity
# # monosnap
# # patterns
# # power json editor
# # spark
# # wunderlist
# # xquartz (compile c++) https://www.xquartz.org
