const {
  time,
  loadFixture,
} = require("@nomicfoundation/hardhat-network-helpers");
const { anyValue } = require("@nomicfoundation/hardhat-chai-matchers/withArgs");
const { expect } = require("chai");
const { ethers } = require("hardhat");

describe("DAO", function () {
  let accounts = [];
  let nmeta;
  let nusd;
  let nusdMinter;
  let treasury;
  let balanceHelper;
  let metaSwapFactory;

  before(async () => {
    accounts = await ethers.getSigners();

    const [deployer, other1, other2] = accounts;

    const NMETA = await ethers.getContractFactory("NMETA");
    nmeta = await NMETA.deploy();

    const NUSD = await ethers.getContractFactory("NUSD");
    nusd = await NUSD.deploy();

    const NUSDMinter = await ethers.getContractFactory("NUSDMinter");
    nusdMinter = await NUSDMinter.deploy();

    const Treasury = await ethers.getContractFactory("Treasury");
    treasury = await Treasury.deploy(
      nmeta.address,
      nusd.address,
      nusdMinter.address
    );

    const BalanceHelper = await ethers.getContractFactory("BalanceHelper");
    balanceHelper = await BalanceHelper.deploy(nusd.address, nmeta.address);

    const MetaSwapFactory = await ethers.getContractFactory("UniswapV2Factory");
    metaSwapFactory = await MetaSwapFactory.deploy(deployer.address);

    const metausdPair = await metaSwapFactory.createPair(
      nmeta.address,
      nusd.address
    );

    await balanceHelper.setFactory(metaSwapFactory.address);
    await treasury.setBalanceHelper(balanceHelper.address);

    await nmeta.connect(deployer).mint(deployer, 10000);
    await nusd.connect(deployer).mint(deployer, 10000);

    await metaSwapFactory.connect(deployer).addLi();
  });
});
