// SPDX-License-Identifier: MIT
pragma solidity ^0.8.15;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";

interface ICrossDomainMessenger {
    function sendMessage(address target, bytes calldata message, uint32 gasLimit) external;
    function xDomainSender() external view returns (address);
}

contract ProducerProtocolOptimism is ERC721, Ownable, ReentrancyGuard {
    // Address of the Optimism Cross Domain Messenger
    address public crossDomainMessenger;
    // Trusted L1 contract address initiating the bridge
    address public l1Contract;
    // Next token ID for admin minting
    uint256 public nextTokenId;
    // Gas limit for L1 message calls
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
     * @notice Bridge mint an NFT on Optimism by a validated L1 call.
     * @param tokenId The token ID (should mirror the L1 record).
     * @param recipient The address receiving the NFT.
     *
     * Requirements:
     * - Must be called by the cross-domain messenger.
     * - The originating L1 sender must match the trusted l1Contract.
     */
    function bridgeMint(uint256 tokenId, address recipient) external nonReentrant {
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
     * @notice Bridge out (burn) an NFT on Optimism and send a message to L1.
     * @param tokenId The token ID to bridge out.
     * @param l1Recipient The address on L1 to receive/unlock the token.
     *
     * Requirements:
     * - Caller must be the token owner or approved operator.
     */
    function bridgeOut(uint256 tokenId, address l1Recipient) external nonReentrant {
        require(_isApprovedOrOwner(msg.sender, tokenId), "Caller is not owner nor approved");
        _burn(tokenId);
        emit TokenBridgedOut(tokenId, l1Recipient);

        // Prepare the message for L1 processing.
        bytes memory message = abi.encodeWithSignature("completeBridgeOut(uint256,address)", tokenId, l1Recipient);
        ICrossDomainMessenger(crossDomainMessenger).sendMessage(l1Contract, message, L1_GAS_LIMIT);
    }

    /**
     * @notice Allows the owner to mint NFTs directly on Optimism.
     * @param recipient The address receiving the NFT.
     */
    function adminMint(address recipient) external onlyOwner nonReentrant {
        uint256 tokenId = nextTokenId;
        nextTokenId++;
        _safeMint(recipient, tokenId);
    }
}