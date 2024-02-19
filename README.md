[Nix](https://nixos.org) derivations for DMD [D compiler](https://dlang.org). Based on the
[official derivation on NixPkgs](https://github.com/nixos/nixpkgs/tree/master/pkgs/development/compilers/dmd),
but with an ability to choose an older DMD instead. You might want to use this if
you have some outdated D code, and you want to use Nix but don't want to spend
time backporting the D compiler derivation yourself.

These derivations will also try to be compatible with both the latest NixOS and
Unstable channels, so you might also want to use these if you want an up-to-date
DMD without having to subscribe to the unstable channel for just that.

*NOTE*: This project has almost entirely been merged to and superseded by [dlang-nix](https://github.com/petarkirov/dlang-nix), which I'm now developing instead of this. Unlike this project dlang-nix has support for Nix flakes, CI environment, dub and LDC derivations, and more. As of writing, if you need versions 2.084, 2.087 or 2.088 you'll still need these but otherwise I recommend dlang-nix instead.

To build:
```bash
nix-build -E 'with import <nixpkgs> {}; callPackage ./default.nix {inherit (darwin.apple_sdk.frameworks) Foundation;}'
```

or to install to your default environment:
```bash
nix-env -iE  'f: with import <nixpkgs> {}; callPackage ./default.nix {inherit (darwin.apple_sdk.frameworks) Foundation;}'
```

Replace `<nixpkgs>` with the channel you wish to use, and `./default.nix` with
any of the version number filenames if you wish to compile an older DMD version. If
you're not on Darwin, you can replace `inherit (darwin.apple_sdk.frameworks) Foundation;`
with `Foundation=null;`

The aim is to support the last patch version of minor DMD versions divisable by four,
plus the latest stable. For a reasonable timeframe - the intention is not to support
everything back to 2.00. Minor versions that are not divisable by 4 are accepted
and kept, but no effort is made to support all of them. Former non-divisable
minor versions will also be of secondary importance when testing and fixing any
possible breakage.

I currently test only on NixOS, and I'm not an experienced packager, so mistakes are
likely. Issue reports and patches welcome!

MIT License carried over from NixPkgs with no additional conditions from me.
