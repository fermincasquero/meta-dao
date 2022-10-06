const { ethers } = require("hardhat");
const fs = require("fs");

async function main() {
  const [deployer, ...accounts] = await ethers.getSigners();

  const NMETA = await ethers.getContractFactory("NMETA");
  const nmeta = await NMETA.deploy();

  const NUSD = await ethers.getContractFactory("NUSD");
  const nusd = await NUSD.deploy();

  const NUSDMinter = await ethers.getContractFactory("NUSDMinter");
  const nusdMinter = await NUSDMinter.deploy();

  const Treasury = await ethers.getContractFactory("Treasury");
  const treasury = await Treasury.deploy(
    nmeta.address,
    nusd.address,
    nusdMinter.address
  );

  const BalanceHelper = await ethers.getContractFactory("BalanceHelper");
  const balanceHelper = await BalanceHelper.deploy(nusd.address, nmeta.address);

  const MetaSwapFactory = await ethers.getContractFactory("UniswapV2Factory");
  const metaSwapFactory = await MetaSwapFactory.deploy(deployer.address);

  const MetaSwapRouter = await ethers.getContractFactory("UniswapV2Router02");
  const metaSwapRouter = await MetaSwapRouter.deploy(metaSwapFactory.address, );

  const metausdPair = await metaSwapFactory.createPair(
    nmeta.address,
    nusd.address
  );

  await balanceHelper.setFactory(metaSwapFactory.address);
  await treasury.setBalanceHelper(balanceHelper.address);

  await fs.writeFile(
    "./scripts/addresses.json",
    JSON.stringify({
      nmeta: nmeta.address,
      nusd: nusd.address,
      treasury: treasury.address,
      balanceHelper: balanceHelper.address,
      nusdMinter: nusdMinter.address,
    }),
    () => {
      console.log("Finished");
    }
  );
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
