//SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

/**
 * @title SanSound Sanctuary
 * @author Maffaz
 */

interface ITokenLevels {
    enum TokenLevel {
        Unbound,
        Rebirthed,
        Citizen,
        Defiant,
        Hanzoku,
        The33
    }

    event TokenLevelUpdated(
        address indexed TokenOwnerAddress,
        uint256 indexed tokenId,
        TokenLevel indexed newLevel,
        TokenLevel previousLevel
    );

    function upgradeTokenLevel(uint256 _tokenId, TokenLevel newLevel) external payable;

    error CannotApproveBoundedToken();
    error CannotTransferBoundedToken();

    error InvalidNumberOfLevelPrices();
    error LevelAlreadyReached();
    error LevelPricesNotIncreasing();
    error TokenAlreadyUsed();
    error TokenAlreadyBoundInOrigin();
    error contractAddressNotValid();
    error TokenUnBound();
    error TokenLevelMismatch();
}
