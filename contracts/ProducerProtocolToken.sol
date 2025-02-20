// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import "@thirdweb-dev/contracts/base/ERC20Base.sol";


contract ProducerProtocolToken is ERC20Base {
    // Contribution struct
    struct Contribution {
        address contributor;
        uint256 artistPercentage;
        uint256 fanPercentage;
        uint256 timestamp;
    }

    // Mapping of project IDs to arrays of Contribution structs
    mapping(bytes32 => Contribution[]) public projectContributions;

    // Events for logging
    event ArtistContribution(bytes32 indexed projectId, address indexed artist, uint256 percentage);
    event FanContribution(bytes32 indexed projectId, address indexed fan, uint256 percentage);

    /**
     * @notice Constructor sets up the initial roles and token details.
     * @param _name Token name.
     * @param _symbol Token symbol.
     * @param _initialOwner Address that receives the default admin and minter roles.
     */
    constructor(
        string memory _name,
        string memory _symbol,
        address _initialOwner
    ) ERC20Base(_name, _symbol, _initialOwner) {
        // No roles, just basic ERC20 setup from Thirdweb
    }

    function mintArtistTokens(
        address to,
        uint256 amount,
        bytes32 projectId,
        uint256 percentage
    ) external onlyOwner {
        require(to != address(0), "Cannot mint to zero address");
        require(amount > 0, "Amount must be greater than zero");
        require(percentage <= 100, "Artist percentage must be between 0 and 100");

        _mint(to, amount);

        projectContributions[projectId].push(
            Contribution({
                contributor: to,
                artistPercentage: percentage,
                fanPercentage: 0,
                timestamp: block.timestamp
            })
        );

        emit ArtistContribution(projectId, to, percentage);
    }

    function mintFanTokens(
        address to,
        uint256 amount,
        bytes32 projectId,
        uint256 percentage
    ) external onlyOwner {
        require(to != address(0), "Cannot mint to zero address");
        require(amount > 0, "Amount must be greater than zero");
        require(percentage <= 100, "Fan percentage must be between 0 and 100");

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

    function getProjectContributions(bytes32 projectId)
        external
        view
        returns (Contribution[] memory)
    {
        return projectContributions[projectId];
    }
}