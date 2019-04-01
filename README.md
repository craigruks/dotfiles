# My dotfiles

This is the core set of files that I clone on a new machine.

Used [paulirish/dotfiles](https://github.com/paulirish/dotfiles) as a starting point (thank you!!). Once I pared down to only what I wanted, I looked through various other dotfiles to glean tidbits here and there. Notably, [Remy Sharp's](https://remysharp.com/2018/08/23/cli-improved) upgrades in 2018 were much needed.


#### Installing & using

* fork this to your own acct
* clone that repo
* read and run all files in the `manual run` section below, in that order


## Overview of files

#### oh-my-zsh
* `.zshrc` - oh-my-zsh configuration

#### shell environment
```bash
.aliases  # one liner shortcuts
.functions  # larger helper methods
.extra  # anything custom, secret that should not be in repo
```

#### manual run
* `setup-a-new-machine.sh` - random apps i need installed
* `symlink-setup.sh`  - sets up symlinks for all dotfiles and configs.
* `.osx` - run on a fresh osx setup
* `brew.sh` & `brew-cask.sh` - homebrew initialization

#### git
* `.gitconfig`


### `~/.extra` for your private configuration

There will be items that don't belong to be committed to a git repo, because either 1) it shoudn't be the same across your machines or 2) it shouldn't be in a git repo. In there I have some EXPORTS, my PATH construction, and a few functions to enter projects.



### `~/.osx` for OS X defaults

Mathias's repo and/or Paul's are great starting points. I walked through each one, commented out ones that didn't interest me, ran it rebooted and then tweaked anything that I didn't like.

```bash
./.osx
```


### `~/bin`

One-off binaries that aren't via an npm global or homebrew.
- [wifi-password](https://github.com/rauchg/wifi-password)
- [git-overwritten](https://github.com/mislav/dotfiles/blob/master/bin/git-overwritten)



## Monthly Cleanup

Once a month I do the following cleanup / security checks on my machine. Helps keep things lean and clean.

- Brew updates `brew update && brew upgrade && brew cu && brew cleanup && brew cask cleanup && brew cleanup --prune-prefix && brew doctor` - make sure that the `brew cu` is run in Terminal, in case it upgrades iTerm2!
- Docker cleanup
```
docker rmi $(docker images --filter "dangling=true" -q --no-trunc)
docker rmi $(docker images | grep "none" | awk '/ / { print $3 }')
```
- Open App Store, check/install updates
- Open Adobe, check/install updates
- Use Clean My Mac
- Use Lockdown
- Use MalwareBytes
- Use Carbon Copy Cloner, backup HD
