const TestNft = artifacts.require("TestNft");
const Source = artifacts.require("SrcBridge")
const Destination = artifacts.require("DestBridge")

// Contracts for Wrapping NFT
const WrapNft = artifacts.require("WrapNft")
const NftFactory = artifacts.require("NftFactory")

module.exports = function (deployer) {
  deployer.deploy(TestNft);
  deployer.deploy(Source)
  deployer.deploy(Destination)

  deployer.deploy(WrapNft, "WRAP NFT", "WNFT")
  deployer.deploy(NftFactory)
};
