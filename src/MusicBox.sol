// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.18;

// Once in a Soulbound state, the NFT acts as the holder’s token-gated login to the SAN Sound platform:

// Merged will not receive access to the SAN Sound platform.
// Citizen will receive one year of access to the SAN Sound platform. .33 ETH
// Defiant will receive LIFETIME access to the SAN Sound platform.    xxETH
// Hanzoku will receive LIFETIME access to the SAN Sound platform.  xxETH
// “The 33” will receive LIFETIME access to the SAN Sound platform. xxETH

// Fees can be changed

// Only Merged NFT's from orign are allowed - level 0 only
// 1. Soulbind 3 nfts that are at level 0 in the origin to create a new NFT MB (MusicBox) Token
// Soulbinding does not give access.  3 NFT's
// 2. Can transfer when Merged.
// 3. any level can be paid for can upgrade not downgrade.abi
// 4. no need to revoke if we can upgrade no problems.

import "src/MusicBox721.sol";
import "src/interfaces/SanSound/ISanOriginNFT.sol";

contract MusicBox is MusicBox721 {
    uint256 public constant NUM_OF_LEVELS = 6;

    ISanOriginNFT public sanOriginNFT;

    mapping(SoulboundLevel soulboundLevel => uint256 price) public levelPrice;
    mapping(uint256 tokenId => SoulboundLevel soulboundLevel) public currentTokenLevel;
    mapping(uint originTokenId => bool isUsed) public usedOriginTokens;
    mapping(uint tokenId => uint256[TOKENS_REQUIRED_TO_MINT] sanOriginTokenIds) public tokensMergedFrom;

    constructor(
        string memory _name,
        string memory _symbol,
        string memory _contractURI,
        string memory _baseURI,
        uint256[] memory _levelPrices
    ) MusicBox721(_name, _symbol, _contractURI, _baseURI) {
        sanOriginNFT = ISanOriginNFT(address(0x33333333333371718A3C2bB63E5F3b94C9bC13bE));

        levelPrice[SoulboundLevel.Unbound] = _levelPrices[0];
        levelPrice[SoulboundLevel.Merged] = _levelPrices[1];
        levelPrice[SoulboundLevel.Citizen] = _levelPrices[2];
        levelPrice[SoulboundLevel.Defiant] = _levelPrices[3];
        levelPrice[SoulboundLevel.Hanzoku] = _levelPrices[4];
        levelPrice[SoulboundLevel.The33] = _levelPrices[5];
    }

    function _checkUserOwnsTokens(uint256[TOKENS_REQUIRED_TO_MINT] memory tokenIds, address _address)
        private
        view
        notZeroAddress(_address)
        returns (bool)
    {
        unchecked {
            for (uint256 i = 0; i < TOKENS_REQUIRED_TO_MINT; i++) {
                if (usedOriginTokens[tokenIds[i]] != false) revert TokenAlreadyUsed();
                if (sanOriginNFT.ownerOf(tokenIds[i]) != _msgSender()) revert TokenNotOwned();
            }
        }
        return true;
    }

    function _checkOriginTokensNotBound(uint256[TOKENS_REQUIRED_TO_MINT] memory tokenIds) private view returns (bool) {
        unchecked {
            for (uint256 i = 0; i < TOKENS_REQUIRED_TO_MINT; i++) {
                uint256 tokenLevel = sanOriginNFT.tokenLevel(tokenIds[i]);
                if (tokenLevel != 0) revert TokenAlreadyBoundInOrigin();
            }
        }
        return true;
    }

    function mergeTokens(uint256[TOKENS_REQUIRED_TO_MINT] memory tokenIds, SoulboundLevel _newLevel)
        public
        payable
        returns (bool)
    {
        _checkUserOwnsTokens(tokenIds, _msgSender());
        _checkOriginTokensNotBound(tokenIds);
        if (tokenIds.length != TOKENS_REQUIRED_TO_MINT) revert MintAmountTokensIncorrect();
        if (currentTokenId >= MAX_SUPPLY) revert MaxSupplyReached();
        if (userMinted[_msgSender()] > MAX_MINT_PER_ADDRESS) {
            revert ExceedsMaxMintPerAddress();
        }

        // Pass checks, map the ids so they cannot be used again.
        unchecked {
            for (uint256 i = 0; i < TOKENS_REQUIRED_TO_MINT; i++) {
                usedOriginTokens[tokenIds[i]] = true;
            }
        }
        uint256 newTokenId = _getTokenIdAndIncrement();

        userMinted[_msgSender()] += 1;
        tokensMergedFrom[newTokenId] = tokenIds;
        currentTokenLevel[newTokenId] = _newLevel;
        if (_newLevel > SoulboundLevel.Unbound) {
            soulbind(newTokenId, _newLevel);
        }
        _safeMint(_msgSender(), newTokenId);

        return true;
    }

    function soulbind(uint256 _tokenID, SoulboundLevel _newLevel) public payable tokenOwned(_tokenID) {
        SoulboundLevel curLevel = currentTokenLevel[_tokenID];

        if (curLevel >= _newLevel) revert LevelAlreadyReached();

        unchecked {
            uint256 price = levelPrice[_newLevel] - levelPrice[curLevel];
            if (msg.value != price) revert IncorrectPaymentAmount();
            contractBalance += msg.value;
        }
        currentTokenLevel[_tokenID] = _newLevel;
        _approve(address(0), _tokenID);
        emit SoulBound(_msgSender(), _tokenID, _newLevel, curLevel);
    }

    function setLevelPrices(uint256[NUM_OF_LEVELS] calldata _newPrices) external onlyOwner {
        if (_newPrices.length != NUM_OF_LEVELS) revert InvalidNumberOfLevelPrices();

        unchecked {
            uint256 previousPrice;
            for (uint256 i; i < NUM_OF_LEVELS; i++) {
                if (_newPrices[i] <= previousPrice) {
                    revert LevelPricesNotIncreasing();
                }
                levelPrice[SoulboundLevel(i + 1)] = _newPrices[i];
                previousPrice = _newPrices[i];
            }
        }
    }

    function userMaxSoulboundLevel(address _owner) external view returns (SoulboundLevel) {
        uint256 tokenCount = balanceOf(_owner);
        if (tokenCount == 0) return SoulboundLevel.Unbound;

        SoulboundLevel userMaxLevel;
        unchecked {
            for (uint256 i; i < tokenCount; i++) {
                SoulboundLevel level = currentTokenLevel[tokenOfOwnerByIndex(_owner, i)];
                if (level > userMaxLevel) userMaxLevel = level;
            }
        }
        return userMaxLevel;
    }

    function tokenURI(uint256 _tokenID) public view override returns (string memory) {
        if (!_exists(_tokenID)) revert TokenDoesNotExist();
        return string(
            abi.encodePacked(
                baseURI,
                Strings.toString(uint256(currentTokenLevel[_tokenID])),
                "/",
                Strings.toString(_tokenID),
                ".json"
            )
        );
    }

    modifier notZeroAddress(address _address) {
        if (_address == address(0)) revert ZeroAddress();
        _;
    }

    modifier tokenOwned(uint256 _tokenID) {
        if (ownerOf(_tokenID) != _msgSender()) revert TokenNotOwned();
        _;
    }
}
