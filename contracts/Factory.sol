// SPDX-License-Identifier: MIT

pragma solidity 0.8.9;

import "./WIT.sol";

contract WitFactory {
    address[] public wits;

    address public treasury;
    address public swap;
    address public action;
    address public oracle;

    constructor(
        address treasury_,
        address swap_,
        address action_,
        address oracle_
    ) {
        treasury = treasury_;
        swap = swap_;
        action = action_;
        oracle = oracle_;
    }

    function create(
        address inputToken_,
        address[] memory outputTokens_,
        uint256[] memory weights_
    ) external {
        WiccaIndexToken wit = new WiccaIndexToken(
            treasury,
            inputToken_,
            outputTokens_,
            weights_,
            swap,
            action,
            oracle
        );

        wits.push(address(wit));
    }
}
