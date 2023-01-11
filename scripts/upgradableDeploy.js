const { ethers, upgrades } = require("hardhat");

async function main() {
    const UpdateContract = await ethers.getContractFactory (/* write name of contract */);
    console.log("Contract is upgrading ....");

    await upgrades.upgradeProxy(
        /* Write address of your contract you want to update->*/ "",
        UpdateContract
    );
    console.log("Previous upgraded to NEW Contract");
}
main();

//cmd: npx hardhat run --network hardhat scripts/upgradableDeploy.js
