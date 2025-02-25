// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import "./mojo.sol";

interface IPGKBurner {
    function verifyBurn(address user, uint256 amount) external view returns (bool);
}

/**
 * @title MojoSwap
 * @notice Handles PJK burn events from Polygon and mints Mojo on Optimism.
 */
contract MojoSwap {
    Mojo public mojoToken = Mojo(0xf9e7D3cd71Ee60C7A3A64Fa7Fcb81e610Ce1daA5);
    IPGKBurner public pjkBurner = IPGKBurner(0xFF197b807f60c2985938c0Fe920D89E1c80a1aF3);
    address public owner;
    
    mapping(address => uint256) public pendingSwaps;

    event SwapRequested(address indexed user, uint256 pjkAmount);
    event SwapCompleted(address indexed user, uint256 pjkAmount, uint256 mojoAmount);

    constructor() {
        owner = msg.sender;
    }

    /**
     * @notice Request swap after burning PJK on Polygon.
     * @param pjkAmount Amount burned, verified via the PGKBurner contract.
     */
    function requestSwap(uint256 pjkAmount) external {
        require(pjkBurner.verifyBurn(msg.sender, pjkAmount), "Burn verification failed");
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