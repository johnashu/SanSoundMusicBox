// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.18;

import {ITokenLevels} from "src/interfaces/Levels/ITokenLevels.sol";
import {ISanctuary} from "src/interfaces/Sanctuary/ISanctuary.sol";

import {IBase721} from "src/interfaces/ERC721/IBase721.sol";
import {Ownable} from "src/utils/Ownable.sol";
import {Test} from "lib/forge-std/src/Test.sol";

abstract contract TokenLevels is ITokenLevels, Ownable, IBase721, Test {
    uint256 public constant NUM_OF_LEVELS = 6;

    mapping(TokenLevel tokenLevel => uint256 price) public levelPrice;
    mapping(uint256 tokenId => TokenLevel tokenLevel) public tokenLevel;

    constructor(uint256[NUM_OF_LEVELS] memory _levelPrices) {
        unchecked {
            for (uint256 i; i < NUM_OF_LEVELS; i++) {
                levelPrice[TokenLevel(i)] = _levelPrices[i];
            }
        }
    }

    /// @dev Owner can set the levelPrices
    /// @param _newPrices An array of length(NUM_OF_LEVELS) of New level prices.
    function setLevelPrices(uint256[NUM_OF_LEVELS] calldata _newPrices) public onlyOwner {
        unchecked {
            uint256 previousPrice;
            for (uint256 i; i < NUM_OF_LEVELS; ++i) {
                if (_newPrices[i] < previousPrice) {
                    revert LevelPricesNotIncreasing();
                }

                levelPrice[TokenLevel(i)] = _newPrices[i];
                previousPrice = _newPrices[i];
                if (i == NUM_OF_LEVELS - 1) {
                    break;
                }
            }
        }
    }

    /// @notice Find the Max Soulbound level of a user.
    /// @dev Explain to a developer any extra details.
    /// @param _owner Address to check the Level of.
    /// @return userMaxLevel The Maximum level of that owner.
    function userMaxTokenLevel(address _owner) public view returns (TokenLevel) {
        uint256 tokenCount = ISanctuary(address(this)).balanceOf(_owner);
        if (tokenCount == 0) return TokenLevel.Unbound;

        TokenLevel userMaxLevel;
        uint256[] memory tokenIds = ISanctuary(address(this)).tokensOwnedByAddress(_owner);
        unchecked {
            for (uint256 i; i < tokenCount; i++) {
                TokenLevel level = tokenLevel[tokenIds[i]];
                if (level > userMaxLevel) userMaxLevel = level;
            }
        }
        return userMaxLevel;
    }

    /// @notice Upgrade a tokens Level
    /// @dev Public facing function to upgrade a tokens level.
    /// @param _tokenId Token to upgrade.
    /// @param _newLevel New level
    function upgradeTokenLevel(uint256 _tokenId, TokenLevel _newLevel) public payable {
        if (ISanctuary(address(this)).ownerOf(_tokenId) != msg.sender) revert TokenNotOwned();
        if (_newLevel == TokenLevel.Unbound) revert TokenUnBound();

        TokenLevel currentLevel = tokenLevel[_tokenId];
        if (currentLevel >= _newLevel) revert LevelAlreadyReached();

        _upgradeTokenLevel(_tokenId, _newLevel, currentLevel);
    }

    /// @dev Check prices and do the upgrade.. Used by minting functions and publicly explosed function below.
    /// @param _tokenId Token to upgrade.
    /// @param _newLevel New level
    /// @param _currentLevel current level
    function _upgradeTokenLevel(uint256 _tokenId, TokenLevel _newLevel, TokenLevel _currentLevel) internal {
        __upgradeTokenLevel(_tokenId, _newLevel, _currentLevel);
        emit TokenLevelUpdated(msg.sender, _tokenId, _newLevel, _currentLevel);
    }

    /// @dev Check prices and do the upgrade.. Used by minting functions and publicly explosed function below.
    /// @param _tokenId Token to upgrade.
    /// @param _newLevel New level
    /// @param _currentLevel current level
    function __upgradeTokenLevel(uint256 _tokenId, TokenLevel _newLevel, TokenLevel _currentLevel) internal {
        tokenLevel[_tokenId] = _newLevel;
        unchecked {
            uint256 price = levelPrice[_newLevel] - levelPrice[_currentLevel];
            if (msg.value != price) revert IncorrectPaymentAmount();
        }
    }
}
