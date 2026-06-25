{
  config,
  pkgs,
  inputs,
  system,
  lib,
  ...
}: {
  home.enableNixpkgsReleaseCheck = false;

  home.stateVersion = "23.05";

  home.packages = with pkgs; [
    cachix
    nix-prefetch-git

    bash
    zsh
    coreutils
    gettext
    gawk

    docker

    pgcli

    # devenv
    just
    tealdeer
    mosh

    xan

    kubecolor

    # firebase-tools
    flyctl

    # ansible

    localsend
    yubikey-manager
    # super-productivity
    mouser

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
    gh
    rtk

    # (pkgs.google-cloud-sdk.withExtraComponents [
    #   pkgs.google-cloud-sdk.components.gke-gcloud-auth-plugin
    # ])

    beads

    zotero

    monaspace
    atkinson-hyperlegible-next
    nerd-fonts.symbols-only
  ]
  # Linux has no system C compiler; pull in nix stdenv.cc.
  # Darwin uses the system Apple clang (/usr/bin/clang), so skip it there.
  ++ lib.optional pkgs.stdenv.isLinux pkgs.stdenv.cc;

  home.sessionVariables = {
    EDITOR = "nvim";
    VISUAL = "nvim";
    PAGER = "less";
    SHELL = "zsh";
  };

  programs = {
    home-manager = {
      enable = true;
    };

    zsh = {
      enable = true;
      enableCompletion = true;
      enableVteIntegration = true;
      autosuggestion.enable = true;

      plugins = [
        {
          name = "zsh-autopair";
          src = pkgs.zsh-autopair;
          file = "share/zsh/zsh-autopair/autopair.zsh";
        }
        {
          name = "safe-paste";
          src = pkgs.fetchFromGitHub {
            owner = "oz";
            repo = "safe-paste";
          };
          file = "safe-paste.plugin.zsh";
        }
        {
          name = "zsh-titles";
          src = pkgs.fetchFromGitHub {
            owner = "jreese";
            repo = "zsh-titles";
          };
          file = "titles.plugin.zsh";
        }
      ];

      initContent = lib.mkMerge [
        # Runs before compinit (order 570) so brew completions land in $fpath.
        (lib.mkOrder 560 ''
          case `uname` in
            Darwin)
              if type brew &>/dev/null; then
                fpath+=($(brew --prefix)/share/zsh/site-functions)
              fi
            ;;
          esac
        '')

        # Must load after compinit (570) and before zsh-autosuggestions (700). fzf's own zsh
        # integration (order 910) then keeps fzf-tab as its fallback completion,
        # so plain TAB uses fzf-tab while `**<TAB>` keeps fzf's file/dir trigger.
        (lib.mkOrder 600 ''
          source ${pkgs.zsh-fzf-tab}/share/fzf-tab/fzf-tab.plugin.zsh
          fzf_default_completion=fzf-tab-complete
        '')

        # Main interactive config (runs after compinit).
        ''
          # Extend PATH for interactive shells.
          path=(~/bin ~/scripts ~/git-semantic-commits $path)

          # Export environment variables.
          export GPG_TTY=$TTY

          # Source additional local files if they exist.
          [[ -f ~/.env.zsh ]] && source ~/.env.zsh

          # Right Arrow accepts the whole autosuggestion (zsh-autosuggestions
          # default). Ctrl+/ undoes the last command-line change (zle builtin).
          bindkey '^_' undo

          # Autoload functions.
          autoload -Uz zmv

          # Define functions and completions.
          function md() { [[ $# == 1 ]] && mkdir -p -- "$1" && cd -- "$1" }
          compdef _directories md

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

          eval "$(jump shell)"

          compdef kubecolor=kubectl

          # ---- Completion styling ----
          # Populate LS_COLORS so completion / fzf-tab can colorize entries.
          (( $+commands[dircolors] )) && eval "$(dircolors -b)"

          # General completion behaviour.
          zstyle ':completion:*'        matcher-list      'm:{a-z}={A-Z}'
          zstyle ':completion:*'        list-colors       "''${(@s.:.)LS_COLORS}"
          zstyle ':completion:*'        verbose           true
          zstyle ':completion:*'        squeeze-slashes   true
          zstyle ':completion:*'        single-ignored    show
          zstyle ':completion:*:functions' ignored-patterns '-*|_*'
          zstyle ':completion:*:rm:*'   ignore-line       other
          zstyle ':completion:*:kill:*' ignore-line       other
          zstyle ':completion:*:diff:*' ignore-line       other
          zstyle ':completion:*:rm:*'   file-patterns     '*:all-files'
          zstyle ':completion:*:paths'  accept-exact-dirs true
          zstyle ':completion:*:-subscript-:*' tag-order  'indexes parameters'
          zstyle ':completion:*:-tilde-:*'     tag-order  'directory-stack' 'named-directories' 'users'

          # Cache completion results.
          zstyle ':completion:*' use-cache  true
          zstyle ':completion:*' cache-path "''${XDG_CACHE_HOME:-$HOME/.cache}/zsh/zcompcache"
          [[ -d "''${XDG_CACHE_HOME:-$HOME/.cache}/zsh/zcompcache" ]] || \
            mkdir -p "''${XDG_CACHE_HOME:-$HOME/.cache}/zsh/zcompcache"

          # Hide noisy git refs.
          zstyle ':completion:*:git-*:argument-rest:heads'           ignored-patterns '(FETCH_|ORIG_|*/|)HEAD'
          zstyle ':completion:*:git-*:argument-rest:heads-local'     ignored-patterns '(FETCH_|ORIG_|)HEAD'
          zstyle ':completion:*:git-*:argument-rest:heads-remote'    ignored-patterns '*/HEAD'
          zstyle ':completion:*:git-*:argument-rest:commits'         ignored-patterns '*'
          zstyle ':completion:*:git-*:argument-rest:commit-objects'  ignored-patterns '*'
          zstyle ':completion:*:git-*:argument-rest:recent-branches' ignored-patterns '*'

          # ---- fzf-tab tuning ----
          # Disable the native zsh menu so fzf-tab can capture candidates.
          zstyle ':completion:*' menu no
          # Group support: show a header per completion group.
          zstyle ':completion:*:descriptions' format '[%d]'
          # Don't pre-sort `git checkout` refs.
          zstyle ':completion:*:git-checkout:*' sort false
          # Preview directory contents (lsd) when completing `cd`.
          zstyle ':fzf-tab:complete:cd:*' fzf-preview 'lsd -1 --color=always --icon=always $realpath'
          # Switch completion groups with < and >.
          zstyle ':fzf-tab:*' switch-group '<' '>'
        ''

        # fast-syntax-highlighting (zdharma-continuum/fast-syntax-highlighting)
        # must be sourced last so it wraps every other ZLE widget. Replaces the
        # highlighter z4h bundled.
        (lib.mkOrder 1250 ''
          source ${pkgs.zsh-fast-syntax-highlighting}/share/zsh/plugins/fast-syntax-highlighting/fast-syntax-highlighting.plugin.zsh
        '')
      ];

      envExtra = ''
        ${lib.optionalString pkgs.stdenv.isDarwin "export SSH_SK_PROVIDER=/usr/local/lib/sk-libfido2.dylib"}
        ABBR_SET_EXPANSION_CURSOR=1
      '';

      profileExtra = ''
        [ -f ~/.profile ] && source ~/.profile

        export LANG='en_US.UTF-8'

        export GOPATH=''${HOME}/project/go
        export ANDROID_HOME=''${HOME}/Library/Android/Sdk
        export ANDROID_SDK_ROOT=$ANDROID_HOME
        export NPM_CONFIG_PREFIX=''${HOME}/.npm-global

        export PATH="/usr/local/opt/ruby/bin:$PATH"
        export PATH=''${PATH}:~/scripts
        export PATH=''${PATH}:~/git-semantic-commits
        export PATH=''${PATH}:''${GOPATH}/bin
        export PATH=''${PATH}:"$(ruby -e 'puts Gem.user_dir')/bin"
        export PATH=''${PATH}:~/.local/share/bin
        export PATH="$PATH":"$HOME/.pub-cache/bin"
        export PATH=''${PATH}:''${NPM_CONFIG_PREFIX}/bin

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

    starship = {
      enable = true;
      enableZshIntegration = true;
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

    codex = {
      enable = true;
    };

    claude-code = {
      enable = true;
    };

    vscode = {
      enable = true;
    };

    nix-index.enable = true;
  };

  home.activation.claudeSetup = lib.hm.dag.entryAfter ["writeBoundary"] ''
    export PATH="${config.home.profileDirectory}/bin:$PATH"
    $DRY_RUN_CMD bash ${../bootstrap/claude-setup.sh} || true
  '';

  home.activation.codexSetup = lib.hm.dag.entryAfter ["writeBoundary"] ''
    export PATH="${config.home.profileDirectory}/bin:$PATH"
    $DRY_RUN_CMD bash ${../bootstrap/codex-setup.sh} || true
  '';

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
