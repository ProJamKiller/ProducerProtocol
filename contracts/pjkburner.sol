// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

/**
 * @title PJKBurner
 * @notice Burns PJK tokens on Polygon to trigger Mojo minting on Optimism.
 */
contract PJKBurner {
    IERC20 public pjkToken = IERC20(0xfc0E40e7D6AbA1079409966bcAcB2273f048Da5F);
    address public constant BURN_ADDRESS = 0x000000000000000000000000000000000000dEaD;

    event PJKBurned(address indexed user, uint256 amount);

    /**
     * @notice Burns PJK tokens by sending them to a dead address.
     * @param amount Amount of PJK to burn.
     */
    function burnPJK(uint256 amount) external {
        require(pjkToken.transferFrom(msg.sender, BURN_ADDRESS, amount), "PJK burn failed");
        emit PJKBurned(msg.sender, amount);
    }
}