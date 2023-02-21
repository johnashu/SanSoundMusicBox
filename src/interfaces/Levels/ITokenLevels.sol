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
        address indexed TokenOwnerAddress, uint256 indexed tokenId, TokenLevel newLevel, TokenLevel previousLevel
    );

    event TokenLevelsUpdated(
        address indexed TokenOwnerAddress, uint256[] indexed tokenIds, TokenLevel newLevel, TokenLevel previousLevel
    );

    function upgradeTokenLevel(uint256 _tokenId, TokenLevel _newLevel) external payable;

    error CannotApproveTokenLevel(address to, uint256 tokenId);
    error CannotTransferTokenLevelUpdatedToken(address from, address to, uint256 tokenId);

    error InvalidNumberOfLevelPrices();
    error LevelAlreadyReached();
    error LevelPricesNotIncreasing();
    error TokenAlreadyUsed();
    error TokenAlreadyBoundInOrigin();
    error contractAddressNotValid();
    error TokenUnBound();
    error TokenLevelMismatch();
}
