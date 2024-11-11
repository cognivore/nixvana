{ pkgs, lib, ... }:
let
  inherit (lib) mkDefault;
in
{
  home.packages = [
    pkgs.fd
    pkgs.autocutsel
    pkgs.xorg.xinput
  ];

  # We use dumber bash for `mc` prompt not to glith due to starship
  programs.bash.enable = true;
  programs.bash.enableCompletion = true;
  programs.bash.bashrcExtra = ''
  # Provide a nice prompt if the terminal supports it.
  if [ "$TERM" != "dumb" ] || [ -n "$INSIDE_EMACS" ]; then
    PROMPT_COLOR="1;31m"
    ((UID)) && PROMPT_COLOR="1;32m"
    if [ -n "$INSIDE_EMACS" ]; then
      # Emacs term mode doesn't support xterm title escape sequence (\e]0;)
      PS1="\n\[\033[$PROMPT_COLOR\][\u@\h:\w]\\$\[\033[0m\] "
    else
      PS1="\n\[\033[$PROMPT_COLOR\][\[\e]0;\u@\h: \w\a\]\u@\h:\w]\\$\[\033[0m\] "
    fi
    if test "$TERM" = "xterm"; then
      PS1="\[\033]2;\h:\u:\w\007\]$PS1"
    fi
  fi
  '';

  programs.fzf = {
    enable = true;
    enableBashIntegration = true;
    enableZshIntegration = true;
  };

  programs.starship.enableBashIntegration = false;
  programs.starship.settings = {
    aws.symbol = mkDefault " ";
    battery.full_symbol = mkDefault "";
    battery.charging_symbol = mkDefault "";
    battery.discharging_symbol = mkDefault "";
    battery.unknown_symbol = mkDefault "";
    battery.empty_symbol = mkDefault "";
    cmake.symbol = mkDefault "△ ";
    conda.symbol = mkDefault " ";
    crystal.symbol = mkDefault " ";
    dart.symbol = mkDefault " ";
    docker_context.symbol = mkDefault " ";
    dotnet.symbol = mkDefault " ";
    elixir.symbol = mkDefault " ";
    elm.symbol = mkDefault " ";
    erlang.symbol = mkDefault " ";
    git_branch.symbol = mkDefault " ";
    git_commit.tag_symbol = mkDefault " ";
    git_status.format = mkDefault "([$all_status$ahead_behind]($style) )";
    git_status.conflicted = mkDefault " ";
    git_status.ahead = mkDefault " ";
    git_status.behind = mkDefault " ";
    git_status.diverged = mkDefault " ";
    git_status.untracked = mkDefault " ";
    git_status.stashed = mkDefault " ";
    git_status.modified = mkDefault " ";
    git_status.staged = mkDefault " ";
    git_status.renamed = mkDefault " ";
    git_status.deleted = mkDefault " ";
    golang.symbol = mkDefault " ";
    helm.symbol = mkDefault "⎈ ";
    hg_branch.symbol = mkDefault " ";
    java.symbol = mkDefault " ";
    julia.symbol = mkDefault " ";
    kotlin.symbol = mkDefault " ";
    kubernetes.symbol = mkDefault "☸ ";
    lua.symbol = mkDefault " ";
    nim.symbol = mkDefault " ";
    nix_shell.symbol = mkDefault " ";
    nodejs.symbol = mkDefault " ";
    openstack.symbol = mkDefault " ";
    package.symbol = mkDefault " ";
    perl.symbol = mkDefault " ";
    php.symbol = mkDefault " ";
    purescript.symbol = mkDefault "<≡> ";
    python.symbol = mkDefault " ";
    ruby.symbol = mkDefault " ";
    rust.symbol = mkDefault " ";
    status.symbol = mkDefault " ";
    status.not_executable_symbol = mkDefault " ";
    status.not_found_symbol = mkDefault " ";
    status.sigint_symbol = mkDefault " ";
    status.signal_symbol = mkDefault " ";
    swift.symbol = mkDefault " ";
    terraform.symbol = mkDefault "𝗧 ";
    vagrant.symbol = mkDefault "𝗩 ";
    zig.symbol = mkDefault " ";
  };

  # Starship Prompt
  # https://rycee.gitlab.io/home-manager/options.html#opt-programs.starship.enable
  programs.starship.enable = true;

  programs.starship.settings = {
    # See docs here: https://starship.rs/config/
    # Symbols config configured ./starship-symbols.nix.

    # TODO: Move symbols to another file
    directory.read_only = mkDefault " ";
    directory.fish_style_pwd_dir_length = 1; # turn on fish directory truncation
    directory.truncation_length = 2; # number of directories not to truncate

    # TODO: Move symbols to another file
    gcloud.symbol = mkDefault " ";
    gcloud.disabled = true; # annoying to always have on

    hostname.style = "bold green"; # don't like the default

    # TODO: Move symbols to another file
    memory_usage.symbol = mkDefault " ";
    memory_usage.disabled = true; # because it includes cached memory it's reported as full a lot

    # TODO: Move symbols to another file
    shlvl.symbol = mkDefault " ";
    shlvl.disabled = false;

    username.style_user = "bold blue"; # don't like the default
  };

  programs.zsh = {
    enable = true;
    enableCompletion = true;
    autosuggestion.enable = true;
    syntaxHighlighting = {enable = false;};
    oh-my-zsh = {
      enable = true;
      plugins = ["docker-compose" "docker" "git" "tmux" "fzf"];
      theme = "dst";
    };
    shellAliases = {
      mc = ''
           bash -c "SHELL=/home/sweater/.nix-profile/bin/bash mc"
      '';
    };
    sessionVariables = { ZSH_THEME = "spaceship"; };
    initExtra = ''
      source ${pkgs.zsh-vi-mode}/share/zsh-vi-mode/zsh-vi-mode.plugin.zsh;
      bindkey '^f' autosuggest-accept;
      bindkey -v

      # Dumb
      if [[ "$TERM" == "dumb" ]]
      then
        unsetopt zle
        unsetopt prompt_cr
        unsetopt prompt_subst
        if whence -w precmd >/dev/null; then
            unfunction precmd
        fi
        if whence -w preexec >/dev/null; then
            unfunction preexec
        fi
        PS1='$ '
      fi
    '';
  };

  programs.ripgrep.enable = true;
}
