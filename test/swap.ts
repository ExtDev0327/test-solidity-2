const { BigNumber } = require("ethers");
const { expect } = require("chai");
const { ethers } = require("hardhat");

describe("BContract Swap", function () {
  let aContract: any;
  let bContract: any;
  beforeEach(async function () {
    const AContract = await ethers.getContractFactory("AContract");
    aContract = await AContract.deploy("TestNFTA", "TNA");
    await aContract.deployed();
    const BContract = await ethers.getContractFactory("BContract");
    bContract = await BContract.deploy(aContract.address, "TestNFTB", "TNB");
    await bContract.deployed();
  });

  it("Should user own a A's token", async function () {
    const [user] = await ethers.getSigners();
    await aContract.mint(user.address, 2, "", {
      value: ethers.utils.parseEther("0.01"),
    });
    expect(await aContract.ownerOf(2)).to.equal(user.address);

    await aContract.approve(bContract.address, 2);
    await bContract.mint(user.address, 1, "", 2);
    expect(await bContract.ownerOf(1)).to.equal(user.address);
    expect(await aContract.ownerOf(2)).to.equal(bContract.address);
    expect(await bContract.escrowedTokens(user.address)).to.equal(2);

    await bContract.swap(1);
    expect(await aContract.ownerOf(2)).to.equal(user.address);
    await expect(bContract.ownerOf(1)).to.be.revertedWith(
      "ERC721: invalid token ID"
    );
  });

  it("Should fail when invalid token inputed", async function () {
    const [user, otherUser] = await ethers.getSigners();
    await aContract.connect(otherUser).mint(otherUser.address, 2, "", {
      value: ethers.utils.parseEther("0.01"),
    });
    await aContract.connect(otherUser).approve(bContract.address, 2);
    await bContract.connect(otherUser).mint(otherUser.address, 1, "", 2);

    await expect(bContract.swap(1)).to.be.revertedWith(
      "user doesn't own this token"
    );
  });
});
