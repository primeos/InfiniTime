with import <nixpkgs> {};

let
  nRF-SDK = fetchzip {
    url = "https://developer.nordicsemi.com/nRF5_SDK/nRF5_SDK_v15.x.x/nRF5_SDK_15.3.0_59ac345.zip";
    sha256 = "0kwgafa51idn0cavh78zgakb02xy49vzag7firv9rgqmk1pa3yd5";
  };
  gcc-arm-none-eabi-bin = stdenv.mkDerivation {
    # https://developer.arm.com/tools-and-software/open-source-software/developer-tools/gnu-toolchain/gnu-rm/downloads/9-2020-q2-update
    # Nixpkgs: gcc-arm-embedded and pkgsCross.arm-embedded.buildPackages.gcc

    pname = "gcc-arm-none-eabi";
    version = "0"; # TODO

    # TODO: Build form source
    src = fetchzip {
      url = "https://developer.arm.com/-/media/Files/downloads/gnu-rm/9-2020q2/gcc-arm-none-eabi-9-2020-q2-update-x86_64-linux.tar.bz2?revision=05382cca-1721-44e1-ae19-1e7c3dc96118&la=en&hash=D7C9D18FCA2DD9F894FD9F3C3DC9228498FA281A";
      sha256 = "1v5np0jii6l0i18nqclwfvik9cvx3nac2qnc3vjzz9q9cya0fh2b";
    };

    nativeBuildInputs = [
      autoPatchelfHook
    ];

    buildInputs = [
      ncurses5
      python
      stdenv.cc.cc.lib
    ];

    installPhase = ''
      mkdir $out
      mv * $out
    '';
  };
in stdenv.mkDerivation {
  # https://github.com/JF002/InfiniTime/blob/develop/doc/buildAndProgram.md

  pname = "InfiniTime";
  version = "1.2.0"; # TODO

  src = ./.;

  postPatch = ''
    patchShebangs tools/mcuboot/
  '';

  nativeBuildInputs = [
    cmake
    (python3.withPackages(ps: with ps; [ click cryptography cbor intelhex ]))
  ];

  cmakeFlags = [
    "-DARM_NONE_EABI_TOOLCHAIN_PATH=${gcc-arm-none-eabi-bin}"
    "-DNRF5_SDK_PATH=${nRF-SDK}"
    "-DNRFJPROG=/dev/null"
  ];

  installPhase = ''
    mkdir $out
    mv src/* $out/
  '';
}
