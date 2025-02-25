// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import "./Mojo.sol";

/**
 * @title MojoSwap
 * @notice Handles PJK burn events from Polygon and mints Mojo on Optimism.
 */
contract MojoSwap {
    Mojo public mojoToken;
    address public owner;
    // Simplified: Assume an oracle or bridge sets this after verifying Polygon burn
    mapping(address => uint256) public pendingSwaps;

    event SwapRequested(address indexed user, uint256 pjkAmount);
    event SwapCompleted(address indexed user, uint256 pjkAmount, uint256 mojoAmount);

    constructor(address _mojoToken) {
        mojoToken = Mojo(_mojoToken);
        owner = msg.sender;
    }

    /**
     * @notice Request swap (called after burning PJK on Polygon).
     * @param pjkAmount Amount burned, verified off-chain or via bridge.
     */
    function requestSwap(uint256 pjkAmount) external {
        pendingSwaps[msg.sender] += pjkAmount;
        emit SwapRequested(msg.sender, pjkAmount);
    }

    /**
     * @notice Complete swap by minting Mojo (owner or oracle calls after verification).
     */
    function completeSwap(address user, uint256 pjkAmount) external onlyOwner {
        require(pendingSwaps[user] >= pjkAmount, "Insufficient pending amount");
        pendingSwaps[user] -= pjkAmount;
        mojoToken.mintForSwap(user, pjkAmount);
        emit SwapCompleted(user, pjkAmount, pjkAmount * mojoToken.swapRatio());
    }

    modifier onlyOwner() {
        require(msg.sender == owner, "Not owner");
        _;
    }
}