{
  lib,
  buildNpmPackage,
  fetchFromGitHub,
  stdenv,
  autoPatchelfHook,
  SDL2,
  libuv,
  lz4,
  #tests
  testers,
  runCommand,
  igir,
  nodejs,
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

  npmDepsHash = "sha256-miXxMBtIqgxS4Ulhkq79VDCkBjDjoB8juPoDWE1UQUM=";

  # This patch is only needed for 3.0.1 and needs to be removed afterwards
  # along with the patch file itself
  patches = [ ./0001-update-dependencies.patch ];

  # I have no clue why I have to do this
  postPatch = ''
    patchShebangs scripts/update-readme-help.sh
  '';

  buildInputs = [
    (lib.getLib stdenv.cc.cc)
    SDL2
    libuv
    lz4
  ];

  nativeBuildInputs = lib.optionals stdenv.hostPlatform.isLinux [ autoPatchelfHook ];

  postFixup = lib.optionalString stdenv.hostPlatform.isDarwin ''
    # Fix chdman
    find $out/lib/node_modules/igir/node_modules/@emmercm/ -name chdman -executable -type f \
      -exec install_name_tool -change /opt/homebrew/opt/sdl2/lib/libSDL2-2.0.0.dylib ${SDL2}/lib/libSDL2-2.0.0.dylib {} \;

    # Fix maxcso
    find $out/lib/node_modules/igir/node_modules/@emmercm/ -name maxcso -executable -type f \
      -exec install_name_tool -change /opt/homebrew/opt/libuv/lib/libuv.1.dylib ${libuv}/lib/libuv.1.dylib {} \;
    find $out/lib/node_modules/igir/node_modules/@emmercm/ -name maxcso -executable -type f \
      -exec install_name_tool -change /opt/homebrew/opt/lz4/lib/liblz4.1.dylib ${lz4.lib}/lib/liblz4.1.dylib {} \;
  '';

  passthru.tests =
    let
      igirDir = "${igir}/lib/node_modules/igir";
      npxCmd = "${nodejs}/bin/npx";
    in
    {
      chdman = runCommand "${pname}-chdman" { meta.timeout = 30; } ''
        set +e
        cd ${igirDir}
        ${npxCmd} chdman > $out
        grep -q "chdman - MAME Compressed Hunks of Data (CHD) manager" $out
      '';

      maxcso = runCommand "${pname}-maxcso" { meta.timeout = 30; } ''
        set +e
        cd ${igirDir}
        ${npxCmd} maxcso 2> $out
        grep -q "maxcso v1.13.0" $out
      '';

      # maxcso = testers.testVersion {
      #   package = igir;
      #   command = "${npxCmd} maxcso";
      #   version = "v1.13.0";
      # };
    };

  meta = {
    description = "Video game ROM collection manager to help filter, sort, patch, archive, and report on collections on any OS";
    mainProgram = "igir";
    homepage = "https://igir.io";
    changelog = "https://github.com/emmercm/igir/releases/tag/${src.rev}";
    license = lib.licenses.gpl3Plus;
    maintainers = with lib.maintainers; [ docbobo ];
    platforms = with lib.platforms; linux ++ darwin;
  };
}
