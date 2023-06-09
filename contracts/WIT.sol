// SPDX-License-Identifier: MIT

pragma solidity 0.8.9;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@chainlink/contracts/src/v0.8/AutomationCompatible.sol";

import "./interfaces/ISwapRouter.sol";
import "./Oracle.sol";

// TODO: IWIT
// import "hardhat/console.sol";

contract WiccaIndexToken is
    Oracle,
    AutomationCompatibleInterface,
    ERC20("WICCA Index Token", "WIT")
{
    // TODO: safeERC20
    // TODO: context

    //============ Params ============//

    address public treasury; // feeTo

    IERC20 public inputToken; // 0x00 for ETH
    IERC20[] public outputTokens;
    uint256[] public weights;
    uint256 public totalWeight;

    uint256 private constant _DECIMALS = 10000;

    ISwapRouter internal swap;

    AggregatorV3Interface internal inputTokenPriceFeed;
    AggregatorV3Interface[] internal outputTokenPriceFeeds;

    struct Task {
        bool active;
        address to;
        uint256 amount;
        uint256 startBlock;
        uint256 endBlock;
        uint256 interval;
        uint256 count;
    }
    uint256 private _tasksId;
    mapping(uint256 => Task) internal _tasks;

    //============ Initialize ============//

    constructor(
        address treasury_,
        address inputToken_,
        address[] memory outputTokens_,
        uint256[] memory weights_,
        address inputTokenPriceFeedAddress,
        address[] memory outputTokenPriceFeedAddress,
        address swap_
    )
        Oracle(
            inputToken_,
            outputTokens_,
            inputTokenPriceFeedAddress,
            outputTokenPriceFeedAddress
        )
    {
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

            outputTokenPriceFeeds.push(
                AggregatorV3Interface(outputTokenPriceFeedAddress[i])
            );

            unchecked {
                i++;
            }
        }

        require(totalWeight == _DECIMALS, "WIT::constructor: input error.");

        swap = ISwapRouter(swap_);

        inputTokenPriceFeed = AggregatorV3Interface(inputTokenPriceFeedAddress);
    }

    // function _getShares(uint256 inputAmount) internal returns (uint256 amount) {}

    //====== deposit & withdraw ======//

    function deposit(address to_, uint256 amount_) external {
        inputToken.transferFrom(msg.sender, address(this), amount_);
        _exchange(amount_);
        _mint(to_, amount_); // TODO: yield bearing => share amount
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
        uint256 startBlock_,
        uint256 endBlock_,
        uint256 interval_
    ) external {
        _tasks[_tasksId++] = Task({
            active: true,
            to: to_,
            amount: amount_,
            startBlock: startBlock_,
            endBlock: endBlock_,
            interval: interval_,
            count: 0
        });
    }

    function cancel(uint256 tid) external {
        _tasks[tid].active = false;
    }

    //============ Automation ============//

    // Example: 0-to-10:
    // 0x0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000a
    /// @dev Pagination for multiple upkeeps.
    function pagination(
        uint256 lowerBound,
        uint256 upperBound
    ) external pure returns (bytes memory) {
        return abi.encode(lowerBound, upperBound); // [lowerBound, upperBound)
    }

    function checkUpkeep(
        bytes calldata checkData
    )
        public
        view
        override
        returns (bool upkeepNeeded, bytes memory performData)
    {
        (uint256 lowerBound, uint256 upperBound) = abi.decode(
            checkData,
            (uint256, uint256)
        );

        uint256 len;
        uint256[] memory tids = new uint256[](upperBound - lowerBound);
        uint256 blockNumber = block.number;

        // check
        for (uint256 i = lowerBound; i < upperBound; ) {
            Task storage task = _tasks[i];

            if (
                (task.startBlock + task.count * task.interval <= blockNumber) &&
                (task.endBlock > blockNumber)
            ) {
                tids[len] = i;
                unchecked {
                    ++len;
                }
            }
            unchecked {
                ++i;
            }
        }

        // return
        if (len > 0) {
            // resize memory
            assembly {
                mstore(tids, len)
            }
            upkeepNeeded = true;
            performData = abi.encode(tids);
        }
    }

    function performUpkeep(bytes calldata performData) external override {
        // checkUpkeep() // TODO

        uint256[] memory tids = abi.decode(performData, (uint256[]));

        for (uint256 i = 0; i < tids.length; ) {
            Task storage task = _tasks[tids[i]];

            inputToken.transferFrom(msg.sender, address(this), task.amount);
            _exchange(task.amount);
            _mint(task.to, task.amount); // TODO: yield bearing => share amount

            unchecked {
                ++i;
            }
        }
    }

    //====== utils ======//

    function _allPrice() internal view returns (uint256[] memory) {
        uint256[] memory _prices = new uint256[](outputTokens.length);

        for (uint256 i; i < outputTokens.length; ) {
            _prices[i] = priceOf(address(outputTokens[i]));
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
