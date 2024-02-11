const { expect } = require("chai");
const { ethers } = require("hardhat");
const tokenJSON = require("../artifacts/contracts/ERC.sol/AnyaToken.json")

describe("Shop", async function(){
    let owner;
    let buyer;
    let shop;
    let erc20;

    beforeEach(async function(){
        [owner, buyer] = await ethers.getSigners();
        const Shop = await ethers.getContractFactory("AnyaShop", owner);
        shop = await Shop.deploy()
        await shop.waitForDeployment()

        address = await shop.getAddress()
        erc20 = new ethers.Contract(await shop.token(), tokenJSON.abi, owner)
    })

    it("should have an owner and a token", async function () {
        expect(await shop.owner()).to.eq(owner.address);
        
        expect(await shop.token()).to.be.properAddress;
    })

    it("allows to buy", async function() { 
        const tokenAmount = 3n;

        const txData = {
            value: tokenAmount,
            to: address
        }

        const tx = await buyer.sendTransaction(txData);
        await tx.wait()

        expect(await erc20.balanceOf(buyer.address)).to.eq(tokenAmount)
        await expect(() => tx).
        to.changeEtherBalance(shop, tokenAmount)

        expect(tx).to.emit(shop, "Bought").
        withArgs(tokenAmount, buyer.address)
    })

    it("allows to sell", async function () {
        const tokenAmount = 10n;

        const txData = {
            value: tokenAmount,
            to: address
        }

        const tx = await buyer.sendTransaction(txData);
        await tx.wait()

        const sellTokenAmount = 7n;

        const approval = await erc20.connect(buyer).approve(address, sellTokenAmount)
        await approval.wait()

        const sellTx = await shop.connect(buyer).sell(sellTokenAmount);

        expect(await erc20.balanceOf(buyer.address)).to.eq(tokenAmount-sellTokenAmount);

        await expect(() => sellTx).
        to.changeEtherBalance(shop, -sellTokenAmount)

        expect(sellTx).to.emit(shop, "Sold").
        withArgs(sellTokenAmount, buyer.address)

    })
})
