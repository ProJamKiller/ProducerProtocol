// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

// Import OpenZeppelin's AccessControl and alias it to avoid naming conflicts.
import { AccessControl as OZAccessControl } from "@openzeppelin/contracts/access/AccessControl.sol";

contract WPJK is OZAccessControl {
    bytes32 public constant ADMIN_ROLE = keccak256("ADMIN_ROLE");

    constructor() {
        // Set up roles using OpenZeppelin's AccessControl functions.
        _setupRole(DEFAULT_ADMIN_ROLE, msg.sender);
        _setupRole(ADMIN_ROLE, msg.sender);
    }

    // Add your additional functions and state variables here.
}