{ lib, buildNpmPackage, fetchFromGitHub,

stdenv, }:

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

  dontPatchELF = true;
  buildInputs = [ (lib.getLib stdenv.cc.cc) ];

  meta = with lib; {
    description =
      "Video game ROM collection manager to help filter, sort, patch, archive, and report on collections on any OS";
    mainProgram = "igir";
    homepage = "https://igir.io";
    changelog = "https://github.com/emmercm/igir/releases/tag/${src.rev}";
    license = licenses.gpl3Plus;
    maintainers = with maintainers; [ ];
    platforms = platforms.linux ++ platforms.darwin;
  };
}
