// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import "@thirdweb-dev/contracts/base/ERC20Base.sol";

/**
 * @title Mojo Token
 * @notice ERC20 token for Producer Protocol on Optimism.
 *         This token replaces PJK and supports artist and fan interactions.
 */
contract Mojo is ERC20Base {
    // Total token supply: 1,000,000 MOJO (with 18 decimals)
    uint256 public constant TOTAL_SUPPLY = 1_000_000 * 1e18;
    // Designator to identify the main Producer Protocol token.
    string public constant DESIGNATOR = "ProducerProtocolMainToken";

    enum Role { Artist, Fan }

    struct Contribution {
        address contributor;
        Role role;
        uint256 percentage;
        uint256 timestamp;
    }

    // Mapping to record contributions for each project by its unique ID.
    mapping(bytes32 => Contribution[]) public projectContributions;

    event ContributionRecorded(
        bytes32 indexed projectId,
        address indexed contributor,
        Role role,
        uint256 percentage
    );
    event TokensBurned(address indexed burner, uint256 amount);

    /**
     * @notice Constructor mints the total supply to the initial owner.
     * @param _initialOwner The address that will own the initial supply.
     */
    constructor(address _initialOwner)
        ERC20Base(_initialOwner, "Mojo", "MOJO")
    {
        _mint(_initialOwner, TOTAL_SUPPLY);
    }

    /**
     * @notice Allocates tokens from the treasury to a contributor and records their contribution.
     * @param to The address receiving tokens.
     * @param amount The amount to allocate.
     * @param projectId The unique identifier for the project.
     * @param role The contributor's role (Artist or Fan).
     * @param percentage The percentage allocation for this contribution.
     */
    function allocateContribution(
        address to,
        uint256 amount,
        bytes32 projectId,
        Role role,
        uint256 percentage
    ) external onlyOwner {
        require(to != address(0), "Invalid recipient");
        require(balanceOf(owner()) >= amount, "Insufficient treasury tokens");

        _transfer(owner(), to, amount);

        projectContributions[projectId].push(
            Contribution({
                contributor: to,
                role: role,
                percentage: percentage,
                timestamp: block.timestamp
            })
        );

        emit ContributionRecorded(projectId, to, role, percentage);
    }

    /**
     * @notice Allows token holders to burn their tokens.
     * @param amount The amount of tokens to burn.
     */
    function burn(uint256 amount) external override {
        _burn(msg.sender, amount);
        emit TokensBurned(msg.sender, amount);
    }
}