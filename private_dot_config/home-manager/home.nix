{
  config,
  pkgs,
  inputs,
  system,
  lib,
  ...
}: {
  home.enableNixpkgsReleaseCheck = false;

  home.homeDirectory = "/Users/${config.home.username}";

  home.stateVersion = "23.05";

  home.packages = with pkgs; [
    cachix # to store cache binaries on cachix.org
    nix-prefetch-git # to get git signatures for fetchFromGit

    coreutils
    gettext

    chezmoi

    docker

    pipx

    pgcli

    zsh
    # devenv
    just
    tealdeer
    mosh

    xan

    kubecolor

    # firebase-tools
    # flyctl

    # ansible

    localsend

    yubikey-manager

    nodejs
    pnpm

    difftastic
    git
    git-lfs
    jump
    neovim
    # altair
    android-tools
    # vagrant
    kubectl

    (pkgs.google-cloud-sdk.withExtraComponents [
      pkgs.google-cloud-sdk.components.gke-gcloud-auth-plugin
    ])

    claude-code
    claude-code-router

    monaspace
    atkinson-hyperlegible-next
    nerd-fonts.symbols-only
  ];

  home.sessionVariables = {
    EDITOR = "nvim";
    VISUAL = "nvim";
    PAGER = "less";
    SHELL = "/bin/zsh";
  };

  programs = {
    home-manager = {
      enable = true;
    };

    zsh = {
      enable = true;
      enableVteIntegration = true;

      initContent = let
        zshConfigEarlyInit = lib.mkOrder 500 ''
          ZSH_AUTOSUGGEST_USE_ASYNC=true

          # Documentation: https://github.com/romkatv/zsh4humans/blob/v5/README.md.

          # Periodic auto-update on Zsh startup: 'ask' or 'no'.
          # You can manually run `z4h update` to update everything.
          zstyle ':z4h:' auto-update      'no'
          # Ask whether to auto-update this often; has no effect if auto-update is 'no'.
          zstyle ':z4h:' auto-update-days '28'

          # Move prompt to the bottom when zsh starts and on Ctrl+L.
          zstyle ':z4h:' prompt-at-bottom 'yes'

          # Keyboard type: 'mac' or 'pc'.
          zstyle ':z4h:bindkey' keyboard  'mac'

          # Mark up shell's output with semantic information.
          zstyle ':z4h:' term-shell-integration 'yes'

          zstyle ':z4h:' iterm2-integration 'no'

          zstyle ':z4h:' start-tmux 'no'

          # Right-arrow key accepts one character ('partial-accept') from
          # command autosuggestions or the whole thing ('accept')?
          zstyle ':z4h:autosuggestions' forward-char 'accept'

          # Recursively traverse directories when TAB-completing files.
          zstyle ':z4h:fzf-complete' recurse-dirs 'yes'

          # Enable direnv to automatically source .envrc files.
          zstyle ':z4h:direnv'         enable 'yes'
          # Show "loading" and "unloading" notifications from direnv.
          zstyle ':z4h:direnv:success' notify 'yes'

          # Enable ('yes') or disable ('no') automatic teleportation of z4h over
          # SSH when connecting to these hosts.
          # zstyle ':z4h:ssh:example-hostname1'   enable 'yes'
          # zstyle ':z4h:ssh:*.example-hostname2' enable 'no'
          # The default value if none of the overrides above match the hostname.
          zstyle ':z4h:ssh:*'                   enable 'no'

          # Send these files over to the remote host when connecting over SSH to the
          # enabled hosts.
          # zstyle ':z4h:ssh:*' send-extra-files '~/.nanorc' '~/.env.zsh'

          # Clone additional Git repositories from GitHub.
          #
          # This doesn't do anything apart from cloning the repository and keeping it
          # up-to-date. Cloned files can be used after `z4h init`. This is just an
          # example. If you don't plan to use Oh My Zsh, delete this line.
          # z4h install ohmyzsh/ohmyzsh || return

          z4h install mafredri/zsh-async || return
          # zsh-async is needed before p10k is loaded
          z4h source mafredri/zsh-async/async.zsh

          z4h install hlissner/zsh-autopair || return
          z4h install oz/safe-paste || return
          z4h install jreese/zsh-titles || return

          # Install or update core components (fzf, zsh-autosuggestions, etc.) and
          # initialize Zsh. After this point console I/O is unavailable until Zsh
          # is fully initialized. Everything that requires user interaction or can
          # perform network I/O must be done above. Everything else is best done below.
          z4h init || return

          # Extend PATH.
          path=(~/bin $path)

          # Export environment variables.
          export GPG_TTY=$TTY

          # Source additional local files if they exist.
          z4h source ~/.env.zsh

          # Use additional Git repositories pulled in with `z4h install`.
          #
          # This is just an example that you should delete. It does nothing useful.
          # z4h source ohmyzsh/ohmyzsh/lib/diagnostics.zsh  # source an individual file
          # z4h load   ohmyzsh/ohmyzsh/plugins/emoji-clock  # load a plugin

          z4h load hlissner/zsh-autopair
          z4h load oz/safe-paste
          z4h load jreese/zsh-titles

          # Define key bindings.
          z4h bindkey undo Ctrl+/   Shift+Tab # undo the last command line change
          z4h bindkey redo Option+/           # redo the last undone command line change

          z4h bindkey z4h-cd-back    Shift+Left   # cd into the previous directory
          z4h bindkey z4h-cd-forward Shift+Right  # cd into the next directory
          z4h bindkey z4h-cd-up      Shift+Up     # cd into the parent directory
          z4h bindkey z4h-cd-down    Shift+Down   # cd into a child directory

          # Autoload functions.
          autoload -Uz zmv

          # Define functions and completions.
          function md() { [[ $# == 1 ]] && mkdir -p -- "$1" && cd -- "$1" }
          compdef _directories md

          # Define named directories: ~w <=> Windows home directory on WSL.
          [[ -z $z4h_win_home ]] || hash -d w=$z4h_win_home

          # Set shell options: http://zsh.sourceforge.net/Doc/Release/Options.html.
          setopt glob_dots     # no special treatment for file names with a leading dot
          setopt no_auto_menu  # require an extra TAB press to open the completion menu

          # Aliases
          alias top='htop'
          alias cal='cal -m -n 3'
          alias cat='bat'
          alias vim='nvim'
          alias gco='git checkout'
          alias gcob='git checkout -b'
          alias gcommit='git commit -am'
          alias gfix='git add . && git fix'
          alias gfeat='git add . && git feat'
          alias gdocs='git add . && git docs'
          alias gchore='git add . && git chore'
          alias grefact='git add . && git refact'
          alias gstyle='git add . && git style'
          alias gtest='git add . && git test'
          alias gpush='git push origin'
          alias gpull='git pull --no-ff origin'
          alias gbuild='git add . && git build'
          alias glog='git log --pretty=short'
          alias gfetchco='git-fetch-then-checkout'
          alias gsync='git-sync'
          alias grsorigin='git-reset-origin'

          # alias docker='podman'

          case `uname` in
            Darwin)
              if type brew &>/dev/null; then
                fpath+=($(brew --prefix)/share/zsh/site-functions)
              fi
            ;;
          esac

          eval "$(jump shell)"

          compdef kubecolor=kubectl
        '';
        zshConfig =
          lib.mkOrder 1000 ''
          '';
      in
        lib.mkMerge [zshConfigEarlyInit zshConfig];

      envExtra = ''
        # Documentation: https://github.com/romkatv/zsh4humans/blob/v5/README.md.
        #
        # Do not modify this file unless you know exactly what you are doing.
        # It is strongly recommended to keep all shell customization and configuration
        # (including exported environment variables such as PATH) in ~/.zshrc or in
        # files sourced from ~/.zshrc. If you are certain that you must export some
        # environment variables in ~/.zshenv, do it where indicated by comments below.

        if [ -n "''${ZSH_VERSION-}" ]; then
          # If you are certain that you must export some environment variables
          # in ~/.zshenv (see comments at the top!), do it here:
          #
          #   export GOPATH=$HOME/go

          export SSH_SK_PROVIDER=/usr/local/lib/sk-libfido2.dylib
          ABBR_SET_EXPANSION_CURSOR=1

          #
          # Do not change anything else in this file.

          : ''${ZDOTDIR:=~}
          setopt no_global_rcs
          [[ -o no_interactive && -z "''${Z4H_BOOTSTRAPPING-}" ]] && return
          setopt no_rcs
          unset Z4H_BOOTSTRAPPING
        fi

        Z4H_URL="https://raw.githubusercontent.com/romkatv/zsh4humans/v5"
        : "''${Z4H:=''${XDG_CACHE_HOME:-$HOME/.cache}/zsh4humans/v5}"

        umask o-w

        if [ ! -e "$Z4H"/z4h.zsh ]; then
          mkdir -p -- "$Z4H" || return
          >&2 printf '\033[33mz4h\033[0m: fetching \033[4mz4h.zsh\033[0m\n'
          if command -v curl >/dev/null 2>&1; then
            curl -fsSL -- "$Z4H_URL"/z4h.zsh >"$Z4H"/z4h.zsh.$$ || return
          elif command -v wget >/dev/null 2>&1; then
            wget -O-   -- "$Z4H_URL"/z4h.zsh >"$Z4H"/z4h.zsh.$$ || return
          else
            >&2 printf '\033[33mz4h\033[0m: please install \033[32mcurl\033[0m or \033[32mwget\033[0m\n'
            return 1
          fi
          mv -- "$Z4H"/z4h.zsh.$$ "$Z4H"/z4h.zsh || return
        fi

        . "$Z4H"/z4h.zsh || return

        setopt rcs
      '';
      profileExtra = ''
        [ -f ~/.profile ] && source ~/.profile

        export LANG='en_US.UTF-8'

        export GOPATH=''${HOME}/project/go
        export ANDROID_HOME=''${HOME}/Library/Android/Sdk
        export ANDROID_SDK_ROOT=$ANDROID_HOME

        export PATH="/usr/local/opt/ruby/bin:$PATH"

        export PATH=''${PATH}:~/scripts
        export PATH=''${PATH}:~/git-semantic-commits
        export PATH=''${PATH}:''${GOPATH}/bin
        export PATH=''${PATH}:"$(ruby -e 'puts Gem.user_dir')/bin"
        export PATH=''${PATH}:~/.local/share/bin
        export PATH="$PATH":"$HOME/.pub-cache/bin"

        export PATH="/usr/local/opt/gawk/libexec/gnubin:$PATH"

        # Ensure path arrays do not contain duplicates.
        typeset -gU cdpath fpath mailpath path

        # Set the default Less options.
        # Mouse-wheel scrolling has been disabled by -X (disable screen clearing).
        # Remove -X to enable it.
        export LESS='-g -i -M -R -S -w -X -z-4'

        ## bat https://github.com/sharkdp/bat
        export MANPAGER="sh -c 'col -bx | bat -l man -p'"
        export MANROFFOPT="-c"

        #
        # Temporary Files
        #

        if [[ ! -d "$TMPDIR" ]]; then
          export TMPDIR="$(mktemp -d)"
        fi

        TMPPREFIX="''${TMPDIR%/}/zsh"

        # Added by OrbStack: command-line tools and integration
        source ~/.orbstack/shell/init.zsh 2>/dev/null || :
      '';
      dirHashes = {
        docs = "$HOME/Documents";
        vids = "$HOME/Videos";
        dl = "$HOME/Downloads";
      };
      zsh-abbr = {
        enable = true;
        abbreviations = {
          "git a" = "git add";
          "git b" = "git branch";
          "git c" = "git commit";
          "git co" = "git checkout";
          "git d" = "git diff";
          "git f" = "git fetch";
          "git g" = "git grep";
          "git graph" = "git log -15 --branches --remotes --tags --graph --oneline --decorate=full HEAD";
          "git l" = "git log";
          "git last" = "git log -1 HEAD";
          "git m" = "git merge";
          "git p" = "git push";
          "git pr" = "git pull --rebase";
          "git r" = "git remote";
          "git rb" = "git rebase";
          "git rbc" = "git rebase --continue";
          "git rbs" = "git rebase --skip";
          "git st" = "git status";
          "git unadd" = "git reset HEAD";
          "git uncommit" = "git reset --soft HEAD~1";
          "git uncommit-hard" = "git reset --hard HEAD~1";
          "git unstage" = "git reset HEAD";
          "git w" = "git whatchanged";

          "kubectl" = "kubecolor";
        };
      };
      history = {
        append = true;
      };
    };

    direnv = {
      enable = true;
    };

    k9s = {
      enable = true;
    };

    mise = {
      enable = true;
    };

    ripgrep = {
      enable = true;
    };

    less = {
      enable = true;
    };

    lesspipe = {
      enable = true;
    };

    bat = {
      enable = true;
      config = {
        theme = "gruvbox-dark";
        italic-text = "always";
      };
    };

    atuin = {
      enable = true;
      settings = {
        enter_accept = true;
      };
    };

    lsd = {
      enable = true;
      settings = {
        sorting = {
          dir-grouping = "first";
        };
      };
    };

    fzf = {
      enable = true;
    };

    jujutsu = {
      enable = true;
      settings = {
        user = {
          name = "imcvampire";
          email = "nguyen@qa.id.vn";
        };
        signing = {
          behavior = "own";
          backend = "ssh";
          key = "~/.ssh/id_ed25519.pub";
        };
        ui = {
          "diff-formatter" = ["difft" "--color=always" "$left" "$right"];
        };
        revset-aliases = {
          "closest_bookmark(to)" = "heads(::to & bookmarks())";
        };
        colors = {
          wip = "yellow";
          todo = "blue";
          vibe = "cyan";
          mega = "red";
        };
        templates = {
          git_push_bookmark = "\"imcvampire/\" ++ change_id.short()";
        };
        template-aliases = {
          "format_short_change_id(id)" = "id.shortest(4)";
          "format_short_commit_id(id)" = "id.shortest(4)";
          prompt = ''
            separate(" ",
              format_short_change_id_with_hidden_and_divergent_info(self),
              format_short_commit_id(commit_id),
              if(empty, label("empty", "(empty)"), ""),
              if(description == "", label("description placeholder", "(no description)"), ""),
              if(description.contains("megamerge"), label("mega", "(mega)"), ""),
              if(description.starts_with("wip"), label("wip", "(wip)"), ""),
              if(description.starts_with("todo"), label("todo", "(todo)"), ""),
              if(description.starts_with("vibe"), label("vibe", "(vibe)"), ""),
              if(description.starts_with("mega"), label("mega", "(mega)"), ""),
              if(conflict, label("conflict", "(conflict)"), "")
            )
          '';
        };
      };
    };

    nix-index.enable = true;
  };

  editorconfig = {
    enable = true;
    settings = {
      "*" = {
        indent_style = "space";
        end_of_line = "lf";
        trim_trailing_whitespace = true;
        insert_final_newline = true;
        indent_size = 2;
      };

      "*.go" = {
        indent_style = "tab";
        indent_size = 4;
      };

      "*.{md,mdx}" = {
        trim_trailing_whitespace = false;
      };

      "*.{cmd,bat}" = {
        end_of_line = "crlf";
      };

      "Makefile" = {
        indent_style = "tab";
      };

      "*.{rs,py}" = {
        indent_size = 4;
      };
    };
  };
}
