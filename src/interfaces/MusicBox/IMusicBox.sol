//SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

/**
 * @title SanSound MusicBox
 * @author Maffaz
 */

interface IMusicBox {
    enum SoulboundLevel {
        Unbound,
        Merged,
        Citizen,
        Defiant,
        Hanzoku,
        The33
    }

    event SoulBound(
        address indexed soulAccount,
        uint256 indexed tokenID,
        SoulboundLevel indexed newLevel,
        SoulboundLevel previousLevel
    );

    error CannotApproveSoulboundToken(address to, uint256 tokenId);
    error CannotTransferSoulboundToken(address from, address to, uint256 tokenId);

    error InvalidNumberOfLevelPrices();
    error LevelAlreadyReached();
    error LevelPricesNotIncreasing();
    error TokenAlreadyUsed();
    error TokenAlreadyBoundInOrigin();
    error contractAddressNotValid();
}
