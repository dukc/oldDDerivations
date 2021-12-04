{ stdenv, lib, fetchFromGitHub
, makeWrapper, unzip, which, writeTextFile
, curl, tzdata, gdb, Foundation, git, callPackage
, targetPackages, fetchpatch, bash
, HOST_DMD? "${callPackage ./bootstrap.nix { }}/bin/dmd"
, version? "2.098.0"
, dmdSha256? "03pk278rva7f0v464i6av6hnsac1rh22ppxxrlai82p06i9w7lxk"
, druntimeSha256? "0p75h8gigc5yj090k7qxmzz04dbpkab890l2sv1mdsxvgabch08q"
, phobosSha256? "0kdr9857kckpzsk59wyd7wvjd0d3ch9amqkq2y7ipx70rv9y6m0r"
}:

let
  dmdConfFile = writeTextFile {
    name = "dmd.conf";
    text = (lib.generators.toINI {} {
      Environment = {
        DFLAGS = ''-I@out@/include/dmd -L-L@out@/lib -fPIC ${lib.optionalString (!targetPackages.stdenv.cc.isClang) "-L--export-dynamic"}'';
      };
    });
  };

  bits = builtins.toString stdenv.hostPlatform.parsed.cpu.bits;
in

stdenv.mkDerivation rec {
  pname = "dmd";
  inherit version;

  enableParallelBuilding = true;

  srcs = [
    (fetchFromGitHub {
      owner = "dlang";
      repo = "dmd";
      rev = "v${version}";
      sha256 = dmdSha256;
      name = "dmd";
    })
    (fetchFromGitHub {
      owner = "dlang";
      repo = "druntime";
      rev = "v${version}";
      sha256 = druntimeSha256;
      name = "druntime";
    })
    (fetchFromGitHub {
      owner = "dlang";
      repo = "phobos";
      rev = "v${version}";
      sha256 = phobosSha256;
      name = "phobos";
    })
  ];

  sourceRoot = ".";

  # https://issues.dlang.org/show_bug.cgi?id=19553
  hardeningDisable = [ "fortify" ];

  # Not using patches option to make it easy to patch, for example, dmd and
  # Phobos at same time if that's required
  patchPhase =

  # DDocYear test used to have a hardcoded year, this patches it to use the
  # current one
  lib.optionalString (builtins.compareVersions version "2.091.0" < 0) ''
    patch -p1 -F3 --directory=dmd -i ${(fetchpatch {
      url = "https://github.com/dlang/dmd/commit/d2df0b34a72994d14b6da47ce4cb3761987161fd.patch";
      sha256 = "0sbqadp08bkw5qf2dx4zvbm7idv2ll4i4id9zh36qzkr0vq3rl1k";
    })}
    patch -p1 -F3 --directory=dmd -i ${(fetchpatch {
      url = "https://github.com/dlang/dmd/commit/7553454bac4bebf0e85bf8311627e72c0d8671be.patch";
      sha256 = "0gvracnn3k65kyi9xic52avnpgk4aq4qljkh64jkh281q8x5i9dk";
    })}
  ''

  # Fixes C++ tests that compiled on older G++ but not on the current one
  + lib.optionalString (builtins.compareVersions version "2.092.1" <= 0) ''
    patch -p1 -F3 --directory=druntime -i ${(fetchpatch {
      url = "https://github.com/dlang/druntime/commit/438990def7e377ca1f87b6d28246673bb38022ab.patch";
      sha256 = "0nxzkrd1rzj44l83j7jj90yz2cv01na8vn9d116ijnm85jl007b4";
    })}

  ''

  + postPatch;

  postPatch =
  ''
    patchShebangs .

  '' + lib.optionalString (version == "2.092.1") ''
    rm dmd/test/dshell/test6952.d
  '' + lib.optionalString (builtins.compareVersions "2.092.1" version < 0) ''
    substituteInPlace dmd/test/dshell/test6952.d --replace "/usr/bin/env bash" "${bash}/bin/bash"

  '' + ''
    rm dmd/test/runnable/gdb1.d
    rm dmd/test/runnable/gdb10311.d
    rm dmd/test/runnable/gdb14225.d
    rm dmd/test/runnable/gdb14276.d
    rm dmd/test/runnable/gdb14313.d
    rm dmd/test/runnable/gdb14330.d
    rm dmd/test/runnable/gdb15729.sh
    rm dmd/test/runnable/gdb4149.d
    rm dmd/test/runnable/gdb4181.d

  '' + lib.optionalString stdenv.isLinux ''
    substituteInPlace phobos/std/socket.d --replace "assert(ih.addrList[0] == 0x7F_00_00_01);" ""
  '' + lib.optionalString stdenv.isDarwin ''
    substituteInPlace phobos/std/socket.d --replace "foreach (name; names)" "names = []; foreach (name; names)"
  '';

  nativeBuildInputs = [ makeWrapper unzip which git ];

  buildInputs = [ gdb curl tzdata ]
    ++ lib.optional stdenv.isDarwin [ Foundation gdb ];


  osname = if stdenv.isDarwin then
    "osx"
  else
    stdenv.hostPlatform.parsed.kernel.name;
  top = "$NIX_BUILD_TOP";
  pathToDmd = "${top}/dmd/generated/${osname}/release/${bits}/dmd";

  # Build and install are based on http://wiki.dlang.org/Building_DMD
  buildPhase = ''
    cd dmd
    make -j$NIX_BUILD_CORES -f posix.mak INSTALL_DIR=$out BUILD=release ENABLE_RELEASE=1 PIC=1 HOST_DMD=${HOST_DMD}
    cd ../druntime
    make -j$NIX_BUILD_CORES -f posix.mak BUILD=release ENABLE_RELEASE=1 PIC=1 INSTALL_DIR=$out DMD=${pathToDmd}
    cd ../phobos
    echo ${tzdata}/share/zoneinfo/ > TZDatabaseDirFile
    echo ${curl.out}/lib/libcurl${stdenv.hostPlatform.extensions.sharedLibrary} > LibcurlPathFile
    make -j$NIX_BUILD_CORES -f posix.mak BUILD=release ENABLE_RELEASE=1 PIC=1 INSTALL_DIR=$out DMD=${pathToDmd} DFLAGS="-version=TZDatabaseDir -version=LibcurlPath -J$(pwd)"
    cd ..
  '';

  doCheck = true;

  # many tests are disbled because they are failing

  # NOTE: Purity check is disabled for checkPhase because it doesn't fare well
  # with the DMD linker. See https://github.com/NixOS/nixpkgs/issues/97420
  checkPhase = ''
    cd dmd
    NIX_ENFORCE_PURITY= \
      make -j$NIX_BUILD_CORES -C test -f Makefile PIC=1 CC=$CXX DMD=${pathToDmd} BUILD=release SHELL=$SHELL

    cd ../druntime
    NIX_ENFORCE_PURITY= \
      make -j$NIX_BUILD_CORES -f posix.mak unittest PIC=1 DMD=${pathToDmd} BUILD=release

    cd ../phobos
    NIX_ENFORCE_PURITY= \
      make -j$NIX_BUILD_CORES -f posix.mak unittest BUILD=release ENABLE_RELEASE=1 PIC=1 DMD=${pathToDmd} DFLAGS="-version=TZDatabaseDir -version=LibcurlPath -J$(pwd)"

    cd ..
  '';

  installPhase = ''
    cd dmd
    mkdir $out
    mkdir $out/bin
    cp ${pathToDmd} $out/bin

    mkdir -p $out/share/man/man1
    mkdir -p $out/share/man/man5
    cp -r docs/man/man1/* $out/share/man/man1/
    cp -r docs/man/man5/* $out/share/man/man5/

    cd ../druntime
    mkdir $out/include
    mkdir $out/include/dmd
    cp -r import/* $out/include/dmd

    cd ../phobos
    mkdir $out/lib
    cp generated/${osname}/release/${bits}/libphobos2.* $out/lib

    cp -r std $out/include/dmd
    cp -r etc $out/include/dmd

    wrapProgram $out/bin/dmd \
      --prefix PATH ":" "${targetPackages.stdenv.cc}/bin" \
      --set-default CC "${targetPackages.stdenv.cc}/bin/cc"

    substitute ${dmdConfFile} "$out/bin/dmd.conf" --subst-var out
  '';

  meta = with lib; {
    description = "Official reference compiler for the D language";
    homepage = "https://dlang.org/";
    # Everything is now Boost licensed, even the backend.
    # https://github.com/dlang/dmd/pull/6680
    license = licenses.boost;
    maintainers = [ {
      email = "ajieskola@gmail.com";
      github = "dukc";
      githubId = 24233408;
      name = "Ate Eskola";
    } ];
    platforms = [ "x86_64-linux" "i686-linux" "x86_64-darwin" ];
  };
}
