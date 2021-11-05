args @ { callPackage, ...}: callPackage ./default.nix ({
  version = "2.097.2";
  dmdSha256 = "16ldkk32y7ln82n7g2ym5d1xf3vly3i31hf8600cpvimf6yhr6kb";
  druntimeSha256 = "1sayg6ia85jln8g28vb4m124c27lgbkd6xzg9gblss8ardb8dsp1";
  phobosSha256 = "0czg13h65b6qwhk9ibya21z3iv3fpk3rsjr3zbcrpc2spqjknfw5";
} // args)
