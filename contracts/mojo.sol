// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import "@thirdweb-dev/contracts/base/ERC20Base.sol";

/**
 * @title Mojo Token
 * @notice ERC20 token for Producer Protocol on Optimism with dynamic minting.
 *         Replaces PJK via swap/burn mechanism.
 */
contract Mojo is ERC20Base {
    string public constant DESIGNATOR = "ProducerProtocolMainToken";
    address public swapContract; // Address allowed to mint Mojo
    uint256 public swapRatio = 1; // 1 PJK = 1 Mojo (adjustable)

    enum Role { Artist, Fan }

    struct Contribution {
        address contributor;
        Role role;
        uint256 percentage;
        uint256 timestamp;
    }

    mapping(bytes32 => Contribution[]) public projectContributions;

    event ContributionRecorded(bytes32 indexed projectId, address indexed contributor, Role role, uint256 percentage);
    event TokensBurned(address indexed burner, uint256 amount);
    event TokensMintedForSwap(address indexed user, uint256 pjkAmount, uint256 mojoAmount);

    /**
     * @notice Constructor sets initial owner and swap contract.
     * @param _initialOwner Address with owner privileges (e.g., 0x2af17552f27021666BcD3E5Ba65f68CB5Ec217fc).
     */
    constructor(address _initialOwner) 
        ERC20Base(_initialOwner, "Mojo", "MOJO") 
    {
        require(_initialOwner == 0x2af17552f27021666BcD3E5Ba65f68CB5Ec217fc, "Invalid initial owner");
        swapContract = _initialOwner; // Initially owner, update to swap contract later
    }

    /**
     * @notice Allocate tokens and record contribution (owner-only).
     */
    function allocateContribution(
        address to,
        uint256 amount,
        bytes32 projectId,
        Role role,
        uint256 percentage
    ) external onlyOwner {
        require(to != address(0), "Invalid recipient");
        _mint(to, amount); // Dynamic minting for contributions
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
     * @notice Mint Mojo for PJK swapped/burned (called by swap contract).
     * @param user Address receiving Mojo.
     * @param pjkAmount Amount of PJK burned on Polygon.
     */
    function mintForSwap(address user, uint256 pjkAmount) external onlySwapContract {
        uint256 mojoAmount = pjkAmount * swapRatio;
        _mint(user, mojoAmount);
        emit TokensMintedForSwap(user, pjkAmount, mojoAmount);
    }

    /**
     * @notice Burn Mojo tokens.
     */
    function burn(uint256 amount) external override {
        _burn(msg.sender, amount);
        emit TokensBurned(msg.sender, amount);
    }

    /**
     * @notice Update swap contract address.
     */
    function setSwapContract(address _swapContract) external onlyOwner {
        require(_swapContract != address(0), "Invalid address");
        swapContract = _swapContract;
    }

    /**
     * @notice Update swap ratio.
     */
    function setSwapRatio(uint256 _ratio) external onlyOwner {
        require(_ratio > 0, "Invalid ratio");
        swapRatio = _ratio;
    }

    modifier onlySwapContract() {
        require(msg.sender == swapContract, "Only swap contract allowed");
        _;
    }
}