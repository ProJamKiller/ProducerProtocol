// SPDX-License-Identifier: MIT
pragma solidity ^0.8.15;

// Import OpenZeppelin's ERC721 and Ownable. (Make sure these dependencies are installed.)
import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

/* 
 * Minimal inline version of OpenZeppelin's ReentrancyGuard.
 * This prevents reentrant calls in functions marked with the nonReentrant modifier.
 */
abstract contract ReentrancyGuard {
    uint256 private constant _NOT_ENTERED = 1;
    uint256 private constant _ENTERED = 2;
    uint256 private _status;

    constructor() {
        _status = _NOT_ENTERED;
    }

    modifier nonReentrant() {
        require(_status != _ENTERED, "ReentrancyGuard: reentrant call");
        _status = _ENTERED;
        _;
        _status = _NOT_ENTERED;
    }
}

/*
 * Interface for the Optimism Cross Domain Messenger.
 * This allows our contract to verify cross-chain calls.
 */
interface ICrossDomainMessenger {
    function sendMessage(address target, bytes calldata message, uint32 gasLimit) external;
    function xDomainSender() external view returns (address);
}

/*
 * ProducerProtocolOptimism is an ERC721 NFT contract with bridging functionality.
 * It supports:
 *   - bridgeMint: Minting tokens on Optimism via a validated call from L1 through the messenger.
 *   - bridgeOut: Burning tokens on Optimism and sending a message to L1 for the bridge-out process.
 *   - adminMint: Direct minting by the contract owner.
 */
contract ProducerProtocolOptimism is ERC721, Ownable, ReentrancyGuard {
    // Address of the Optimism Cross Domain Messenger.
    address public crossDomainMessenger;
    // Trusted L1 contract address that initiates the bridge.
    address public l1Contract;
    // Next token ID for admin minting.
    uint256 public nextTokenId;
    // Gas limit for sending messages to L1.
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
     * @notice Bridge mint an NFT on Optimism via a validated L1 call.
     * @param tokenId The token ID (should match the L1 record).
     * @param recipient The address receiving the NFT.
     * Requirements:
     *   - Must be called by the cross-domain messenger.
     *   - The originating L1 sender (via xDomainSender) must match our trusted l1Contract.
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
     * @notice Bridge out (burn) an NFT on Optimism and notify the L1 contract.
     * @param tokenId The token ID to bridge out.
     * @param l1Recipient The recipient address on L1 to receive/unlock the token.
     * Requirements:
     *   - Caller must be the token owner or an approved operator.
     */
    function bridgeOut(uint256 tokenId, address l1Recipient) external nonReentrant {
        require(_isApprovedOrOwner(msg.sender, tokenId), "Caller is not owner nor approved");
        _burn(tokenId);
        emit TokenBridgedOut(tokenId, l1Recipient);

        // Prepare the message for the L1 contract.
        bytes memory message = abi.encodeWithSignature("completeBridgeOut(uint256,address)", tokenId, l1Recipient);
        ICrossDomainMessenger(crossDomainMessenger).sendMessage(l1Contract, message, L1_GAS_LIMIT);
    }

    /**
     * @notice Allows the owner to mint a new NFT directly on Optimism.
     * @param recipient The address that receives the NFT.
     */
    function adminMint(address recipient) external onlyOwner nonReentrant {
        uint256 tokenId = nextTokenId;
        nextTokenId++;
        _safeMint(recipient, tokenId);
    }
}