#!/bin/bash

# to maintain cask: `brew update && brew upgrade brew-cask && brew cleanup && brew cask cleanup`
# to search for new ones https://caskroom.github.io/search


# cask itself
brew install caskroom/cask/brew-cask
brew tap caskroom/versions

# browsers
brew cask install firefox
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
brew cask install atom
brew cask install gifrocket
brew cask install gitbox
brew cask install gitup
brew cask install imageoptim
brew cask install iterm2
brew cask install openoffice
brew cask install postgres
brew cask install postico
brew cask install qlmarkdown
brew cask install quiver
brew cask install rested
brew cask install shuttle
brew cask install sublime-text
brew cask install transmit
brew cask install virtualbox

# maintenance
brew cask install apptrap
brew cask install carbon-copy-cloner
brew cask install cleanmymac
# brew cask install coconutbattery  # check iphone battery
brew cask install daisydisk

# media
brew cask install flash-player  # for spotify
brew cask install keepingyouawake
brew cask install lastfm
brew cask install plex-media-server
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

# usenet
brew cask install couchpotato
brew cask install sabnzbd
brew cask install sonarr
brew cask install utorrent
brew cask install unrarx
brew cask install viscosity


# Not on cask but I want regardless.

# airmail 2
# day one
# gemini 2
# docker beta
# feedly
# gotomeeting
# icon slate
# monity
# monosnap
# power json editor
# wunderlist
