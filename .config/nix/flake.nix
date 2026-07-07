{
  description = "nix-darwin system flake";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    nix-darwin.url = "github:nix-darwin/nix-darwin/master";
    nix-darwin.inputs.nixpkgs.follows = "nixpkgs";
    nix-homebrew.url = "github:zhaofengli/nix-homebrew";
    
    # Optional: Declarative tap management
    homebrew-core = {
      url = "github:homebrew/homebrew-core";
      flake = false;
    };
    homebrew-cask = {
      url = "github:homebrew/homebrew-cask";
      flake = false;
    };
    turso-tap = {
      url = "github:tursodatabase/homebrew-tap";
      flake = false;
    };

    # for trash-cli
    # homebrew-macmade-tap = {
    #   url = "github:macmade/homebrew-tap";
    #   flake = false;
    # };
  };

  outputs = inputs@{ self, nix-darwin, nix-homebrew, homebrew-core, homebrew-cask, turso-tap, nixpkgs }:
  let
    # ── Fork here ──────────────────────────────────────────────────────────
    # The one value a fork must change. Owns the homebrew prefix and is
    # `system.primaryUser`, so it has to be declared (pure flake eval can't
    # read $USER). The config is keyed `default`, not by hostname - every
    # machine rebuilds with `#default`, so there's no host to sync.
    username = "craigruks";
    # ───────────────────────────────────────────────────────────────────────

    configuration = { pkgs, config, ... }: {
      # Apps kept manual ON PURPOSE - most have casks, but these self-update
      # faster than casks track (or can't be casked: Frame, Lexicon, Apple's).
      # Listed so every installed app is accounted for here or in the private
      # wrapper flake (/etc/nix-darwin - see README "Private apps").
      # 1Password - https://1password.com/ - password manager
      # Adobe products
      # Claude - https://claude.ai/download - anthropic desktop app
      # Codex - https://openai.com/codex - openai coding agent app
      # Conductor - https://conductor.build - parallel claude code manager (trialing)
      # Frame - design tool
      # Helium - https://helium.computer - browser (trialing)
      # Lexicon - https://www.lexicondj.com/ - dj organization
      # Logic Pro - https://www.apple.com/logic-pro/ - music production
      # Photos - https://www.apple.com/photos/ - photo organization
      # Rekordbox - https://rekordbox.com/ - dj organization
      # Signal - https://signal.org/ - chat and file sharing
      # Supacode - https://supacode.dev - claude code manager
      # Zed - https://zed.dev - editor
      # Zen - https://zen-browser.app - browser (trialing)

      # List packages installed in system profile. To search by name, run:
      # $ nix-env -qaP | grep wget
      # https://search.nixos.org/packages
      environment.systemPackages =
        [ 
          # CLI tools
          pkgs.bat        # cat with syntax highlighting (also fzf/preview backend)
          pkgs.eza        # modern ls (git-aware, icons, tree)
          pkgs.fd         # fast, ergonomic find (used by fzf, sesh, telescope)
          pkgs.fzf
          pkgs.ripgrep    # fast grep (rg) - also powers telescope live-grep
          pkgs.starship
          pkgs.sesh
          pkgs.stow
          pkgs.tmux
          pkgs.zoxide
          pkgs.zsh
          pkgs.zsh-autosuggestions
          pkgs.zsh-completions
          pkgs.zsh-defer
          pkgs.zsh-syntax-highlighting

          # Applications
          # pkgs.anki-bin -> homebrew cask "anki" (real /Applications install, auto-updates)
          # pkgs.appcleaner
          # pkgs.brave  -> moved to homebrew cask "brave-browser":
          # browsers need security auto-updates + a clean LaunchServices
          # registration on macOS (nixpkgs builds go stale & confuse Raycast/Spotlight)
          # pkgs.discord -> homebrew cask "discord" (same reason: auto-updates + clean launch)
          # pkgs.firefox -> homebrew cask "firefox"
          # pkgs.obsidian -> homebrew cask "obsidian" (same reason as anki)
          # pkgs.ollama -> homebrew cask "ollama-app" (app + CLI in one)
          # pkgs.ghostty - broken

          # System
          pkgs.mkalias

          # Coding
          pkgs.ffmpeg_6-headless
          pkgs.just
          # mise -> homebrew brew "mise": nixpkgs builds it from source and a
          # permission-bits test fails in the Nix sandbox; brew ships a bottle
          pkgs.shopify-cli

          # VIM
          pkgs.neovim
          pkgs.tree-sitter
          pkgs.yazi  # TODO compare with ranger
        ];

      fonts.packages = [
        pkgs.nerd-fonts.jetbrains-mono
      ];

      homebrew = {
        enable = true;
        taps = [
          "dmno-dev/tap"        # varlock - per-project env schema/validation
          "libsql/sqld"         # sqld / libsql-server
          "tursodatabase/tap"   # turso CLI
          "modem-dev/tap"       # hunk (review-first terminal diff viewer)
          # "macmade/tap"
        ];
        brews = [
          # doesn't work, TODO
          # { name = "macmade/tap/trash"; args = [ "HEAD" ]; }

          # system
          "mas"  # Mac App Store CLI

          # code
          "cloudflare-wrangler"
          "coreutils"  # gtimeout etc - was added for cursor (since removed); drop if nothing else needs it
          "webp"
          "gh"
          "gitleaks"  # secret scanner - used by .githooks/pre-commit
          "mise"  # dev tool/runtime version manager (bottle; avoids nixpkgs source build)
          "fnox"  # machine/ambient secret resolver (1Password backend) - see README Secrets policy

          # spot
          "gettext"
          "libyaml"  # ruby psych ext - without it mise ruby builds fail
          "openssl"
          "readline"
          "sqlite3"
          "tcl-tk"
          "zlib"
          "xz"

          # restored after cleanup="zap" removed them (were installed but not declared)
          "lazygit"
          "gnupg"                     # gpg - git signing / encryption
          "cloudflared"               # cloudflare tunnel
          # tapped formulae (taps declared above)
          "dmno-dev/tap/varlock"      # per-project env schema + validation (1Password backend) - see README
          "tursodatabase/tap/turso"   # turso edge-db CLI
          "libsql/sqld/sqld"          # libsql server
          "modem-dev/tap/hunk"        # review-first terminal diff viewer (needs Node 18+)
          # optional (uncomment if you use them): "oha" (HTTP load test), "poppler" (PDF utils)
        ];
        casks = [
          "1password-cli"  # op - 1Password CLI; backs both fnox and varlock secret resolution
          "affinity-designer"
          "affinity-photo"
          "anki"
          "arc"
          "betterdisplay"
          "brave-browser"
          "discord"
          # "figma"
          "firefox"
          "flycut"  # clipboard manager
          "ghostty"
          "google-chrome"
          "granola"  # ai meeting notetaker (fathom replacement)
          "imageoptim"
          "keycastr"  # keystroke visualiser (screencasts)
          "kitlangton-hex"  # hex - voice-to-text dictation
          "loom"
          "mixed-in-key"
          "ngrok"
          # "notion"
          "obsidian"
          "ollama-app"  # menu-bar server + links the ollama CLI
          "orbstack"
          # "postico"
          "raycast"
          "rectangle"
          # "skype"  # retired by Microsoft May 2025; download.skype.com is gone
          "splice"
          "spotify"
          "tella"  # screen recording
          # "thunderbird"
          "tomatobar"
          "typora"
          "vlc"
          "workflowy"
          "zoom"

          # TODO try these
          # "amethyst"  # tile manager https://youtu.be/5nwnJjr5eOo?si=AYRU3G26qmpKNTrw
          # "beekeeper-studio"  # SQL client
          # "fork"  # git client
          "shottr"  # screenshot editor
          # "yaak"  # gql + grpc client - alt to postman
          # "zen-browser"  # alt to chrome
        ];
        # masApps DISABLED (intentionally). `mas` needs the user's GUI / App Store
        # (StoreKit) session. nix-darwin now runs activation as root via
        # `sudo darwin-rebuild`, which has no App Store session, so `mas install`
        # fails for every app during activation - even though the same command
        # works in your terminal. This is inherent to mas + StoreKit; no setting
        # fixes it. All these apps are already installed and auto-update via the
        # App Store. To add/update MAS apps, run `mas` directly in your terminal
        # (e.g. `mas upgrade`). Kept below as a fresh-machine checklist.
        /*
        masApps = {
          "Amphetamine" = 937984704;
          "Bear" = 1091189122;
          "DaisyDisk" = 411643860;
          "Excel" = 462058435;
          "Image2Icon" = 992115977;
          "Line" = 539883307;
          "Nord" = 905953485;
          "Numbers" = 409203825;
          "Pages" = 409201541;
          "Power JSON" = 499768540;
          "Slack" = 803453959;
          "Telegram" = 747648890;

          # Run `xcode-select --install` after installing
          # Then install simulators from XCode prefs
          # Only run this on new install, then let OSX update with Software Update
          # "Xcode" = 497799835;

          # TODO try these
          # "TripMode" = 1513400665;  # Track traffic
          # "Red2" = 1491764008;  # Redis GUI

        };
        */
        onActivation = {
          cleanup = "zap";
          autoUpdate = true;
          # upgrade = false: activation only ensures packages are INSTALLED, it does
          # not mass-upgrade outdated casks/formulae. A single cask quirk (dead
          # download, quarantine error, etc.) would otherwise abort the whole
          # system activation. Run `brew upgrade` manually to update packages.
          upgrade = false;
        };
      };

      # Zap seatbelt (guard 2 of 2; the other is a check in `just rebuild`).
      # cleanup="zap" deletes an undeclared cask's DATA (Application Support,
      # prefs) via its zap stanza, not just the .app. If a rebuild ever drops a
      # cask that's still installed - missing/broken private wrapper, a
      # commented-out line, a typo - activation would zap it and destroy that
      # data (this cost us Plex/SABnzbd/Calibre once; see README "Private apps").
      # This runs before Homebrew and ABORTS activation if the build no longer
      # declares a cask that is currently installed, so the loss can't happen
      # silently. It also blocks zapping a cask you installed out-of-band. Remove
      # one on purpose with `brew uninstall --zap <name>` first. Armed only while
      # cleanup="zap"; unmanaged paths (bare `darwin-rebuild switch`, the shim,
      # or `just`) all hit it since it lives in activation itself.
      system.activationScripts.preActivation.text =
        pkgs.lib.optionalString (config.homebrew.onActivation.cleanup == "zap") ''
          if [ -x /opt/homebrew/bin/brew ]; then
            echo "checking zap seatbelt (installed casks vs declared)..." >&2
            _declared=$(printf '%s\n' ${pkgs.lib.escapeShellArgs
              (map (c: if builtins.isString c then c else c.name) config.homebrew.casks)
            } | sed 's#.*/##' | sort -u)
            _installed=$(sudo --user=${username} --set-home /opt/homebrew/bin/brew list --cask -1 2>/dev/null | sed 's#.*/##' | sort -u)
            _victims=$(comm -23 <(printf '%s\n' "$_installed") <(printf '%s\n' "$_declared") | grep -v '^$' || true)
            if [ -n "$_victims" ]; then
              echo >&2 "error: refusing to activate - cleanup=\"zap\" would DELETE data for installed cask(s) this build no longer declares:"
              printf '%s\n' "$_victims" | sed 's/^/  - /' >&2
              echo >&2 "Likely cause: the private wrapper (/etc/nix-darwin -> ~/.nix-private) is missing, or a cask was dropped/typo'd."
              echo >&2 "Fix: restore ~/.nix-private then 'just private-init', or re-add the cask, then rebuild."
              echo >&2 "To remove one on purpose: 'brew uninstall --zap <name>' first."
              exit 1
            fi
          fi
        '';

      system.activationScripts.applications.text = let
        env = pkgs.buildEnv {
          name = "system-applications";
          paths = config.environment.systemPackages;
          pathsToLink = [ "/Applications" ];
        };
      in
        pkgs.lib.mkForce ''
        # Set up applications.
        echo "setting up /Applications..." >&2
        rm -rf /Applications/Nix\ Apps
        mkdir -p /Applications/Nix\ Apps
        find ${env}/Applications -maxdepth 1 -type l -exec readlink '{}' + |
        while read -r src; do
          app_name=$(basename "$src")
          echo "copying $src" >&2
          ${pkgs.mkalias}/bin/mkalias "$src" "/Applications/Nix Apps/$app_name"
        done
            '';

      # Skip building the darwin manual/manpages. nixpkgs removed
      # nixos-render-docs --toc-depth (2026-07) and nix-darwin master still
      # passes it, which broke every `just rebuild` at darwin-manual-html.drv.
      # darwin-uninstaller must go too: it evaluates its own inner darwin
      # system with docs enabled, pulling the broken drv back in.
      # Re-enable both once upstream catches up, if ever missed.
      documentation.enable = false;
      system.tools.darwin-uninstaller.enable = false;

      # Necessary for using flakes on this system.
      nix.settings.experimental-features = "nix-command flakes";

      # Enable alternative shell support in nix-darwin.
      programs.zsh.enable = true;

      # Set up Homebrew environment
      environment.shellInit = ''
        # Homebrew in PATH
        if [ -x /opt/homebrew/bin/brew ]; then
          eval "$(/opt/homebrew/bin/brew shellenv)"
        fi
      '';

      # Auto upgrade nix packages
      nix.enable = false;
      nix.package = pkgs.nix;
      nix.settings = {
        auto-optimise-store = true;
        substituters = [ "https://cache.determinate.systems" ];
      };
      nix.gc = {
        # automatic = true;  # Remove: needs nix.enable
        interval = { Weekday = 0; Hour = 2; Minute = 0; };  # Weekly Sunday 2AM
      };

      # Use touch-id for sudo
      security.pam.services.sudo_local.touchIdAuth = true;

      # Required by modern nix-darwin for user-scoped activation
      # (homebrew prefix, per-user system.defaults, etc.)
      system.primaryUser = username;

      system.defaults = {
        dock.autohide = true;  # Hide dock
        finder.FXPreferredViewStyle = "clmv";  # Show list view
        finder.NewWindowTarget = "Home";  # Open finder in home
        finder.QuitMenuItem = true;  # Show quit menu item
        finder.ShowExternalHardDrivesOnDesktop = false;  # Hide external drives
        finder.ShowHardDrivesOnDesktop = false;  # Hide hard drives
        loginwindow.GuestEnabled = false;  # Disable guest account
        NSGlobalDomain._HIHideMenuBar = true;  # Hide menu bar
        NSGlobalDomain.AppleICUForce24HourTime = true;  # Force 24 hour time
        NSGlobalDomain.AppleInterfaceStyle = "Dark";  # Dark mode
        NSGlobalDomain.KeyRepeat = 2;  # Fastest key repeat
      };

      # Set Git commit hash for darwin-version.
      system.configurationRevision = self.rev or self.dirtyRev or null;

      # Used for backwards compatibility, please read the changelog before changing.
      # $ darwin-rebuild changelog
      system.stateVersion = 6;

      # The platform the configuration will be used on.
      nixpkgs.hostPlatform = "aarch64-darwin";
      nixpkgs.config.allowUnfree = true;
    };
  in
  {
    # The entire public config as one composable module. The private wrapper
    # flake at /etc/nix-darwin (machine-local, never in git - see README
    # "Private apps") imports this and appends its own homebrew.casks/brews
    # under fully PURE eval. List options merge, so the wrapper only declares
    # the extras. A machine without the wrapper builds
    # darwinConfigurations.default below directly - same config, no extras.
    darwinModules.default = {
      imports = [
        configuration
        nix-homebrew.darwinModules.nix-homebrew
        {
          nix-homebrew = {
            # Install Homebrew under the default prefix
            enable = true;

            # Apple Silicon Only: Also install Homebrew under the default Intel prefix for Rosetta 2
            enableRosetta = true;

            # User owning the Homebrew prefix
            user = username;

            # Automatically migrate existing Homebrew installations
            autoMigrate = true;
          };
        }
      ];
    };

    # Build darwin flake using:
    # $ darwin-rebuild build --flake .#default
    darwinConfigurations.default = nix-darwin.lib.darwinSystem {
      modules = [ self.darwinModules.default ];
    };

    darwinPackages = self.darwinConfigurations.default.pkgs;
  };
}
