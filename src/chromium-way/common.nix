{
    info ? {version = "1.0.0"; src = https://example.org/;},

    product ? "chromium-way",
    channel ? "stable",

    pulseSupport ? true,
    cupsSupport ? true,
    commandLineArgs ? "",
}:

pkgs:

let
    llvm = with pkgs.llvmPackages; {
        unC = clang-unwrapped;
        wpC = clang;
    };
    deps = with pkgs; [
        # Tooling
        yasm bison gperf kerberos icu re2 libgcrypt
        # Networking
        libnss kerberos
        # Compression
        bzip2 zlib snappy zlib minizip
        # Audio
        libpulseaudio alsaLib flac opusWithCustomModes speex
        # Graphics
        libpng libjpeg libwebp ffmpeg
        # Data
        xdg_utils libxslt libxml2
        # Interface
        dbus
        # Hardware
        libpci libcap libusb1 cups
    ];
    suffix = if channel == "stable" then "" else "-${channel}";
    meta = import ./metadata.nix pkgs;
in {
    ozone = rec {
        name = product + suffix + "-" + version;
        inherit meta;

        inherit (info) src version;
        inherit (pkgs) fish;
        builder = builtins.toFile "builder.sh" ''
            #!$fish
            source $stdenv/setup

            source <(echo $configurePhase)
            source <(echo $buildPhase)
        '';
        configurePhase = ''
            python tools/gn/bootstrap/bootstrap.py -v -s --no-clean
            set -x PATH $PWD/out/Release $PATH
        '';
        buildPhase = ''
        '';
        nativeBuildInputs = with pkgs // pkgs.python2Packages; [
            ninja which python perl pkgconfig ply jinja2 nodejs gnutar
        ];
    };
}
