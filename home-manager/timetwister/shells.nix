{ ... }:

{
  # Set alias for `ls` in `bash` to be `ls -p` by default
  programs.bash.shellAliases = {
    ls = "ls -p";
  };
}
