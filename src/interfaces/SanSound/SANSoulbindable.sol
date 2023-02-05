//SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

/**
 * @title SanSoundMusicBox
 * @author Maffaz
 */

interface SANSoulbindable {
    enum SoulboundLevel {
        Merged,
        Citizen,
        Defiant,
        Hanzoku,
        The33
    }

    struct TokenData {
        uint256[] SanOriginTokenIds;
        SoulboundLevel tokenSoulboundLevel;
    }

    event SoulBound(
        address indexed soulAccount,
        uint256 indexed tokenID,
        SoulboundLevel indexed newLevel,
        SoulboundLevel previousLevel
    );

    error MintAmountTokensIncorrect();

    error CannotApproveSoulboundToken();
    error CannotTransferSoulboundToken();

    error InvalidNumberOfLevelPrices();
    error InvalidSoulbindCredit();
    error SoulbindingDisabled();
    error LevelAlreadyReached();
    error LevelFourFull();
    error LevelPricesNotIncreasing();
    error TokenAlreadyUsed();
    error TokenAlreadyBoundInOrigin();
}
