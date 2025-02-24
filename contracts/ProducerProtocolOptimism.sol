// SPDX-License-Identifier: MIT
pragma solidity ^0.8.15;

import "@thirdweb-dev/contracts/base/ERC721Base.sol";

contract ProducerProtocolOptimism is ERC721Base {
    address public immutable crossDomainMessenger;
    address public immutable l1Contract;
    uint256 public nextTokenId;
    uint32 public constant L1_GAS_LIMIT = 1_000_000;

    event TokenBridgedIn(uint256 indexed tokenId, address indexed recipient);
    event TokenBridgedOut(uint256 indexed tokenId, address indexed l1Recipient);

    constructor(
        address _crossDomainMessenger, 
        address _l1Contract
    ) ERC721Base(
        msg.sender,           // _defaultAdmin
        "Producer Protocol",  // _name
        "PP",                // _symbol
        address(0),          // _royaltyRecipient
        0                    // _royaltyBps
    ) {
        crossDomainMessenger = _crossDomainMessenger;
        l1Contract = _l1Contract;
        nextTokenId = 1;
    }

    function bridgeMint(
        uint256 tokenId, 
        address recipient
    ) external {
        require(
            msg.sender == crossDomainMessenger, 
            "Unauthorized messenger"
        );
        require(
            ICrossDomainMessenger(crossDomainMessenger).xDomainSender() == l1Contract,
            "Invalid L1 sender"
        );
        require(!_exists(tokenId), "Token already exists");
        
        _safeMint(recipient, tokenId);
        emit TokenBridgedIn(tokenId, recipient);
    }

    function bridgeOut(
        uint256 tokenId, 
        address l1Recipient
    ) external {
        require(
            isApprovedOrOwner(msg.sender, tokenId), 
            "Not owner or approved"
        );
        
        _burn(tokenId);
        emit TokenBridgedOut(tokenId, l1Recipient);

        bytes memory message = abi.encodeWithSignature(
            "completeBridgeOut(uint256,address)", 
            tokenId, 
            l1Recipient
        );
        
        ICrossDomainMessenger(crossDomainMessenger).sendMessage(
            l1Contract, 
            message, 
            L1_GAS_LIMIT
        );
    }

    function adminMint(address recipient) external onlyOwner {
        _safeMint(recipient, nextTokenId);
        nextTokenId++;
    }
}

interface ICrossDomainMessenger {
    function sendMessage(
        address target, 
        bytes calldata message, 
        uint32 gasLimit
    ) external;
    
    function xDomainSender() external view returns (address);
}