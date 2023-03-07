// SPDX-License-Identifier: MIT

pragma solidity 0.8.9;

import "../interfaces/IOracle.sol";

import "hardhat/console.sol";

interface ITestERC20 {
    function mint(address account, uint256 amount) external;

    function burn(address account, uint256 amount) external;

    function balanceOf(address account) external view returns (uint256);
}

contract Swap {
    IOracle internal _oracle;

    constructor(address oracle_) {
        _oracle = IOracle(oracle_);
    }

    function swapTokensForExactTokens(
        uint amountOut,
        uint amountInMax,
        address[] calldata path,
        address to,
        uint deadline
    ) external returns (uint[] memory amounts) {
        ITestERC20(path[0]).burn(
            msg.sender,
            (amountOut * 10 ** 18) / _oracle.priceOf(path[0])
        );
        ITestERC20(path[1]).mint(msg.sender, amountOut);

        console.log(
            path[1],
            msg.sender,
            ITestERC20(path[1]).balanceOf(msg.sender)
        );
    }
}
