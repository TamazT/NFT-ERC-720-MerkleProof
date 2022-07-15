const { getNamedAccounts, deployments, network } = require("hardhat");
const {
  networkConfig,
  developmentChains,
} = require("../helper-hardhat-config");
const { verify } = require("../utils/verify");

module.exports = async ({ getNamedAccounts, deployments }) => {
  const { deploy, log } = deployments;
  const deployer ="your private key"
    ;
  log("----------------------------------------------------");
  log("Deploying FundMe and waiting for confirmations...");
  const arguments = ["Eternal", "EG"];
  const Artwork = await deploy("Artwork", {
    from: deployer,
    args: arguments,
    log: true,
    // we need to wait if on a live network so we can verify properly
    waitConfirmations: network.config.blockConfirmations || 1,
  });
  log(`Artwork deployed at ${Artwork.address}`);
  const chainId = network.config.chainId;
  if (chainId !== 31337 && process.env.ETHERSCAN_API_KEY) {
    await verify(Artwork.address, arguments);
  }
};

module.exports.tags = ["all", "fundme"];
