const hre = require("hardhat");
const fs = require('fs');
const { signer, contract, set } = require('./set');

async function deploy() {
  process.stdout.write("Deploy Token0");
  const Token0 = await hre.ethers.getContractFactory("TestERC20");
  contract.token0 = await Token0.deploy();
  await contract.token0.deployed();
  console.log(":\t\t", contract.token0.address);

  process.stdout.write("Deploy Token1");
  const Token1 = await hre.ethers.getContractFactory("TestERC20");
  contract.token1 = await Token1.deploy();
  await contract.token1.deployed();
  console.log(":\t\t", contract.token1.address);

  process.stdout.write("Deploy Token2");
  const Token2 = await hre.ethers.getContractFactory("TestERC20");
  contract.token2 = await Token2.deploy();
  await contract.token2.deployed();
  console.log(":\t\t", contract.token2.address);

  process.stdout.write("Deploy Token3");
  const Token3 = await hre.ethers.getContractFactory("TestERC20");
  contract.token3 = await Token3.deploy();
  await contract.token3.deployed();
  console.log(":\t\t", contract.token3.address);

  process.stdout.write("Deploy Token4");
  const Token4 = await hre.ethers.getContractFactory("TestERC20");
  contract.token4 = await Token4.deploy();
  await contract.token4.deployed();
  console.log(":\t\t", contract.token4.address);

  process.stdout.write("Deploy Token5");
  const Token5 = await hre.ethers.getContractFactory("TestERC20");
  contract.token5 = await Token5.deploy();
  await contract.token5.deployed();
  console.log(":\t\t", contract.token5.address);


  process.stdout.write("Deploy Oracle");
  const Oracle = await hre.ethers.getContractFactory("Oracle");
  contract.oracle = await Oracle.deploy(
    [
      contract.token0.address,
      contract.token1.address,
      contract.token2.address,
      contract.token3.address,
      contract.token4.address,
      contract.token5.address
    ],
    [
      BigInt(23000 * (10 ** 18)),
      BigInt(1600 * (10 ** 18)),
      BigInt(0.4 * (10 ** 18)),
      BigInt(500 * (10 ** 18)),
      BigInt(12 * (10 ** 18)),
      BigInt(1 * (10 ** 18)) // USDC
    ]
  );
  await contract.oracle.deployed();
  console.log(":\t\t", contract.oracle.address);

  process.stdout.write("Deploy Swap");
  const Swap = await hre.ethers.getContractFactory("Swap");
  contract.swap = await Swap.deploy(contract.oracle.address);
  await contract.swap.deployed();
  console.log(":\t\t", contract.swap.address);

  process.stdout.write("Deploy Action");
  const Action = await hre.ethers.getContractFactory("Action");
  contract.action = await Action.deploy();
  await contract.action.deployed();
  console.log(":\t\t", contract.action.address);


  process.stdout.write("Deploy Factory");
  const Factory = await hre.ethers.getContractFactory("WitFactory");
  contract.factory = await Factory.deploy(
    signer.fee.address,
    contract.swap.address,
    contract.action.address,
    contract.oracle.address
  );
  await contract.factory.deployed();
  console.log(":\t\t", contract.factory.address);


  process.stdout.write("Deploy WIT0");
  const txRes0 = await contract.factory.create(
    contract.token5.address,
    [
      contract.token0.address,
      contract.token1.address,
      contract.token2.address,
      contract.token3.address
    ],
    [
      6000,
      2900,
      1000,
      100
    ]
  );
  await txRes0.wait();
  contract.wit0 = await ethers.getContractAt("WiccaIndexToken", await contract.factory.wits(0));
  console.log(":\t\t", contract.wit0.address);

  process.stdout.write("Deploy WIT1");
  const txRes1 = await contract.factory.create(
    contract.token5.address,
    [
      contract.token0.address,
      contract.token1.address
    ],
    [
      5000,
      5000
    ]
  );
  await txRes1.wait();
  contract.wit1 = await ethers.getContractAt("WiccaIndexToken", await contract.factory.wits(1));
  console.log(":\t\t", contract.wit1.address);

  process.stdout.write("Deploy WIT2");
  const txRes2 = await contract.factory.create(
    contract.token5.address,
    [
      contract.token0.address,
      contract.token1.address,
      contract.token2.address,
      contract.token3.address,
      contract.token4.address
    ],
    [
      4000,
      3000,
      1000,
      1000,
      1000
    ]
  );
  await txRes2.wait();
  contract.wit2 = await ethers.getContractAt("WiccaIndexToken", await contract.factory.wits(2));
  console.log(":\t\t", contract.wit2.address);


  fs.writeFileSync("address.json", JSON.stringify({
    "Owner": signer.owner.address,
    "User1": signer.user1.address,
    "User2": signer.user2.address,
    "Fee": signer.fee.address,
    "Token0": contract.token0.address,
    "Token1": contract.token1.address,
    "Token2": contract.token2.address,
    "Token3": contract.token3.address,
    "Token4": contract.token4.address,
    "Token5": contract.token5.address,
    "swap": contract.swap.address,
    "action": contract.action.address,
    "oracle": contract.oracle.address,
    "factory": contract.factory.address,
    "wit0": contract.wit0.address,
    "wit1": contract.wit1.address,
    "wit2": contract.wit2.address
  }, null, 4));
}

async function main() {
  console.log("\n<Set>");
  await set();

  console.log("\n<Deploy>");
  await deploy();


  // TODO: test
  let txRes;

  // approve and mint token5

  process.stdout.write("[USDC] Max approve");
  txRes = await contract.token5.connect(signer.user1).approveMax(contract.wit0.address);
  await txRes.wait();
  console.log(" - complete");

  process.stdout.write("[USDC] Mint 10000");
  txRes = await contract.token5.connect(signer.user1).mint(
    signer.user1.address,
    BigInt(10000 * (10 ** 18))
  );
  await txRes.wait();
  console.log(" - complete");

  // deposit
  process.stdout.write("[WIT0] Deposit 10000 USDC");
  txRes = await contract.wit0.connect(signer.user1).deposit(
    signer.user1.address,
    BigInt(10000 * (10 ** 18))
  );
  await txRes.wait();
  console.log(` - complete (Balance: ${await contract.wit0.balanceOf(signer.user1.address) / (10 ** 18)})`);

  // withdraw
  process.stdout.write("[WIT0] Withdraw 2000 WIT0");
  txRes = await contract.wit0.connect(signer.user1).withdraw(
    signer.user1.address,
    BigInt(2000 * (10 ** 18))
  );
  await txRes.wait();
  console.log(` - complete (Balance:\
    ${await contract.token0.balanceOf(signer.user1.address) / (10 ** 18)}, \
    ${await contract.token1.balanceOf(signer.user1.address) / (10 ** 18)}, \
    ${await contract.token2.balanceOf(signer.user1.address) / (10 ** 18)}, \
    ${await contract.token3.balanceOf(signer.user1.address) / (10 ** 18)}\
  )`);
}

main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
