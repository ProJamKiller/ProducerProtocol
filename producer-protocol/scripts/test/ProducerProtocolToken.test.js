const { expect } = require("chai");
const { ethers } = require("hardhat");

describe("ProducerProtocolToken", function () {
  let token, owner, artist, fan;

  beforeEach(async function () {
    [owner, artist, fan] = await ethers.getSigners();

    const ProducerProtocolToken =
      await ethers.getContractFactory(
        "ProducerProtocolToken",
      );
    token = await ProducerProtocolToken.deploy(
      "Producer Protocol Token",
      "PPT",
      owner.address,
    );
    await token.deployed();
  });

  it("Should mint artist tokens", async function () {
    const projectId =
      ethers.utils.formatBytes32String("Project1");

    await token.mintArtistTokens(
      artist.address,
      1000,
      projectId,
      50,
    );

    const contributions =
      await token.getProjectContributions(projectId);
    expect(contributions[0].contributor).to.equal(
      artist.address,
    );
  });
});
