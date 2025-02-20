// SPDX-License-Identifier: MIT
pragma solidity ^0.8.15;

contract DummyL1Bridge {
    event BridgeOutCompleted(uint256 tokenId, address l1Recipient);

    function completeBridgeOut(uint256 tokenId, address l1Recipient) external {
        // For now, just emit an event. Add your logic later if needed.
        emit BridgeOutCompleted(tokenId, l1Recipient);
    }
}