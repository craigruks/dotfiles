# My dotfiles

This is the core set of files that I clone on a new machine.

Used [paulirish/dotfiles](https://github.com/paulirish/dotfiles) as a starting point (thank you!!). Once I pared down to only what I wanted, I looked through various other dotfiles to glean tidbits here and there.


#### Installing & using

* fork this to your own acct
* clone that repo
* read and run all files in the `manual run` section below, in that order


## Overview of files

####  Automatic config
* `.inputrc` - behavior of the actual prompt line

#### shell environment
```bash
.aliases  # one liner shortcuts
.bash_profile  # settings for bash
.bash_prompt  # color!
.exports  # split out exports from profiles
.functions  # larger helper methods
.extra  # not included, explained below
```

#### manual run
* `setup-a-new-machine.sh` - random apps i need installed
* `symlink-setup.sh`  - sets up symlinks for all dotfiles and vim config.
* `.osx` - run on a fresh osx setup
* `brew.sh` & `brew-cask.sh` - homebrew initialization

#### git
* `.gitconfig`
* `.gitmodules`


### `~/.extra` for your private configuration

There will be items that don't belong to be committed to a git repo, because either 1) it shoudn't be the same across your machines or 2) it shouldn't be in a git repo. In there I have some EXPORTS, my PATH construction, and a few aliases for development purposes.

This is how I do mine:

```shell
# default unix bins
PATH=/usr/local/bin:/usr/bin:/bin:/sbin

# git-friendly
PATH=$PATH:~/code/git-friendly

# heroku toolbelt
PATH=$PATH:/usr/local/heroku/bin

# postgres
PATH=$PATH:/Applications/Postgres.app/Contents/Versions/9.3/bin

# ruby
PATH=$PATH:~/.rvm/bin

# ...
```


### `~/.osx` for OS X defaults

Mathias's repo and/or Paul's are great starting points. I walked through each one, commented out ones that didn't interest me, ran it rebooted and then tweaked anything that I didn't like.

```bash
./.osx
```


### `~/.ssh`

A nice goodie from Paul Irish that speeds up the connection to Github.


### `~/bin`

One-off binaries that aren't via an npm global or homebrew.
- [wifi-password](https://github.com/rauchg/wifi-password)
- [git-overwritten](https://github.com/mislav/dotfiles/blob/master/bin/git-overwritten)



## Monthly Cleanup

Once a month I do the following cleanup / security checks on my machine. Helps keep things lean and clean.

- Brew/Cask updates `brew update && brew upgrade brew-cask && brew cleanup && brew cask cleanup && brew prune && brew doctor`
- Open App Store, check/install updates
- Open Adobe, check/install updates
- Use Carbon Copy Cloner, backup HD
- Use Clean My Mac
- Use Lockdown
- Use MalwareBytes
