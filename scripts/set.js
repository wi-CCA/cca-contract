let signer = {
    "owner": null,
    "user1": null,
    "user2": null,
    "fee": null
}

let contract = {
    "token0": null,
    "token1": null,
    "token2": null,
    "token3": null,
    "token4": null,
    "token5": null,
    "swap": null,
    "factory": null,
    "wit0": null,
    "wit1": null,
    "wit2": null,
}

async function set() {
    [signer.owner, signer.user1, signer.user2, signer.fee] = await ethers.getSigners();

    // TODO: change keys
    // since they have same private keys
    signer.user1 = signer.owner;
    signer.user2 = signer.owner;
    signer.fee = signer.owner;

    let balanceOfOwner = await signer.owner.getBalance() / (10 ** 18);
    let balanceOfUser1 = await signer.user1.getBalance() / (10 ** 18);
    let balanceOfUser2 = await signer.user2.getBalance() / (10 ** 18);
    let balanceOfFee = await signer.fee.getBalance() / (10 ** 18);

    console.log("Owner:\t", signer.owner.address, `(${balanceOfOwner} ETH)`);
    console.log("User1:\t", signer.user1.address, `(${balanceOfUser1} ETH)`);
    console.log("User2:\t", signer.user2.address, `(${balanceOfUser2} ETH)`);
    console.log("Fee:\t", signer.fee.address, `(${balanceOfFee} ETH)`);
}

// async function attach() {
//     const address = require("../address");

//     process.stdout.write("Attach Token");
//     contract.token = await ethers.getContractAt("TestERC20", address.Token);
//     console.log(" - complete");
// }

module.exports = {
    signer,
    contract,
    set
}
