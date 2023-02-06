//SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

/**
 * @title SanSound MusicBox
 * @author Maffaz
 */

interface IMusicBox {
    enum TokenAccessLevel {
        Unbound,
        Merged,
        Citizen,
        Defiant,
        Hanzoku,
        The33
    }

    event AccessLevelUpdated(
        address indexed TokenOwnerAddress,
        uint256 indexed tokenId,
        TokenAccessLevel indexed newLevel,
        TokenAccessLevel previousLevel
    );

    error CannotApproveAccessLevel(address to, uint256 tokenId);
    error CannotTransferAccessLevelUpdatedToken(address from, address to, uint256 tokenId);

    error InvalidNumberOfLevelPrices();
    error LevelAlreadyReached();
    error LevelPricesNotIncreasing();
    error TokenAlreadyUsed();
    error TokenAlreadyBoundInOrigin();
    error contractAddressNotValid();
    error TokenUnBound();

    function upgradeAccessLevel(uint256 _tokenId, TokenAccessLevel _newLevel) external payable returns (bool);
    function mintFromSanOrigin(uint256[] calldata tokenIds, TokenAccessLevel _newLevel)
        external
        payable
        returns (bool);

    function mintFromPartner(
        uint256[] calldata originTokenIds,
        TokenAccessLevel _newLevel,
        uint256[] calldata partnerTokenIds,
        address _contractAddress
    ) external payable returns (bool);
}
