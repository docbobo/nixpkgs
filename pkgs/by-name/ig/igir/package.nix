{
  lib,
  buildNpmPackage,
  fetchFromGitHub,
  stdenv,
  autoPatchelfHook,
  SDL2,
  libuv,
  lz4,
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

  buildInputs =
    [
      (lib.getLib stdenv.cc.cc)
      SDL2
    ]
    ++ lib.optionals stdenv.hostPlatform.isLinux [
      libuv
      lz4
    ];

  nativeBuildInputs = lib.optionals stdenv.hostPlatform.isLinux [ autoPatchelfHook ];

  postFixup = lib.optionalString stdenv.hostPlatform.isDarwin ''
    find $out/lib/node_modules/igir/node_modules/@emmercm/ -name chdman -executable -type f \
      -exec install_name_tool -change /opt/homebrew/opt/sdl2/lib/libSDL2-2.0.0.dylib ${SDL2}/lib/libSDL2-2.0.0.dylib {} \;
  '';

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
