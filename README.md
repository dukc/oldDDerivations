[Nix](https://nixos.org) derivation for DMD [D compiler](https://dlang.org). Based on the
[official derivation on NixPkgs](https://github.com/nixos/nixpkgs/tree/master/pkgs/development/compilers/dmd),
but with an ability to choose an older DMD instead. You might want to use this if
you have some outdated D code, and you want to use Nix but don't want to spend
time backporting the D compiler derivation yourself.

To build:
```bash
nix-build -E 'with import <nixpkgs> {}; callPackage ./default.nix {inherit (darwin.apple_sdk.frameworks) Foundation;}'
```
Replace `<nixpkgs>` with the channel you wish to use, and `./default.nix` with
any of the version number filenames if you wish to compile an older DMD version. If
you're not on Darwin, you can replace `inherit (darwin.apple_sdk.frameworks) Foundation;`
with `Foundation=null;`

The aim is to support the last patch version of minor DMD version divisable by four,
plus the latest stable. Minor versions that are not divisable by 4 are accepted
and kept, but no effort is made to support all of them, or port them to latest
patch version.

I currently test only on NixOs, and I'm not an experienced packager, so mistakes are
likely. Patches welcome!

MIT License carried over from NixPkgs with no additional conditions from me.
