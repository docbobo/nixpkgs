{
  lib,
  buildNpmPackage,
  fetchFromGitHub,
  stdenv,
  SDL2,
}:
buildNpmPackage rec {
  pname = "igir";
  version = "3.0.1";

  src = fetchFromGitHub {
    owner = "emmercm";
    repo = "igir";
    rev = "v${version}";
    hash = "sha256-QPUnvirufY3UiSFVxX3xCmpAlzPKg5JxwAnVefdepqU=";
  };

  npmDepsHash = "sha256-hJzgFWUJnEQu+EGD4itv04IQl7Rwm8CYeFELJ9aoTMY=";

  # I have no clue why I have to do this
  postPatch = ''
    patchShebangs scripts/update-readme-help.sh
  '';

  buildInputs = [
    (lib.getLib stdenv.cc.cc)
    SDL2
  ];

  dontPatchELF = true;

  meta = {
    description = "Video game ROM collection manager to help filter, sort, patch, archive, and report on collections on any OS";
    mainProgram = "igir";
    homepage = "https://igir.io";
    changelog = "https://github.com/emmercm/igir/releases/tag/${src.rev}";
    license = lib.licenses.gpl3Plus;
    maintainers = with lib.maintainers; [ ];
    platforms = with lib.platforms; linux ++ darwin;
  };
}
