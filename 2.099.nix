args @ { callPackage, ...}: callPackage ./default.nix ({
  version = "2.099.0";
  dmdSha256 = "1zmndllp6mb4dyjarwjd2f9h35m0pig8mjcdji4wyvpx5818kd2a";
  druntimeSha256 = "1h07szrz0b3grfsfqx29hbnh017hncbjkimwa05218y5sx1yd8zj";
  phobosSha256 = "1w3zab9b1das0kk2lnx3d1jayhj0dqnilik84chsna22yyxnqc84";
} // args)
