const { expect } = require("chai");
const { ethers } = require("hardhat");


describe("GenesisRewardPool", function () {
  it("Should deploy", async function () {
    const CreamGenesisRewardPool = await ethers.getContractFactory("CreamGenesisRewardPool");
    const rewardPool = await CreamGenesisRewardPool.deploy("0x2546BcD3c84621e976D8185a91A922aE77ECEc30",
       "0xcd3B766CCDd6AE721141F452C550Ca635964ce71", 1642989500);
    await rewardPool.deployed();
  });
});

describe("GenesisRewardPool", function () {
  it("Should add a token to pool", async function () {

    const CreamGenesisRewardPool = await ethers.getContractFactory("CreamGenesisRewardPool");
    const rewardPool = await CreamGenesisRewardPool.deploy("0x2546BcD3c84621e976D8185a91A922aE77ECEc30",
       "0xcd3B766CCDd6AE721141F452C550Ca635964ce71", 1642990500);
    await rewardPool.deployed();

    const addTx = await rewardPool.add(0, "0x2546BcD3c84621e976D8185a91A922aE77ECEc30", false, 1642976500);


  });
});


describe("GenesisRewardPool", function () {
    it("Should generate reward", async function () {
  
      const CreamGenesisRewardPool = await ethers.getContractFactory("CreamGenesisRewardPool");
      const rewardPool = await CreamGenesisRewardPool.deploy("0x2546BcD3c84621e976D8185a91A922aE77ECEc30",
         "0xcd3B766CCDd6AE721141F452C550Ca635964ce71", 1642990500);
      await rewardPool.deployed();
  
      const getReward = await rewardPool.getGeneratedReward(1642990500, 1642995500);
      expect(getReward.div(BigInt(1e18))).to.equal(2400);
  
    });

});


describe("pendingCREAM", function () {
  it("Should generate reward", async function () {

    const CreamGenesisRewardPool = await ethers.getContractFactory("CreamGenesisRewardPool");
    const rewardPool = await CreamGenesisRewardPool.deploy("0x2546BcD3c84621e976D8185a91A922aE77ECEc30",
       "0xcd3B766CCDd6AE721141F452C550Ca635964ce71", 1642990500);
    await rewardPool.deployed();

    const getReward = await rewardPool.getGeneratedReward(1642990500, 1642995500);
    expect(getReward.div(BigInt(1e18))).to.equal(2400);

  });

});
