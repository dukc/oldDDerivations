args @ { callPackage, ...}: callPackage ./default.nix ({
  version = "2.092.1";
  dmdSha256 = "1x4fspsk91cdf3pc3sfhhk47511acdbwd458wai2sirkqsdypmnm";
  druntimeSha256 = "0rmqlnw1jlgsh6jjvw6bbmyn26v0xnygqdny699y93g0jldasas4";
  phobosSha256 = "0mw4bad9af7z54dc2rs1aa9h63p3z6bf0fq14v2iyyq4y08ikxzc";
} // args)
