// SPDX-License-Identifier: MIT

pragma solidity 0.8.9;

import "../interfaces/IOracle.sol";

contract SampleOracle is IOracle {
    address[] public tokens;
    uint256[] public prices;

    constructor(address[] memory tokens_, uint256[] memory prices_) {
        for (uint256 i; i < tokens_.length; ) {
            tokens.push(tokens_[i]);
            prices.push(prices_[i]);
            unchecked {
                i++;
            }
        }
    }

    function priceOf(address token) external view returns (uint256 price) {
        for (uint256 i; i < tokens.length; ) {
            if (tokens[i] == token) {
                return prices[i];
            }
            unchecked {
                i++;
            }
        }
        return 10000 * 10 ** 18; // default
    }
}
