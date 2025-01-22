{pkgs, ...}: {
  home.packages = with pkgs; [
    docker-buildx
    docker-compose
    docker-ls
  ];
}