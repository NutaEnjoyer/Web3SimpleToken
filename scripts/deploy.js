const hre = require("hardhat");
const ethers = hre.ethers;


async function main() {
  const [singer] = await ethers.getSigners();

  const Erc = await ethers.getContractFactory("AnyaShop", singer);
  const erc = await Erc.deploy()
  await erc.waitForDeployment()

  console.log(await erc.getAddress())
  console.log(await erc.token())
}

main()
.then(()=>process.exit(0))
.catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
н