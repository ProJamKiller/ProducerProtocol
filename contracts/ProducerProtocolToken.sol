// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import "@thirdweb-dev/contracts/base/ERC20Base.sol";
import "@openzeppelin/contracts/access/AccessControl.sol";

contract ProducerProtocolToken is ERC20Base, AccessControl {
    // Role definitions
    bytes32 public constant ARTIST_ROLE = keccak256("ARTIST_ROLE");
    bytes32 public constant FAN_ROLE = keccak256("FAN_ROLE");
    bytes32 public constant MINTER_ROLE = keccak256("MINTER_ROLE");

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
    event RoleGranted(bytes32 indexed role, address indexed account);
    event RoleRevoked(bytes32 indexed role, address indexed account);

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
    )
        ERC20Base(_name, _symbol, _initialOwner)
    {
        require(_initialOwner != address(0), "Initial owner cannot be zero address");
        
        _setupRole(DEFAULT_ADMIN_ROLE, _initialOwner);
        _setupRole(MINTER_ROLE, _initialOwner);
        _setupRole(ARTIST_ROLE, _initialOwner);
        _setupRole(FAN_ROLE, _initialOwner);
    }

    /**
     * @notice Mint tokens for an artist and track the contribution percentage.
     * @param to Address to receive the tokens
     * @param amount Amount of tokens to mint
     * @param projectId Unique identifier for the project
     * @param percentage Contribution percentage for the artist
     */
    function mintArtistTokens(
        address to,
        uint256 amount,
        bytes32 projectId,
        uint256 percentage
    )
        external
        onlyRole(MINTER_ROLE)
    {
        require(to != address(0), "Cannot mint to zero address");
        require(amount > 0, "Amount must be greater than zero");
        require(percentage <= 100, "Artist percentage must be between 0 and 100");
        require(hasRole(ARTIST_ROLE, to), "Contributor must have ARTIST_ROLE");

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

    /**
     * @notice Mint tokens for a fan and track the contribution percentage.
     * @param to Address to receive the tokens
     * @param amount Amount of tokens to mint
     * @param projectId Unique identifier for the project
     * @param percentage Contribution percentage for the fan
     */
    function mintFanTokens(
        address to,
        uint256 amount,
        bytes32 projectId,
        uint256 percentage
    )
        external
        onlyRole(MINTER_ROLE)
    {
        require(to != address(0), "Cannot mint to zero address");
        require(amount > 0, "Amount must be greater than zero");
        require(percentage <= 100, "Fan percentage must be between 0 and 100");
        require(hasRole(FAN_ROLE, to), "Contributor must have FAN_ROLE");

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
     * @param projectId Unique identifier for the project
     * @return Array of Contribution structs
     */
    function getProjectContributions(bytes32 projectId)
        external
        view
        returns (Contribution[] memory)
    {
        return projectContributions[projectId];
    }

    /**
     * @notice Add an address to the ARTIST_ROLE
     * @param account Address to receive the role
     */
    function addArtistRole(address account) external onlyRole(DEFAULT_ADMIN_ROLE) {
        require(account != address(0), "Cannot grant role to zero address");
        grantRole(ARTIST_ROLE, account);
        emit RoleGranted(ARTIST_ROLE, account);
    }

    /**
     * @notice Add an address to the FAN_ROLE
     * @param account Address to receive the role
     */
    function addFanRole(address account) external onlyRole(DEFAULT_ADMIN_ROLE) {
        require(account != address(0), "Cannot grant role to zero address");
        grantRole(FAN_ROLE, account);
        emit RoleGranted(FAN_ROLE, account);
    }

    /**
     * @notice Add an address to the MINTER_ROLE
     * @param account Address to receive the role
     */
    function addMinterRole(address account) external onlyRole(DEFAULT_ADMIN_ROLE) {
        require(account != address(0), "Cannot grant role to zero address");
        grantRole(MINTER_ROLE, account);
        emit RoleGranted(MINTER_ROLE, account);
    }

    /**
     * @notice Remove an address from the ARTIST_ROLE
     * @param account Address to remove the role from
     */
    function removeArtistRole(address account) external onlyRole(DEFAULT_ADMIN_ROLE) {
        revokeRole(ARTIST_ROLE, account);
        emit RoleRevoked(ARTIST_ROLE, account);
    }

    /**
     * @notice Remove an address from the FAN_ROLE
     * @param account Address to remove the role from
     */
    function removeFanRole(address account) external onlyRole(DEFAULT_ADMIN_ROLE) {
        revokeRole(FAN_ROLE, account);
        emit RoleRevoked(FAN_ROLE, account);
    }

    /**
     * @notice Remove an address from the MINTER_ROLE
     * @param account Address to remove the role from
     */
    function removeMinterRole(address account) external onlyRole(DEFAULT_ADMIN_ROLE) {
        revokeRole(MINTER_ROLE, account);
        emit RoleRevoked(MINTER_ROLE, account);
    }
}
module.exports = {
  solidity: {
    compilers: [
      {
        version: "0.8.20",
      },
      {
        version: "0.8.17",
      }
    ],
  },
  // ... rest of your config
};
require("@nomicfoundation/hardhat-toolbox");

module.exports = {
  solidity: {
    compilers: [
      {
        version: "0.8.17",
        settings: {
          optimizer: {
            enabled: true,
            runs: 200,
          },
        },
      },
    ],
  },
  networks: {
    hardhat: {
      chainId: 1337,
    },
  },
};
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import "@thirdweb-dev/contracts/base/ERC20Base.sol";
import "@openzeppelin/contracts/access/AccessControl.sol";

contract ProducerProtocolToken is ERC20Base, AccessControl {
    bytes32 public constant ARTIST_ROLE = keccak256("ARTIST_ROLE");
    bytes32 public constant FAN_ROLE = keccak256("FAN_ROLE");
    bytes32 public constant MINTER_ROLE = keccak256("MINTER_ROLE");

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
    )
        ERC20Base(_name, _symbol, _initialOwner)
    {
        require(_initialOwner != address(0), "Initial owner cannot be zero address");
        
        _setupRole(DEFAULT_ADMIN_ROLE, _initialOwner);
        _setupRole(MINTER_ROLE, _initialOwner);
        _setupRole(ARTIST_ROLE, _initialOwner);
        _setupRole(FAN_ROLE, _initialOwner);
    }

    function mintArtistTokens(
        address to,
        uint256 amount,
        bytes32 projectId,
        uint256 percentage
    )
        external
        onlyRole(MINTER_ROLE)
    {
        require(to != address(0), "Cannot mint to zero address");
        require(amount > 0, "Amount must be greater than zero");
        require(percentage <= 100, "Artist percentage must be between 0 and 100");
        require(hasRole(ARTIST_ROLE, to), "Contributor must have ARTIST_ROLE");

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
    )
        external
        onlyRole(MINTER_ROLE)
    {
        require(to != address(0), "Cannot mint to zero address");
        require(amount > 0, "Amount must be greater than zero");
        require(percentage <= 100, "Fan percentage must be between 0 and 100");
        require(hasRole(FAN_ROLE, to), "Contributor must have FAN_ROLE");

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

    function addArtistRole(address account) external onlyRole(DEFAULT_ADMIN_ROLE) {
        require(account != address(0), "Cannot grant role to zero address");
        grantRole(ARTIST_ROLE, account);
    }

    function addFanRole(address account) external onlyRole(DEFAULT_ADMIN_ROLE) {
        require(account != address(0), "Cannot grant role to zero address");
        grantRole(FAN_ROLE, account);
    }

    function addMinterRole(address account) external onlyRole(DEFAULT_ADMIN_ROLE) {
        require(account != address(0), "Cannot grant role to zero address");
        grantRole(MINTER_ROLE, account);
    }
}
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import "@thirdweb-dev/contracts/base/ERC20Base.sol";
import "@openzeppelin/contracts/access/AccessControl.sol";

contract ProducerProtocolToken is ERC20Base, AccessControl {
    bytes32 public constant ARTIST_ROLE = keccak256("ARTIST_ROLE");
    bytes32 public constant FAN_ROLE = keccak256("FAN_ROLE");
    bytes32 public constant MINTER_ROLE = keccak256("MINTER_ROLE");

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
    )
        ERC20Base(_name, _symbol, _initialOwner)
    {
        require(_initialOwner != address(0), "Initial owner cannot be zero address");
        
        _setupRole(DEFAULT_ADMIN_ROLE, _initialOwner);
        _setupRole(MINTER_ROLE, _initialOwner);
        _setupRole(ARTIST_ROLE, _initialOwner);
        _setupRole(FAN_ROLE, _initialOwner);
    }

    function mintArtistTokens(
        address to,
        uint256 amount,
        bytes32 projectId,
        uint256 percentage
    )
        external
        onlyRole(MINTER_ROLE)
    {
        require(to != address(0), "Cannot mint to zero address");
        require(amount > 0, "Amount must be greater than zero");
        require(percentage <= 100, "Artist percentage must be between 0 and 100");
        require(hasRole(ARTIST_ROLE, to), "Contributor must have ARTIST_ROLE");

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
    )
        external
        onlyRole(MINTER_ROLE)
    {
        require(to != address(0), "Cannot mint to zero address");
        require(amount > 0, "Amount must be greater than zero");
        require(percentage <= 100, "Fan percentage must be between 0 and 100");
        require(hasRole(FAN_ROLE, to), "Contributor must have FAN_ROLE");

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

    function addArtistRole(address account) external onlyRole(DEFAULT_ADMIN_ROLE) {
        require(account != address(0), "Cannot grant role to zero address");
        grantRole(ARTIST_ROLE, account);
    }

    function addFanRole(address account) external onlyRole(DEFAULT_ADMIN_ROLE) {
        require(account != address(0), "Cannot grant role to zero address");
        grantRole(FAN_ROLE, account);
    }

    function addMinterRole(address account) external onlyRole(DEFAULT_ADMIN_ROLE) {
        require(account != address(0), "Cannot grant role to zero address");
        grantRole(MINTER_ROLE, account);
    }
}
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import "@thirdweb-dev/contracts/base/ERC20Base.sol";
import "@openzeppelin/contracts/access/AccessControl.sol";

contract ProducerProtocolToken is ERC20Base, AccessControl {
    // Role definitions
    bytes32 public constant ARTIST_ROLE = keccak256("ARTIST_ROLE");
    bytes32 public constant FAN_ROLE = keccak256("FAN_ROLE");
    bytes32 public constant MINTER_ROLE = keccak256("MINTER_ROLE");

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
    event RoleGranted(bytes32 indexed role, address indexed account);
    event RoleRevoked(bytes32 indexed role, address indexed account);

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
    )
        ERC20Base(_name, _symbol, _initialOwner)
    {
        require(_initialOwner != address(0), "Initial owner cannot be zero address");
        
        _setupRole(DEFAULT_ADMIN_ROLE, _initialOwner);
        _setupRole(MINTER_ROLE, _initialOwner);
        _setupRole(ARTIST_ROLE, _initialOwner);
        _setupRole(FAN_ROLE, _initialOwner);
    }

    /**
     * @notice Mint tokens for an artist and track the contribution percentage.
     * @param to Address to receive the tokens
     * @param amount Amount of tokens to mint
     * @param projectId Unique identifier for the project
     * @param percentage Contribution percentage for the artist
     */
    function mintArtistTokens(
        address to,
        uint256 amount,
        bytes32 projectId,
        uint256 percentage
    )
        external
        onlyRole(MINTER_ROLE)
    {
        require(to != address(0), "Cannot mint to zero address");
        require(amount > 0, "Amount must be greater than zero");
        require(percentage <= 100, "Artist percentage must be between 0 and 100");
        require(hasRole(ARTIST_ROLE, to), "Contributor must have ARTIST_ROLE");

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

    /**
     * @notice Mint tokens for a fan and track the contribution percentage.
     * @param to Address to receive the tokens
     * @param amount Amount of tokens to mint
     * @param projectId Unique identifier for the project
     * @param percentage Contribution percentage for the fan
     */
    function mintFanTokens(
        address to,
        uint256 amount,
        bytes32 projectId,
        uint256 percentage
    )
        external
        onlyRole(MINTER_ROLE)
    {
        require(to != address(0), "Cannot mint to zero address");
        require(amount > 0, "Amount must be greater than zero");
        require(percentage <= 100, "Fan percentage must be between 0 and 100");
        require(hasRole(FAN_ROLE, to), "Contributor must have FAN_ROLE");

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
     * @param projectId Unique identifier for the project
     * @return Array of Contribution structs
     */
    function getProjectContributions(bytes32 projectId)
        external
        view
        returns (Contribution[] memory)
    {
        return projectContributions[projectId];
    }

    /**
     * @notice Add an address to the ARTIST_ROLE
     * @param account Address to receive the role
     */
    function addArtistRole(address account) external onlyRole(DEFAULT_ADMIN_ROLE) {
        require(account != address(0), "Cannot grant role to zero address");
        grantRole(ARTIST_ROLE, account);
        emit RoleGranted(ARTIST_ROLE, account);
    }

    /**
     * @notice Add an address to the FAN_ROLE
     * @param account Address to receive the role
     */
    function addFanRole(address account) external onlyRole(DEFAULT_ADMIN_ROLE) {
        require(account != address(0), "Cannot grant role to zero address");
        grantRole(FAN_ROLE, account);
        emit RoleGranted(FAN_ROLE, account);
    }

    /**
     * @notice Add an address to the MINTER_ROLE
     * @param account Address to receive the role
     */
    function addMinterRole(address account) external onlyRole(DEFAULT_ADMIN_ROLE) {
        require(account != address(0), "Cannot grant role to zero address");
        grantRole(MINTER_ROLE, account);
        emit RoleGranted(MINTER_ROLE, account);
    }

    /**
     * @notice Remove an address from the ARTIST_ROLE
     * @param account Address to remove the role from
     */
    function removeArtistRole(address account) external onlyRole(DEFAULT_ADMIN_ROLE) {
        revokeRole(ARTIST_ROLE, account);
        emit RoleRevoked(ARTIST_ROLE, account);
    }

    /**
     * @notice Remove an address from the FAN_ROLE
     * @param account Address to remove the role from
     */
    function removeFanRole(address account) external onlyRole(DEFAULT_ADMIN_ROLE) {
        revokeRole(FAN_ROLE, account);
        emit RoleRevoked(FAN_ROLE, account);
    }

    /**
     * @notice Remove an address from the MINTER_ROLE
     * @param account Address to remove the role from
     */
    function removeMinterRole(address account) external onlyRole(DEFAULT_ADMIN_ROLE) {
        revokeRole(MINTER_ROLE, account);
        emit RoleRevoked(MINTER_ROLE, account);
    }
}
module.exports = {
  solidity: {
    compilers: [
      {
        version: "0.8.20",
      },
      {
        version: "0.8.17",
      }
    ],
  },
  // ... rest of your config
};
require("@nomicfoundation/hardhat-toolbox");

module.exports = {
  solidity: {
    compilers: [
      {
        version: "0.8.17",
        settings: {
          optimizer: {
            enabled: true,
            runs: 200,
          },
        },
      },
    ],
  },
  networks: {
    hardhat: {
      chainId: 1337,
    },
  },
};
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import "@thirdweb-dev/contracts/base/ERC20Base.sol";
import "@openzeppelin/contracts/access/AccessControl.sol";

contract ProducerProtocolToken is ERC20Base, AccessControl {
    bytes32 public constant ARTIST_ROLE = keccak256("ARTIST_ROLE");
    bytes32 public constant FAN_ROLE = keccak256("FAN_ROLE");
    bytes32 public constant MINTER_ROLE = keccak256("MINTER_ROLE");

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
    )
        ERC20Base(_name, _symbol, _initialOwner)
    {
        require(_initialOwner != address(0), "Initial owner cannot be zero address");
        
        _setupRole(DEFAULT_ADMIN_ROLE, _initialOwner);
        _setupRole(MINTER_ROLE, _initialOwner);
        _setupRole(ARTIST_ROLE, _initialOwner);
        _setupRole(FAN_ROLE, _initialOwner);
    }

    function mintArtistTokens(
        address to,
        uint256 amount,
        bytes32 projectId,
        uint256 percentage
    )
        external
        onlyRole(MINTER_ROLE)
    {
        require(to != address(0), "Cannot mint to zero address");
        require(amount > 0, "Amount must be greater than zero");
        require(percentage <= 100, "Artist percentage must be between 0 and 100");
        require(hasRole(ARTIST_ROLE, to), "Contributor must have ARTIST_ROLE");

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
    )
        external
        onlyRole(MINTER_ROLE)
    {
        require(to != address(0), "Cannot mint to zero address");
        require(amount > 0, "Amount must be greater than zero");
        require(percentage <= 100, "Fan percentage must be between 0 and 100");
        require(hasRole(FAN_ROLE, to), "Contributor must have FAN_ROLE");

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

    function addArtistRole(address account) external onlyRole(DEFAULT_ADMIN_ROLE) {
        require(account != address(0), "Cannot grant role to zero address");
        grantRole(ARTIST_ROLE, account);
    }

    function addFanRole(address account) external onlyRole(DEFAULT_ADMIN_ROLE) {
        require(account != address(0), "Cannot grant role to zero address");
        grantRole(FAN_ROLE, account);
    }

    function addMinterRole(address account) external onlyRole(DEFAULT_ADMIN_ROLE) {
        require(account != address(0), "Cannot grant role to zero address");
        grantRole(MINTER_ROLE, account);
    }
}
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import "@thirdweb-dev/contracts/base/ERC20Base.sol";
import "@openzeppelin/contracts/access/AccessControl.sol";

contract ProducerProtocolToken is ERC20Base, AccessControl {
    bytes32 public constant ARTIST_ROLE = keccak256("ARTIST_ROLE");
    bytes32 public constant FAN_ROLE = keccak256("FAN_ROLE");
    bytes32 public constant MINTER_ROLE = keccak256("MINTER_ROLE");

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
    )
        ERC20Base(_name, _symbol, _initialOwner)
    {
        require(_initialOwner != address(0), "Initial owner cannot be zero address");
        
        _setupRole(DEFAULT_ADMIN_ROLE, _initialOwner);
        _setupRole(MINTER_ROLE, _initialOwner);
        _setupRole(ARTIST_ROLE, _initialOwner);
        _setupRole(FAN_ROLE, _initialOwner);
    }

    function mintArtistTokens(
        address to,
        uint256 amount,
        bytes32 projectId,
        uint256 percentage
    )
        external
        onlyRole(MINTER_ROLE)
    {
        require(to != address(0), "Cannot mint to zero address");
        require(amount > 0, "Amount must be greater than zero");
        require(percentage <= 100, "Artist percentage must be between 0 and 100");
        require(hasRole(ARTIST_ROLE, to), "Contributor must have ARTIST_ROLE");

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
    )
        external
        onlyRole(MINTER_ROLE)
    {
        require(to != address(0), "Cannot mint to zero address");
        require(amount > 0, "Amount must be greater than zero");
        require(percentage <= 100, "Fan percentage must be between 0 and 100");
        require(hasRole(FAN_ROLE, to), "Contributor must have FAN_ROLE");

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

    function addArtistRole(address account) external onlyRole(DEFAULT_ADMIN_ROLE) {
        require(account != address(0), "Cannot grant role to zero address");
        grantRole(ARTIST_ROLE, account);
    }

    function addFanRole(address account) external onlyRole(DEFAULT_ADMIN_ROLE) {
        require(account != address(0), "Cannot grant role to zero address");
        grantRole(FAN_ROLE, account);
    }

    function addMinterRole(address account) external onlyRole(DEFAULT_ADMIN_ROLE) {
        require(account != address(0), "Cannot grant role to zero address");
        grantRole(MINTER_ROLE, account);
    }
}


```solidity
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import "@thirdweb-dev/contracts/base/ERC20Base.sol";
import "@openzeppelin/contracts/access/AccessControl.sol";

contract ProducerProtocolToken is ERC20Base {
    // Role definitions
    bytes32 public constant ARTIST_ROLE = keccak256("ARTIST_ROLE");
    bytes32 public constant FAN_ROLE = keccak256("FAN_ROLE");
    bytes32 public constant MINTER_ROLE = keccak256("MINTER_ROLE");

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
    )
        ERC20Base(_name, _symbol, _initialOwner)
    {
        _setupRole(DEFAULT_ADMIN_ROLE, _initialOwner);
        _setupRole(MINTER_ROLE, _initialOwner);
        _setupRole(ARTIST_ROLE, _initialOwner);
        _setupRole(FAN_ROLE, _initialOwner);
    }

    /**
     * @notice Mint tokens for an artist and track the contribution percentage.
     */
    function mintArtistTokens(
        address to,
        uint256 amount,
        bytes32 projectId,
        uint256 percentage
    )
        external
        onlyRole(MINTER_ROLE)
    {
        require(percentage <= 100, "Artist percentage must be between 0 and 100");
        require(hasRole(ARTIST_ROLE, to), "Contributor must have ARTIST_ROLE");

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

    /**
     * @notice Mint tokens for a fan and track the contribution percentage.
     */
    function mintFanTokens(
        address to,
        uint256 amount,
        bytes32 projectId,
        uint256 percentage
    )
        external
        onlyRole(MINTER_ROLE)
    {
        require(percentage <= 100, "Fan percentage must be between 0 and 100");
        require(hasRole(FAN_ROLE, to), "Contributor must have FAN_ROLE");

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
     */
    function getProjectContributions(bytes32 projectId)
        external
        view
        returns (Contribution[] memory)
    {
        return projectContributions[projectId];
    }

    /**
     * @notice Add an address to the ARTIST_ROLE
     */
    function addArtistRole(address account) external only
{
  "dependencies": {
    "@openzeppelin/contracts": "4.8.0",
    "ethers": "^5.7.2"
  },
  "devDependencies": {
    "@nomicfoundation/hardhat-toolbox": "^2.0.2",
    "hardhat": "^2.12.0"
  }
}
require("@nomicfoundation/hardhat-toolbox");

/** @type import('hardhat/config').HardhatUserConfig */
module.exports = {
  solidity: {
    version: "0.8.17",
    settings: {
      optimizer: {
        enabled: true,
        runs: 200
      }
    }
  },
  networks: {
    hardhat: {
      chainId: 1337
    }
  }
};
{
  "name": "producer-protocol",
  "version": "1.0.0",
  "description": "",
  "main": "index.js",
  "scripts": {
    "test": "hardhat test",
    "compile": "hardhat compile"
  },
  "dependencies": {
    "@openzeppelin/contracts": "4.8.0",
    "@thirdweb-dev/contracts": "^3.8.0",
    "ethers": "^5.7.2"
  },
  "devDependencies": {
    "@nomicfoundation/hardhat-toolbox": "^2.0.2",
    "hardhat": "^2.12.0"
  }
}
require("@nomicfoundation/hardhat-toolbox");

module.exports = {
  solidity: {
    version: "0.8.17",
    settings: {
      optimizer: {
        enabled: true,
        runs: 200
      }
    }
  },
  networks: {
    hardhat: {
      chainId: 1337
    }
  }
};
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import "@thirdweb-dev/contracts/base/ERC20Base.sol";
import "@openzeppelin/contracts/access/AccessControl.sol";

contract ProducerProtocolToken is ERC20Base, AccessControl {
    bytes32 public constant ARTIST_ROLE = keccak256("ARTIST_ROLE");
    bytes32 public constant FAN_ROLE = keccak256("FAN_ROLE");
    bytes32 public constant MINTER_ROLE = keccak256("MINTER_ROLE");

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
    )
        ERC20Base(_name, _symbol, _initialOwner)
    {
        require(_initialOwner != address(0), "Initial owner cannot be zero address");
        
        _setupRole(DEFAULT_ADMIN_ROLE, _initialOwner);
        _setupRole(MINTER_ROLE, _initialOwner);
        _setupRole(ARTIST_ROLE, _initialOwner);
        _setupRole(FAN_ROLE, _initialOwner);
    }

    function mintArtistTokens(
        address to,
        uint256 amount,
        bytes32 projectId,
        uint256 percentage
    )
        external
        onlyRole(MINTER_ROLE)
    {
        require(to != address(0), "Cannot mint to zero address");
        require(amount > 0, "Amount must be greater than zero");
        require(percentage <= 100, "Artist percentage must be between 0 and 100");
        require(hasRole(ARTIST_ROLE, to), "Contributor must have ARTIST_ROLE");

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
    )
        external
        onlyRole(MINTER_ROLE)
    {
        require(to != address(0), "Cannot mint to zero address");
        require(amount > 0, "Amount must be greater than zero");
        require(percentage <= 100, "Fan percentage must be between 0 and 100");
        require(hasRole(FAN_ROLE, to), "Contributor must have FAN_ROLE");

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

    function addArtistRole(address account) external onlyRole(DEFAULT_ADMIN_ROLE) {
        require(account != address(0), "Cannot grant role to zero address");
        grantRole(ARTIST_ROLE, account);
    }

    function addFanRole(address account) external onlyRole(DEFAULT_ADMIN_ROLE) {
        require(account != address(0), "Cannot grant role to zero address");
        grantRole(FAN_ROLE, account);
    }

    function addMinterRole(address account) external onlyRole(DEFAULT_ADMIN_ROLE) {
        require(account != address(0), "Cannot grant role to zero address");
        grantRole(MINTER_ROLE, account);
    }
}


```solidity
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import "@thirdweb-dev/contracts/base/ERC20Base.sol";
import "@openzeppelin/contracts/access/AccessControl.sol";

contract ProducerProtocolToken is ERC20Base {
    // Role definitions
    bytes32 public constant ARTIST_ROLE = keccak256("ARTIST_ROLE");
    bytes32 public constant FAN_ROLE = keccak256("FAN_ROLE");
    bytes32 public constant MINTER_ROLE = keccak256("MINTER_ROLE");

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
    )
        ERC20Base(_name, _symbol, _initialOwner)
    {
        _setupRole(DEFAULT_ADMIN_ROLE, _initialOwner);
        _setupRole(MINTER_ROLE, _initialOwner);
        _setupRole(ARTIST_ROLE, _initialOwner);
        _setupRole(FAN_ROLE, _initialOwner);
    }

    /**
     * @notice Mint tokens for an artist and track the contribution percentage.
     */
    function mintArtistTokens(
        address to,
        uint256 amount,
        bytes32 projectId,
        uint256 percentage
    )
        external
        onlyRole(MINTER_ROLE)
    {
        require(percentage <= 100, "Artist percentage must be between 0 and 100");
        require(hasRole(ARTIST_ROLE, to), "Contributor must have ARTIST_ROLE");

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

    /**
     * @notice Mint tokens for a fan and track the contribution percentage.
     */
    function mintFanTokens(
        address to,
        uint256 amount,
        bytes32 projectId,
        uint256 percentage
    )
        external
        onlyRole(MINTER_ROLE)
    {
        require(percentage <= 100, "Fan percentage must be between 0 and 100");
        require(hasRole(FAN_ROLE, to), "Contributor must have FAN_ROLE");

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
     */
    function getProjectContributions(bytes32 projectId)
        external
        view
        returns (Contribution[] memory)
    {
        return projectContributions[projectId];
    }

    /**
     * @notice Add an address to the ARTIST_ROLE
     */
    function addArtistRole(address account) external only