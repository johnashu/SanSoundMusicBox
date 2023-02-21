//SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

/**
 * @title SanSound Sanctuary
 * @author Maffaz
 */

interface IRebirth {
    event Rebirth(address indexed TokenOwnerAddress, uint256 OriginTokenId, uint256 RebirthTokenId);
    event Rebirth(
        address indexed TokenOwnerAddress,
        uint256[] OriginTokenIds,
        uint256 startRebirthTokenId,
        uint256 endRebirthTokenId
    );
}
