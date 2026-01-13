const hre = require("hardhat");

async function main() {
  const [deployer] = await hre.ethers.getSigners();
  console.log("Deploying contracts with the account:", deployer.address);

  // 1. Deploy NFT
  const NFT = await hre.ethers.getContractFactory("StakingNFTCollection");
  const nft = await NFT.deploy();
  await nft.deployed();
  console.log("NFT Collection deployed to:", nft.address);

  // 2. Deploy Staking Engine
  const Staking = await hre.ethers.getContractFactory("NFTStakingEngine");
  const staking = await Staking.deploy(nft.address, "0x..."); // Add Reward Token Address
  await staking.deployed();
  console.log("Staking Engine deployed to:", staking.address);
}

main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
