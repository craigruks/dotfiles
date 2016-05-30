# copy paste this file in bit by bit.
# don't run it.
echo "do not run this script in one go. hit ctrl-c NOW"
read -n 1



##############################################################################################################
### old machine backup

#  backup old machine's key items
mkdir -p ~/migration/home
cd ~/migration


# what is worth reinstalling?
brew leaves > brew-list.txt    # all top-level brew installs
brew cask list > cask-list.txt
npm list -g --depth=0 > npm-g-list.txt

# then compare brew-list to what's in `brew.sh`
#   comm <(sort brew-list.txt) <(sort brew.sh-cleaned-up)


# let's hold on to these
cp -R ~/.ssh ~/migration/home
cp ~/.bash_history ~/migration/home
cp ~/.extra ~/migration/home
cp ~/.gitconfig.local ~/migration/home
cp /Library/Preferences/SystemConfiguration/com.apple.airport.preferences.plist ~/migration  # wifi


# (optional) take a screenshot of your dock to remember what goes where


# set up symlink of settings for any other apps
# find the application in [mackup](https://github.com/lra/mackup/tree/master/mackup/applications) to see where settings are



##############################################################################################################
### install fresh copy of el capitan

# good starting point [here](http://mashable.com/2015/10/01/clean-install-os-x-el-capitan/)



##############################################################################################################
### Install XCode Command Line Tools
# thx https://github.com/alrra/dotfiles/blob/ff123ca9b9b/os/os_x/installs/install_xcode.sh

if ! xcode-select --print-path &> /dev/null; then

    # Prompt user to install the XCode Command Line Tools
    xcode-select --install &> /dev/null

    # - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

    # Wait until the XCode Command Line Tools are installed
    until xcode-select --print-path &> /dev/null; do
        sleep 5
    done

    print_result $? 'Install XCode Command Line Tools'

    # - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

    # Point the `xcode-select` developer directory to
    # the appropriate directory from within `Xcode.app`
    # https://github.com/alrra/dotfiles/issues/13

    sudo xcode-select -switch /Applications/Xcode.app/Contents/Developer
    print_result $? 'Make "xcode-select" developer directory point to Xcode'

    # - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

    # Prompt user to agree to the terms of the Xcode license
    # https://github.com/alrra/dotfiles/issues/10

    sudo xcodebuild -license
    print_result $? 'Agree with the XCode Command Line Tools licence'

fi



##############################################################################################################
### homebrew!

# (if your machine has /usr/local locked down (like google's), you can do this to place everything in ~/.homebrew
mkdir $HOME/.homebrew && curl -L https://github.com/mxcl/homebrew/tarball/master | tar xz --strip 1 -C $HOME/.homebrew
export PATH=$HOME/.homebrew/bin:$HOME/.homebrew/sbin:$PATH

# install all the things
./brew.sh
./brew-cask.sh




##############################################################################################################
### install of common things

# github.com/jamiew/git-friendly
# the `push` command which copies the github compare URL to my clipboard is heaven
bash < <( curl https://raw.github.com/jamiew/git-friendly/master/install.sh)


# github.com/thebitguru/play-button-itunes-patch
# disable itunes opening on media keys
git clone https://github.com/thebitguru/play-button-itunes-patch ~/code/play-button-itunes-patch


# for the c alias (syntax highlighted cat)
sudo easy_install Pygments


# change to bash 4 (installed by homebrew)
BASHPATH=$(brew --prefix)/bin/bash
sudo bash -c 'echo $(brew --prefix)/bin/bash >> /etc/shells'
chsh -s $BASHPATH  # will set for current user only.
echo $BASH_VERSION  # should be 4.x not the old 3.2.X


# setting up the sublime symlink
ln -sf "/Applications/Sublime Text.app/Contents/SharedSupport/bin/subl" ~/bin/subl


# python virtualenvwrapper
pip install virtualenv
pip install virtualenvwrapper


# ruby via rvm
command curl -sSL https://rvm.io/mpapis.asc | gpg --import -
\curl -L https://get.rvm.io | bash -s stable
source ~/.rvm/scripts/rvm
rvm install ruby-2.3.1  # check this is latest version http://www.ruby-lang.org/en/downloads/


# node modules
npm install -g git-open  # `git open` to open the GitHub page or website for a repository.
npm install -g trash-cli  # trash as the safe `rm` alternative
npm install -g statik  # use with `server` function



##############################################################################################################
### remaining configuration

# go read mathias, paulmillr, gf3, alraa's dotfiles to see what's worth stealing.

# prezto and antigen communties also have great stuff
#   github.com/sorin-ionescu/prezto/blob/master/modules/utility/init.zsh

# set up osx defaults
#   maybe something else in here https://github.com/hjuutilainen/dotfiles/blob/master/bin/osx-user-defaults.sh
sh .osx

# setup and run Carbon Copy Cloner!



##############################################################################################################
### symlinks to link dotfiles into ~/

# move git credentials into `~/.gitconfig.local` http://stackoverflow.com/a/13615531/89484
# now .gitconfig can be shared across all machines and only the .local changes

# symlink it up!
./symlink-setup.sh

# add manual symlink for .ssh/config



##############################################################################################################
### post symlinks installations

# install nvm https://github.com/creationix/nvm
curl -o- https://raw.githubusercontent.com/creationix/nvm/v0.31.1/install.sh | bash


# store mac address before any spoofing, just in case, run this command then copy out xx:xx:xx:xx:xx:xx
ifconfig en0 ether


# symlink settings (some of these directories won't exist yet)

# adobe photoshop
cd ~/Library/Preferences
ln -s ~/Google\ Drive/Apps/Adobe/Adobe\ Photoshop\ CC\ 2015\ Settings

# couchpotato
cd ~/Library/Application\ Support/CouchPotato
ln -s ~/Google\ Drive/Apps/CouchPotato/database
ln -s ~/Google\ Drive/Apps/CouchPotato/db_backup
ln -s ~/Google\ Drive/Apps/CouchPotato/settings.conf

# ios simulator
ln -s /Applications/Xcode.app/Contents/Developer/Applications/Simulator.app/ /Applications/

# sabnzbd
cd ~/Library/Application\ Support
ln -s ~/Google\ Drive/Apps/SABnzbd

# sonarr
cd ~/.config
ln -s ~/Google\ Drive/Apps/Sonarr/NzbDrone

# sublime
cd ~/Library/Application\ Support/Sublime\ Text\ 3/Packages/
ln -s ~/Google\ Drive/Apps/Sublime/User

# transmit
cd ~/Library/Application\ Support/Transmit
ln -s ~/Google\ Drive/Apps/Transmit/Favorites

# viscocity
cd ~/Library/Application\ Support
ln -s ~/Google\ Drive/Apps/Viscocity


# install dropbox version for home vs work
# based on http://wp.me/p4fLz7-d1
HOME=$HOME/.dropbox-home /Applications/Dropbox.app/Contents/MacOS/Dropbox &

# download latest 2 IE virtualbox instance from modern
# https://developer.microsoft.com/en-us/microsoft-edge/tools/vms/mac/
