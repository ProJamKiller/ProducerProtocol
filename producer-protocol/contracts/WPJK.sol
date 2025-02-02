// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/AccessControl.sol";

contract WPJK is ERC20, AccessControl {
    bytes32 public constant BRIDGE_ROLE = keccak256("BRIDGE_ROLE");
    address public bridgeContract;

    // Events for improved transparency
    event BridgeContractUpdated(address indexed newBridgeContract);
    event TokensMinted(address indexed to, uint256 amount);
    event TokensBurned(address indexed from, uint256 amount);

    constructor() ERC20("Wrapped PJK", "wPJK") {
        _setupRole(DEFAULT_ADMIN_ROLE, msg.sender);
    }

    // Update bridge contract address
    function updateBridgeContract(address _bridgeContract) external onlyRole(DEFAULT_ADMIN_ROLE) {
        bridgeContract = _bridgeContract;
        emit BridgeContractUpdated(_bridgeContract);
    }

    // Mint tokens with enhanced logging
    function mint(address to, uint256 amount) external onlyRole(BRIDGE_ROLE) {
        _mint(to, amount);
        emit TokensMinted(to, amount);
    }

    // Burn tokens with enhanced logging
    function burn(address from, uint256 amount) external onlyRole(BRIDGE_ROLE) {
        _burn(from, amount);
        emit TokensBurned(from, amount);
    }

    // Function to check if an address has the Bridge Role
    function isBridgeRole(address account) public view returns (bool) {
        return hasRole(BRIDGE_ROLE, account);
    }

    // Override supportsInterface for AccessControl compatibility
    function supportsInterface(bytes4 interfaceId) public view virtual override(ERC20, AccessControl) returns (bool) {
        return super.supportsInterface(interfaceId);
    }
}