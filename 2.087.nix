args @ { callPackage, ...}: callPackage ./default.nix ({
  version = "2.087.1";
  dmdSha256 = "19x5qnjfx13qzl4s99sm5db88i3n95g1rrnf9aq1svvkzfr4jl0y";
  druntimeSha256 = "0plbrvkxhxmqm8qfvq8fwpy9f268lfg0l6w40a4sj0186a5gpqa4";
  phobosSha256 = "0mfcngp85s24rd520cv02zyyfwcww1dvmsbb2a3cldv7kas0gsk1";
} // args)
