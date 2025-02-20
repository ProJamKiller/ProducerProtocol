const { expect } = require("chai");
const { ethers } = require("hardhat");

describe("WPJK Token", function () {
  let wpjk, owner, bridgeAccount, testAccount;

  beforeEach(async function () {
    [owner, bridgeAccount, testAccount] =
      await ethers.getSigners();

    const WPJK = await ethers.getContractFactory("WPJK");
    wpjk = await WPJK.deploy();
    await wpjk.deployed();

    // Grant bridge role
    await wpjk.grantRole(
      await wpjk.BRIDGE_ROLE(),
      bridgeAccount.address,
    );
  });

  it("Should mint tokens for bridge account", async function () {
    await wpjk
      .connect(bridgeAccount)
      .mint(testAccount.address, 1000);
    expect(
      await wpjk.balanceOf(testAccount.address),
    ).to.equal(1000);
  });

  it("Should prevent non-bridge accounts from minting", async function () {
    await expect(
      wpjk
        .connect(testAccount)
        .mint(testAccount.address, 1000),
    ).to.be.reverted;
  });
});
