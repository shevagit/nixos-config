{ pkgs, ... }:{
  home.packages = with pkgs; [
    (google-cloud-sdk.withExtraComponents [google-cloud-sdk.components.gke-gcloud-auth-plugin])
    helmfile
    kubectl
    kubectx
    kubernetes-helm
    stern
    kubie
  ];
}