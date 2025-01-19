{
  programs.git = {
    enable = true;
    userName = "andreas sheva";
    userEmail = "shevaneo@gmail.com";
    aliases = {
      retag = "!f() { git tag -f -a \"$1\" -m \"$1\" && git push origin \"$1\" -f; }; f";
      deltag = "!f() { git tag -d \"$1\" && git push --delete origin \"$1\"; }; f";
    };
    extraConfig = {
      init = {
        defaultBranch = "main";
      };
    };
  };
}