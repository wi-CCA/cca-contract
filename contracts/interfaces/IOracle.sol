// SPDX-License-Identifier: MIT

pragma solidity 0.8.9;

interface IOracle {
    function priceOf(address token) external returns (uint256 price);
}
