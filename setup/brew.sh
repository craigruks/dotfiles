#!/bin/bash

# Make sure we’re using the latest Homebrew
brew update

# Upgrade any already-installed formulae
brew upgrade



# GNU core utilities (those that come with OS X are outdated)
brew install coreutils
brew install moreutils
# GNU `find`, `locate`, `updatedb`, and `xargs`, `g`-prefixed
brew install findutils
# GNU `sed`, overwriting the built-in `sed`
brew install gnu-sed --with-default-names

# Bash 4 + autocompletion
brew install bash
brew tap homebrew/versions
brew install bash-completion2
brew install homebrew/completions/brew-cask-completion

# generic colouriser http://kassiopeia.juls.savba.sk/~garabik/software/grc/
brew install grc

# Install more recent versions of some OS X tools
brew install vim --override-system-vi
brew install homebrew/dupes/grep
brew install homebrew/dupes/openssh
brew install homebrew/dupes/screen
brew install git

# php
brew tap homebrew/dupes
brew tap homebrew/versions
brew tap homebrew/homebrew-php
brew install php71
brew install composer
brew install php71-mcrypt

# python
brew install python@2
brew install python

# ruby via rbenv, finished in setup-a-new-machine.sh
brew install libyaml
brew install gpg
brew install rbenv

# heroku development
brew install heroku-toolbelt

# ftp cli !
brew install lftp

# https://github.com/sivel/speedtest-cli
brew install speedtest_cli

# other useful binaries
brew install node # This installs `npm` too using the recommended installation method

# compress file gzip zlib
brew install zopfli

# 7zip archive/extract
brew install p7zip

# video encoder
# brew install ffmpeg --with-libvpx

# terminal recorder
# brew install asciinema

# Remove outdated versions from the cellar
brew cleanup
