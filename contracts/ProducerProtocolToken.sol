// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import "@thirdweb-dev/contracts/base/ERC20Base.sol";

contract ProducerProtocolToken is ERC20Base {
    struct Contribution {
        address contributor;
        uint256 artistPercentage;
        uint256 fanPercentage;
        uint256 timestamp;
    }

    mapping(bytes32 => Contribution[]) public projectContributions;

    event ArtistContribution(bytes32 indexed projectId, address indexed artist, uint256 percentage);
    event FanContribution(bytes32 indexed projectId, address indexed fan, uint256 percentage);

    constructor(
        string memory _name,
        string memory _symbol,
        address _initialOwner
    ) ERC20Base(_initialOwner, _name, _symbol) {}

    function mintArtistTokens(
        address to,
        uint256 amount,
        bytes32 projectId,
        uint256 percentage
    ) external {
        require(msg.sender == owner(), "Caller is not the owner");
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
    ) external {
        require(msg.sender == owner(), "Caller is not the owner");
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