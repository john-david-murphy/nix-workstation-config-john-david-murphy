let
  username = "example";
in {
  inherit username;

  configurationName = "example-aarch64-darwin";
  darwinUid = 501;
  developmentDirectory = "/Users/${username}/work";
  email = "john@onechronos.com";
  fullName = "John Murphy";
  gitContributor = "john-david-murphy";
  homeDirectory = "/Users/${username}";
  homeStateVersion = "26.05";
}
