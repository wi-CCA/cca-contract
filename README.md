# WICCA Index Token (WIT)

This is the official repository for WICCA Index Token (WIT), an innovative investment protocol designed to simplify and secure the process of investing in a diverse portfolio of cryptocurrencies.

WICCA Index Token (WIT) is built on Solidity and utilizes the **Chainlink Automation** and **Chainlink Price Oracle** for secure and efficient operations.


## Contract Features

- **ERC20 Token:** WIT is an ERC20 token which can be minted and burned.

- **Oracle and Automation:** WIT integrates Chainlink Automation and to automate investment transactions securely.

- **Token Swapping:** The contract includes functions to exchange input tokens for output tokens based on predefined weights.

- **Investment Task Enrollment and Cancellation:** Users can enroll and cancel investment tasks, which are automatically executed based on predefined intervals.


## Installation

1. Install dependencies:

   ```bash
   npm install
   ```

2. Compile the contract:

   ```bash
   npx hardhat compile
   ```


## Deployment

1. Deploy the contract:

   ```bash
   npx hardhat run scripts/deploy.js
   ```

---

## Disclaimer

Do not use this code in production without proper security audits and testing.


## License

This project is licensed under the MIT License.
