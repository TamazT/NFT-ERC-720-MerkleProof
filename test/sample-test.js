const { expect, assert } = require("chai");
const { getAddress } = require("ethers/lib/utils");
const { ethers } = require("hardhat");

describe("Artwork Smart Contract Tests", function () {
  let artwork;

  this.beforeEach(async function () {
    const Artwork = await ethers.getContractFactory("Artwork");
    artwork = await Artwork.deploy("tamaz", "rama");
  });

  it("It return wlmint close", async function () {
    assert.equal(await artwork.checkWlMint(), false);
  });
  it("It return wlmint open", async function () {
    await artwork.openWLMint();
    assert.equal(await artwork.checkWlMint(), true);
  });
  it("It will be reverted if mint does not opened", async function () {
    await expect(artwork.mintWl(1)).to.be.revertedWith("didnot open");
  });
  it("It will be reverted if address not in wl", async function () {
    await artwork.openWLMint();
    await expect(artwork.mintWl(1)).to.be.revertedWith(
      "You are not in wl list"
    );
  });
  it("It return publicmint close", async function () {
    assert.equal(await artwork.checkPublicMint(), false);
  });
  it("It return publicmint open", async function () {
    await artwork.openPublicMint();
    assert.equal(await artwork.checkPublicMint(), true);
  });
  it("It will be reverted if public mint did not open", async function () {
    await expect(artwork.mintPublic(1)).to.be.revertedWith(
      "Public mint did not open"
    );
  });
  it("It will be publci minted if public mint open", async function () {
    await artwork.openPublicMint();
    await artwork.setMaxPerWLAddress(1);
    [account1] = await ethers.getSigners();
    await artwork.connect(account1).mintPublic(1);
    assert.equal(await artwork.balanceOf(account1.address), 1);
  });
  it("It will be minted for wl address", async function () {
    await artwork.openWLMint();
    [account1] = await ethers.getSigners();
    await artwork.addWlAdresses([account1.address]);
    await artwork.setMaxPerWLAddress(5);
    await artwork.connect(account1).mintWl(5);
    assert.equal(await artwork.balanceOf(account1.address), 5);
  });
  it("It will be reverted if wl trying mint more than we get for him", async function () {
    await artwork.openWLMint();
    await artwork.setMaxPerWLAddress(1);
    [account1] = await ethers.getSigners();
    await artwork.addWlAdresses([account1.address]);
    await expect(artwork.connect(account1).mintWl(2)).to.be.revertedWith(
      "You have minted max per you address"
    );
  });
  it("It will be minted only part", async function () {
    await artwork.openWLMint();
    await artwork.setMaxPerWLAddress(5);
    [account1] = await ethers.getSigners();
    await artwork.addWlAdresses([account1.address]);
    await artwork.connect(account1).mintWl(2);
    assert.equal(await artwork.balanceOf(account1.address), 2);
    await artwork.connect(account1).mintWl(2);
    assert.equal(await artwork.balanceOf(account1.address), 4);
    await expect(artwork.connect(account1).mintWl(2)).to.be.revertedWith(
      "You have minted max per you address"
    );
  });
  it("It will set base uri", async function () {
    await artwork.setBaseURI("tamaz/");
    await artwork.openWLMint();
    await artwork.setMaxPerWLAddress(5);
    [account1] = await ethers.getSigners();
    await artwork.addWlAdresses([account1.address]);
    await artwork.connect(account1).mintWl(2);
    assert.equal(await artwork.tokenURI(1), "tamaz/1.json");
    await artwork.setBaseURI("nana/");
    assert.equal(await artwork.tokenURI(1), "nana/1.json");
  });
});
