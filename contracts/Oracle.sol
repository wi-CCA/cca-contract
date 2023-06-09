// SPDX-License-Identifier: MIT

pragma solidity 0.8.9;

import "@chainlink/contracts/src/v0.8/interfaces/AggregatorV3Interface.sol";

import "./interfaces/IOracle.sol";

contract Oracle is IOracle {
    address private inputToken; // 0x00 for ETH
    address[] private outputTokens;
    AggregatorV3Interface private inputTokenPriceFeed;
    AggregatorV3Interface[] private outputTokenPriceFeeds;

    mapping(address => uint256) private _toIndex;

    constructor(
        address inputTokenAddress,
        address[] memory outputTokensAddress,
        address inputTokenPriceFeedAddress, // inputToken/USD
        address[] memory outputTokenPriceFeedAddress // outputToken/inputToken
    ) {
        inputToken = inputTokenAddress;
        outputTokens = outputTokensAddress;

        inputTokenPriceFeed = AggregatorV3Interface(inputTokenPriceFeedAddress);
        for (uint256 i = 0; i < outputTokensAddress.length; ) {
            outputTokenPriceFeeds.push(
                AggregatorV3Interface(outputTokenPriceFeedAddress[i])
            );

            _toIndex[outputTokensAddress[i]] = i;

            unchecked {
                ++i;
            }
        }
    }

    function priceOf(address token) public view returns (uint256 price) {
        int256 answer;

        if (token == inputToken) {
            (, answer, , , ) = inputTokenPriceFeed.latestRoundData();
        } else {
            // TODO: non-exist token address
            uint256 index = _toIndex[token];
            (, answer, , , ) = outputTokenPriceFeeds[index].latestRoundData();
        }

        return uint256(answer);
    }
}
