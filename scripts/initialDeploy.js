
const { ethers, upgrades } = require('hardhat');

async function main () {
  const CrowdFund = await ethers.getContractFactory('CrowdFund');
  console.log('Deploying CrowdFund...');
const crowdFund = await upgrades.deployProxy(CrowdFund, [/* Enter address of ERC20 token */], { initializer: 'initialize' });
  await crowdFund.deployed();
  console.log('CrowdFund deployed to:', crowdFund.address);
}

main();

//cmd: npx hardhat run --network hardhat scripts/initialDeploy.js