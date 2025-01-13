{
  lib,
  fetchFromGitHub,
  buildGoModule,
}:

buildGoModule rec {
  pname = "gh-slack";
  version = "0.0.31";

  src = fetchFromGitHub {
    owner = "rneatherway";
    repo = pname;
    rev = "${version}";
    hash = "sha256-h5WrCvNzC75+RXnO5rItiDOETo9BNyyBsD3NJt620Ls=";
  };

  vendorHash = "sha256-0S9TIfySnytfmG8z+bqc+EBzduniP830lDmEG095q7w=";

  ldflags = [
    "-s"
    "-w"
    "-X main.Version=${version}"
  ];

  meta = with lib; {
    homepage = "https://github.com/rneatherway/gh-slack";
    description = "Utility for archiving a slack conversation as markdown";
    license = licenses.mit;
    maintainers = with maintainers; [ docbobo ];
    mainProgram = "gh-slack";
  };
}
