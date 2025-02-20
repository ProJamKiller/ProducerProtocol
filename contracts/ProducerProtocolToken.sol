// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@thirdweb-dev/contracts/base/ERC20Base.sol";


contract ProducerProtocolToken is ERC20Base, 
    // Role definitions
    bytes32 public constant ARTIST_ROLE = keccak256("ARTIST_ROLE");
    bytes32 public constant FAN_ROLE = keccak256("FAN_ROLE");
    bytes32 public constant MINTER_ROLE = keccak256("MINTER_ROLE");

    // Tracking contribution percentages
    struct Contribution {
        address contributor;
        uint256 artistPercentage;
        uint256 fanPercentage;
        uint256 timestamp;
    }

    // Mapping of project contributions
    mapping(bytes32 => Contribution[]) public projectContributions;

    // Events for tracking contributions
    event ArtistContribution(
        bytes32 indexed projectId, 
        address indexed artist, 
        uint256 percentage
    );

    event FanContribution(
        bytes32 indexed projectId, 
        address indexed fan, 
        uint256 percentage
    );

    constructor(
        string memory _name,
        string memory _symbol,
        address _initialOwner
    ) ERC20Base(_name, _symbol, _initialOwner) {
        _setupRole(DEFAULT_ADMIN_ROLE, _initialOwner);
        _setupRole(MINTER_ROLE, _initialOwner);
    }

    // Mint tokens with role-based restrictions
    function mintArtistTokens(
        address to, 
        uint256 amount, 
        bytes32 projectId, 
        uint256 percentage
    ) external onlyRole(MINTER_ROLE) {
        _mint(to, amount);
        
        projectContributions[projectId].push(Contribution({
            contributor: to,
            artistPercentage: percentage,
            fanPercentage: 0,
            timestamp: block.timestamp
        }));

        emit ArtistContribution(projectId, to, percentage);
    }

    // Mint fan tokens
    function mintFanTokens(
        address to, 
        uint256 amount, 
        bytes32 projectId, 
        uint256 percentage
    ) external onlyRole(MINTER_ROLE) {
        _mint(to, amount);
        
        projectContributions[projectId].push(Contribution({
            contributor: to,
            artistPercentage: 0,
            fanPercentage: percentage,
            timestamp: block.timestamp
        }));

        emit FanContribution(projectId, to, percentage);
    }

    // Get project contributions
    function getProjectContributions(bytes32 projectId) 
        external 
        view 
        returns (Contribution[] memory) 
    {
        return projectContributions[projectId];
    }

    // Additional governance and utility functions can be added here
}