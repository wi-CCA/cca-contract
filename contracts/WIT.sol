// SPDX-License-Identifier: MIT

pragma solidity 0.8.9;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "../actions/contracts/interfaces/IActions.sol";
import "./interfaces/IOracle.sol";
import "./interfaces/ISwapRouter.sol";

// import "hardhat/console.sol";

contract WiccaIndexToken is ERC20("WICCA Index Token", "WIT"), IActions {
    // TODO: safeERC20
    // TODO: context

    address public treasury; // feeTo

    IERC20 public inputToken; // 0x00 for ETH
    IERC20[] public outputTokens;
    uint256[] public weights;
    uint256 public totalWeight;

    uint256 internal _DECIMALS = 10000;

    ISwapRouter public swap;
    address public action;
    IOracle public oracle;

    constructor(
        address treasury_,
        address inputToken_,
        address[] memory outputTokens_,
        uint256[] memory weights_,
        address swap_,
        address action_,
        address oracle_
    ) {
        require(
            outputTokens_.length == weights_.length,
            "WIT::constructor: input error."
        );

        treasury = treasury_;
        inputToken = IERC20(inputToken_);
        for (uint256 i; i < weights_.length; ) {
            outputTokens.push(IERC20(outputTokens_[i]));
            weights.push(weights_[i]);
            totalWeight += weights_[i];
            unchecked {
                i++;
            }
        }

        require(totalWeight == _DECIMALS, "WIT::constructor: input error.");

        swap = ISwapRouter(swap_);

        action = action_;
        oracle = IOracle(oracle_);
    }

    // function _getShares(uint256 inputAmount) internal returns (uint256 amount) {}

    //====== deposit & withdraw ======//

    function deposit(address to_, uint256 amount_) external {
        inputToken.transferFrom(msg.sender, address(this), amount_);

        _exchange(amount_);

        _mint(to_, amount_); // TODO: share amount
    }

    function withdraw(address to_, uint256 amount_) external {
        _burn(msg.sender, amount_);

        for (uint256 i; i < outputTokens.length; ) {
            outputTokens[i].transfer(
                to_,
                (outputTokens[i].balanceOf(address(this)) * amount_) /
                    totalSupply()
            );
            unchecked {
                i++;
            }
        }
    }

    function _exchange(uint256 amount_) internal {
        uint256[] memory prices = _allPrice();

        uint256 sum;
        for (uint256 i; i < prices.length; ) {
            sum += (prices[i] * weights[i]) / _DECIMALS; // TODO: 10^18
            unchecked {
                i++;
            }
        }

        uint256 x = ((10 ** 18) * amount_) / sum; // TODO: 10^18

        for (uint256 i; i < outputTokens.length; ) {
            _swap(
                address(inputToken),
                address(outputTokens[i]),
                address(this),
                (weights[i] * x) / _DECIMALS
            ); // TODO: 10^18
            unchecked {
                i++;
            }
        }
    }

    //====== actions ======//

    function enroll(
        address to_,
        uint256 amount_,
        uint256 startBlock,
        uint256 endBlock,
        uint256 interval
    ) external {}

    function cancel() external {}

    function checkUpkeep(
        bytes calldata checkData
    )
        public
        view
        override
        returns (bool upkeepNeeded, bytes memory performData)
    {}

    function performUpkeep(bytes calldata performData) external override {
        // checkUpkeep()
    }

    //====== utils ======//

    function _allPrice() internal returns (uint256[] memory) {
        uint256[] memory _prices = new uint256[](outputTokens.length);

        for (uint256 i; i < outputTokens.length; ) {
            _prices[i] = oracle.priceOf(address(outputTokens[i]));
            unchecked {
                i++;
            }
        }

        return _prices;
    }

    function _swap(
        address fromToken_,
        address toToken_,
        address to_,
        uint256 amountOut
    ) internal {
        address[] memory path = new address[](2);
        path[0] = fromToken_;
        path[1] = toToken_;

        swap.swapTokensForExactTokens(
            amountOut,
            type(uint256).max,
            path,
            to_,
            type(uint256).max
        ); // TODO
    }
}
