// SPDX-License-Identifier: MIT

pragma solidity 0.8.9;

import "./WIT.sol";

contract WitFactory {
    address[] public wits;

    address public treasury;
    address public swap;

    constructor(address treasury_, address swap_) {
        treasury = treasury_;
        swap = swap_;
    }

    function create(
        address inputToken_,
        address[] memory outputTokens_,
        uint256[] memory weights_,
        address inputTokenPriceFeedAddress_,
        address[] memory outputTokenPriceFeedAddress_
    ) external {
        WiccaIndexToken wit = new WiccaIndexToken(
            treasury,
            inputToken_,
            outputTokens_,
            weights_,
            inputTokenPriceFeedAddress_,
            outputTokenPriceFeedAddress_,
            swap
        );

        wits.push(address(wit));
    }
}
