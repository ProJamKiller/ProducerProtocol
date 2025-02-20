// SPDX-License-Identifier: MIT
pragma solidity ^0.8.15;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

interface ICrossDomainMessenger {
    function sendMessage(address target, bytes calldata message, uint32 gasLimit) external;
    function xDomainSender() external view returns (address);
}

contract ProducerProtocolOptimism is ERC721, Ownable {
    // Address of Optimism's Cross Domain Messenger
    address public crossDomainMessenger;
    // Trusted L1 contract address that initiates bridge minting
    address public l1Contract;
    // Next tokenId to use for admin minting (if required)
    uint256 public nextTokenId;
    // Gas limit for sending messages to L1
    uint32 public constant L1_GAS_LIMIT = 1000000;

    event TokenBridgedIn(uint256 indexed tokenId, address indexed recipient);
    event TokenBridgedOut(uint256 indexed tokenId, address indexed l1Recipient);

    constructor(address _crossDomainMessenger, address _l1Contract)
        ERC721("Producer Protocol", "PP")
    {
        crossDomainMessenger = _crossDomainMessenger;
        l1Contract = _l1Contract;
        nextTokenId = 1;
    }

    /**
     * @notice Called by the Cross Domain Messenger to mint an NFT on Optimism.
     * @param tokenId The token ID to mint (should match the L1 record).
     * @param recipient The address that will receive the NFT.
     *
     * Requirements:
     * - Must be called via the cross domain messenger.
     * - The original sender on L1 must be the trusted L1 contract.
     */
    function bridgeMint(uint256 tokenId, address recipient) external {
        require(msg.sender == crossDomainMessenger, "Unauthorized messenger");
        require(
            ICrossDomainMessenger(crossDomainMessenger).xDomainSender() == l1Contract,
            "Invalid L1 sender"
        );
        require(!_exists(tokenId), "Token already exists");
        _safeMint(recipient, tokenId);
        emit TokenBridgedIn(tokenId, recipient);
    }

    /**
     * @notice Burns an NFT on Optimism and notifies the L1 contract to complete the bridge.
     * @param tokenId The token ID to bridge out.
     * @param l1Recipient The address on L1 to receive or unlock the NFT.
     *
     * Requirements:
     * - Caller must be the owner or approved operator for the token.
     */
    function bridgeOut(uint256 tokenId, address l1Recipient) external {
        require(_isApprovedOrOwner(msg.sender, tokenId), "Caller is not owner nor approved");
        _burn(tokenId);
        emit TokenBridgedOut(tokenId, l1Recipient);

        // Prepare the message for the L1 contract to complete the bridge out process.
        bytes memory message = abi.encodeWithSignature("completeBridgeOut(uint256,address)", tokenId, l1Recipient);
        ICrossDomainMessenger(crossDomainMessenger).sendMessage(l1Contract, message, L1_GAS_LIMIT);
    }

    /**
     * @notice Allows the owner to mint a new NFT directly on Optimism.
     * @param recipient The address that will receive the minted NFT.
     */
    function adminMint(address recipient) external onlyOwner {
        uint256 tokenId = nextTokenId;
        nextTokenId++;
        _safeMint(recipient, tokenId);
    }
}