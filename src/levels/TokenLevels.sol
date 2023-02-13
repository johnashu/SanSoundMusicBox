// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.18;

import {ITokenLevels} from "src/interfaces/Levels/ITokenLevels.sol";
import {ISanctuary} from "src/interfaces/Sanctuary/ISanctuary.sol";

import {IBase721} from "src/interfaces/ERC721/IBase721.sol";
import {Ownable} from "src/utils/Ownable.sol";

abstract contract TokenLevels is ITokenLevels, Ownable, IBase721 {
    uint256 public constant NUM_OF_LEVELS = 6;

    mapping(TokenLevel tokenLevel => uint256 price) public levelPrice;
    mapping(uint256 tokenId => TokenLevel tokenLevel) public currentTokenLevel;

    constructor(uint256[NUM_OF_LEVELS] memory _levelPrices) {
        for (uint256 i = 0; i < NUM_OF_LEVELS; i++) {
            levelPrice[TokenLevel(i)] = _levelPrices[i];
        }
    }

    function _upgradeTokenLevel(uint256 _tokenId, TokenLevel _newLevel, TokenLevel _curLevel) internal {
        unchecked {
            uint256 price = levelPrice[_newLevel] - levelPrice[_curLevel];
            if (msg.value != price) revert IncorrectPaymentAmount();
        }
        currentTokenLevel[_tokenId] = _newLevel;
        emit TokenLevelUpdated(_msgSender(), _tokenId, _newLevel, _curLevel);
    }

    function upgradeTokenLevel(uint256 _tokenId, TokenLevel _newLevel) public payable {
        TokenLevel curLevel = currentTokenLevel[_tokenId];
        if (ISanctuary(address(this)).ownerOf(_tokenId) != _msgSender()) revert TokenNotOwned();
        if (_newLevel == TokenLevel.Unbound) revert TokenUnBound();
        if (curLevel >= _newLevel) revert LevelAlreadyReached();
        currentTokenLevel[_tokenId] = _newLevel;
        _upgradeTokenLevel(_tokenId, _newLevel, curLevel);
    }

    function setLevelPrices(uint256[NUM_OF_LEVELS] calldata _newPrices) external onlyOwner {
        if (_newPrices.length != NUM_OF_LEVELS) revert InvalidNumberOfLevelPrices();

        unchecked {
            uint256 previousPrice;
            for (uint256 i = NUM_OF_LEVELS; i > 0; i--) {
                i -= 1;
                if (_newPrices[i] > previousPrice) {
                    revert LevelPricesNotIncreasing();
                }
                levelPrice[TokenLevel(i + 1)] = _newPrices[i];
                previousPrice = _newPrices[i];
            }
        }
    }

    function userMaxTokenLevel(address _owner) external view returns (TokenLevel) {
        uint256 tokenCount = ISanctuary(address(this)).balanceOf(_owner);
        if (tokenCount == 0) return TokenLevel.Unbound;

        TokenLevel userMaxLevel;
        uint256[] memory tokenIds = ISanctuary(address(this)).tokensOwnedByAddress(_owner);
        unchecked {
            for (uint256 i; i < tokenCount; i++) {
                TokenLevel level = currentTokenLevel[tokenIds[i]];
                if (level > userMaxLevel) userMaxLevel = level;
            }
        }
        return userMaxLevel;
    }
}
