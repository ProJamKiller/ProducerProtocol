// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@thirdweb-dev/contracts/base/ERC20Base.sol";

/**
 * @title ProducerProtocolToken
 * @dev An ERC20 token using thirdweb’s ERC20Base, with role-based minting for Artists and Fans.
 */
contract ProducerProtocolToken is ERC20Base {
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
    event ArtistContribution(bytes32 indexed projectId, address indexed artist, uint256 percentage);
    event FanContribution(bytes32 indexed projectId, address indexed fan, uint256 percentage);

    /**
     * @notice Constructor sets up the initial roles and token details.
     * @param _name Token name.
     * @param _symbol Token symbol.
     * @param _initialOwner Address that will receive default admin and minter roles.
     */
    constructor(
        string memory _name,
        string memory _symbol,
        address _initialOwner
    ) ERC20Base(_name, _symbol, _initialOwner) {
        _setupRole(DEFAULT_ADMIN_ROLE, _initialOwner);
        _setupRole(MINTER_ROLE, _initialOwner);
    }

    /**
     * @notice Mint tokens for an artist, track the contribution percentage.
     * @param to Address receiving tokens.
     * @param amount Number of tokens to mint.
     * @param projectId Unique ID for the project.
     * @param percentage Percentage assigned to the artist for this contribution.
     */
    function mintArtistTokens(
        address to,
        uint256 amount,
        bytes32 projectId,
        uint256 percentage
    ) external onlyRole(MINTER_ROLE) {
        _mint(to, amount);

        projectContributions[projectId].push(
            Contribution({
                contributor: to,
                artistPercentage: percentage,
                fanPercentage: 0,
                timestamp: block.timestamp
        );

        emit ArtistContribution(projectId, to, percentage);
    }

    /**
     * @notice Mint tokens for a fan, track the contribution percentage.
     * @param to Address receiving tokens.
     * @param amount Number of tokens to mint.
     * @param projectId Unique ID for the project.
     * @param percentage Percentage assigned to the fan for this contribution.
     */
    function mintFanTokens(
        address to,
        uint256 amount,
        bytes32 projectId,
        uint256 percentage
    ) external onlyRole(MINTER_ROLE) {
        _mint(to, amount);

        projectContributions[projectId].push(
            Contribution({
                contributor: to,
                artistPercentage: 0,
                fanPercentage: percentage,
                timestamp: block.timestamp
            })
        );

        emit FanContribution(projectId, to, percentage);
    }

    /**
     * @notice Get all contributions for a given project ID.
     * @param projectId Unique identifier of the project.
     * @return An array of Contribution structs detailing each contribution made.
     */
    function getProjectContributions(bytes32 projectId)
        external
        view
        returns (Contribution[] memory)
    {
        return projectContributions[projectId];
    }