//SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

/**
 * @title SanSoundMusicBox
 * @author Maffaz
 */

interface SANSoulbindable {
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
    error InvalidSoulbindCredit();
    error SoulbindingDisabled();
    error LevelAlreadyReached();
    error LevelFourFull();
    error LevelPricesNotIncreasing();
    error TokenAlreadyUsed();
    error TokenAlreadyBoundInOrigin();
}
