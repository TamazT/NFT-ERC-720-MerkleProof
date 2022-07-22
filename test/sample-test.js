const { expect, assert } = require("chai");
const { getAddress } = require("ethers/lib/utils");
const { ethers } = require("hardhat");

describe("Artwork Smart Contract Tests", function () {
  let artwork;

  this.beforeEach(async function () {
    const Artwork = await ethers.getContractFactory("Artwork");
    artwork = await Artwork.deploy("tamaz", "rama");
  });
  describe("Wl mint", function () {
    it("It return wlmint close", async function () {
      assert.equal(await artwork.checkWlMint(), false);
      [account1, account2] = await ethers.getSigners();
      await expect(artwork.connect(account2).turnWLMint()).to.be.revertedWith(
        "Only owner can call this fucntion"
      );
      await artwork.turnWLMint();
      assert.equal(await artwork.checkWlMint(), true);
      await artwork.turnWLMint();
      assert.equal(await artwork.checkWlMint(), false);
    });
    it("It return wlmint open", async function () {
      await artwork.turnWLMint();
      assert.equal(await artwork.checkWlMint(), true);
    });
    it("It will be reverted if mint does not opened", async function () {
      await expect(artwork.mintWl(1)).to.be.revertedWith("didnot open");
    });
    it("It will be reverted if address not in wl", async function () {
      await artwork.turnWLMint();
      await expect(artwork.mintWl(1)).to.be.revertedWith(
        "You are not in wl list"
      );
    });
    it("It will be minted for wl address", async function () {
      await artwork.turnWLMint();
      [account1] = await ethers.getSigners();
      await artwork.addWlAdresses([account1.address]);
      await artwork.setMaxPerWLAddress(5);
      await artwork.connect(account1).mintWl(5);
      const balance = await artwork.balanceOf(account1.address);
      assert.equal(balance, 5);
    });
    it("It will be reverted if wl trying mint more than we get for him", async function () {
      await artwork.turnWLMint();
      await artwork.setMaxPerWLAddress(1);
      [account1] = await ethers.getSigners();
      await artwork.addWlAdresses([account1.address]);
      await expect(artwork.connect(account1).mintWl(2)).to.be.revertedWith(
        "You have minted max per you address"
      );
    });
    it("It will be minted only part", async function () {
      await artwork.turnWLMint();
      await artwork.setMaxPerWLAddress(5);
      [account1, account2] = await ethers.getSigners();
      await artwork.addWlAdresses([account1.address]);
      await artwork.connect(account1).mintWl(2);
      assert.equal(await artwork.balanceOf(account1.address), 2);
      await artwork.connect(account1).mintWl(2);
      await artwork
        .connect(account1)
        .transferFrom(account1.address, account2.address, 1);
      assert.equal(await artwork.balanceOf(account1.address), 3);
      await expect(artwork.connect(account1).mintWl(2)).to.be.revertedWith(
        "You have minted max per you address"
      );
    });
  });
  describe("Public mint", function () {
    it("It return publicmint close", async function () {
      assert.equal(await artwork.checkPublicMint(), false);
      await artwork.turnPublicMint();
      assert.equal(await artwork.checkPublicMint(), true);
      await artwork.turnPublicMint();
      assert.equal(await artwork.checkPublicMint(), false);
    });
    it("It return publicmint open", async function () {
      await artwork.turnPublicMint();
      assert.equal(await artwork.checkPublicMint(), true);
    });
    it("It will be reverted if public mint did not open", async function () {
      await expect(artwork.mintPublic(1, { value: 25 })).to.be.revertedWith(
        "Public mint did not open"
      );
    });
    it("It will be reverted if send not enough eth", async function () {
      await expect(artwork.mintPublic(2, { value: 25 })).to.be.revertedWith(
        "Not enough ETH"
      );
    });
    it("It will be public minted if public mint open", async function () {
      await artwork.turnPublicMint();
      await artwork.setMaxPerWLAddress(1);
      [account1] = await ethers.getSigners();
      await artwork.connect(account1).mintPublic(1, { value: 15 });
      assert.equal(
        await artwork.connect(account1).balanceOf(account1.address),
        1
      );
    });
    it("It will be minted only part", async function () {
      await artwork.turnPublicMint();
      await artwork.setMaxPerWLAddress(5);
      [account1] = await ethers.getSigners();
      await artwork.addWlAdresses([account1.address]);
      await artwork.connect(account1).mintPublic(2, { value: 50 });
      assert.equal(await artwork.balanceOf(account1.address), 2);
      await artwork.connect(account1).mintPublic(2, { value: 50 });
      assert.equal(await artwork.balanceOf(account1.address), 4);
      await expect(
        artwork.connect(account1).mintPublic(2, { value: 50 })
      ).to.be.revertedWith("You have minted max per you address");
    });
  });
  describe("Allowlist mint", function () {
    it("It return allowlist close", async function () {
      assert.equal(await artwork.checkAllowlistMint(), false);
      artwork.turnAllowlistMint();
      assert.equal(await artwork.checkAllowlistMint(), true);
      artwork.turnAllowlistMint();
      assert.equal(await artwork.checkAllowlistMint(), false);
    });
    it("It return allowlist open", async function () {
      await artwork.turnAllowlistMint();
      assert.equal(await artwork.checkAllowlistMint(), true);
    });
    it("It will be reverted if allowlist mint did not open", async function () {
      await expect(artwork.mintAllowlist(1, { value: 9 })).to.be.revertedWith(
        "Allowlist mint did not open"
      );
    });
    it("It will be reverted if send not enough eth", async function () {
      await expect(artwork.mintAllowlist(2, { value: 9 })).to.be.revertedWith(
        "Not enough ETH"
      );
    });
    it("It will be allowlist minted if allowlist mint open", async function () {
      await artwork.turnAllowlistMint();
      await artwork.setMaxPerWLAddress(1);
      [account1] = await ethers.getSigners();
      await artwork.connect(account1).mintAllowlist(1, { value: 9 });
      assert.equal(
        await artwork.connect(account1).balanceOf(account1.address),
        1
      );
    });
    it("It will be minted only part", async function () {
      await artwork.turnAllowlistMint();
      await artwork.setMaxPerWLAddress(5);
      [account1] = await ethers.getSigners();
      await artwork.addWlAdresses([account1.address]);
      await artwork.connect(account1).mintAllowlist(2, { value: 18 });
      assert.equal(await artwork.balanceOf(account1.address), 2);
      await artwork.connect(account1).mintAllowlist(2, { value: 18 });
      assert.equal(await artwork.balanceOf(account1.address), 4);
      await expect(
        artwork.connect(account1).mintAllowlist(2, { value: 18 })
      ).to.be.revertedWith("You have minted max per you address");
    });
  });
  describe("UrI Functions", function () {
    it("It will set base uri", async function () {
      await artwork.setBaseURI("tamaz/");
      await artwork.turnWLMint();
      await artwork.setMaxPerWLAddress(5);
      [account1] = await ethers.getSigners();
      await artwork.addWlAdresses([account1.address]);
      await artwork.connect(account1).mintWl(2);
      assert.equal(await artwork.tokenURI(1), "tamaz/1.json");
      await artwork.setBaseURI("nana/");
      assert.equal(await artwork.tokenURI(1), "nana/1.json");
    });
  });
  describe("Tresuare mint", function () {
    it("Tresuare mint works correct", async function () {
      [account1] = await ethers.getSigners();
      await artwork.TresuareMint(100);
      assert.equal(await artwork.balanceOf(account1.address), 100);
      await artwork.TresuareMint(100);
      assert.equal(await artwork.balanceOf(account1.address), 200);
    });
  });
});
