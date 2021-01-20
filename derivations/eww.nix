{ rustPlatform, lib, fetchFromGitHub, rust, gtk3, cairo, glib, pkg-config }:

rustPlatform.buildRustPackage rec {
  pname = "eww";
  version = "master";

  src = fetchFromGitHub {
    owner = "elkowar";
    repo = pname;
    rev = version;
    sha256 = "sha256-QlFHqQaUaG/2sSfObOkuXVBJk45tLxEJS70LTqs7VHY=";
  };

  nativeBuildInputs = [ rust pkg-config ];
  buildInputs = [ gtk3 cairo glib ];
  
  checkPhase = null;
  cargoSha256 = "sha256-I/oEDh2anNyI9qm9bpkgcWAKV3rNgob4nJNZskVLnk4=";

  meta = with lib; {
    description =
      "A standalone widget system made in Rust to add AwesomeWM like widgets to any WM";
    homepage = "https://github.com/elkowar/eww";
    licenses = licenses.mit;
    maintainers = with maintainers; [ fortuneteller2k ];
  };
}
