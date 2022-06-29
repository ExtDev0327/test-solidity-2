import { expect } from "chai";
import { ethers } from "hardhat";

describe("BContract Mint", function () {
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

  it("Should user own a B's token", async function () {
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
  });

  it("Should fail when invalid token inputed", async function () {
    const [user, otherUser] = await ethers.getSigners();
    await aContract.connect(otherUser).mint(otherUser.address, 2, "", {
      value: ethers.utils.parseEther("0.01"),
    });
    await expect(bContract.mint(user.address, 1, "", 2)).to.be.revertedWith(
      "user doesn't own this token"
    );
  });
});
