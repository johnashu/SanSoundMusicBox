// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.18;

// Partner NfTs

// Let’s say 1 0n1 owned- you can merge 1 San for a new NFT (music box) 

// 1 world of women owned - merge 1 San for music box 

// 4 x mutant ape owned - merge 1 San

// But after those three are taken - 3 San for merge into music box

// 1 allowable per NFT collection, and only claimable once per ID


import "src/MusicBox721.sol";
import "src/interfaces/SanSound/ISanOriginNFT.sol";

contract MusicBox is MusicBox721 {
    uint256 public constant NUM_OF_LEVELS = 6;

    ISanOriginNFT public sanOriginNFT;

    mapping(SoulboundLevel soulboundLevel => uint256 price) public levelPrice;
    mapping(uint256 tokenId => SoulboundLevel soulboundLevel) public currentTokenLevel;
    mapping(uint originTokenId => bool isUsed) public usedOriginTokens;
    mapping(uint tokenId => uint256[MAX_TOKENS_REQUIRED_TO_MINT] sanOriginTokenIds) public tokensMergedFrom;

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

    function _checkUserOwnsTokens(uint256[] memory tokenIds)
        private
        view
        returns (bool)
    {
        unchecked {
            for (uint256 i = 0; i < tokenIds.length; i++) {
                if (usedOriginTokens[tokenIds[i]] != false) revert TokenAlreadyUsed();
                if (sanOriginNFT.ownerOf(tokenIds[i]) != _msgSender()) revert TokenNotOwned();
            }
        }
        return true;
    }

    function _checkOriginTokensNotBound(uint256[] memory tokenIds) private view returns (bool) {
        unchecked {
            for (uint256 i = 0; i < tokenIds.length; i++) {
                uint256 tokenLevel = sanOriginNFT.tokenLevel(tokenIds[i]);
                if (tokenLevel != 0) revert TokenAlreadyBoundInOrigin();
            }
        }
        return true;
    }


    function _checkMintConstraints(uint[] memory tokenIds )  private {
        if (tokenIds.length > MAX_TOKENS_REQUIRED_TO_MINT) revert MintAmountTokensIncorrect();
        if (currentTokenId >= MAX_SUPPLY) revert MaxSupplyReached();
        if (userMinted[_msgSender()] > MAX_MINT_PER_ADDRESS) revert ExceedsMaxMintPerAddress();
        
    }

    function _addToUsedIds(uint[] memory tokenIds )  private {
        unchecked {
            for (uint256 i = 0; i < tokenIds.length; i++) {
                usedOriginTokens[tokenIds[i]] = true;
            }
        }
        
    }

    function _addNewTokenData(uint[] memory tokenIds )  private {
        uint256 newTokenId = _getTokenIdAndIncrement();
        userMinted[_msgSender()] += 1;
        tokensMergedFrom[newTokenId] = tokenIds;
        currentTokenLevel[newTokenId] = _newLevel;
    }
    function mergeTokens(uint256[MAX_TOKENS_REQUIRED_TO_MINT] memory tokenIds, SoulboundLevel _newLevel)
        public
        payable
        returns (bool)
    {
        // Checks
        _checkMintConstraints(tokenIds);
        _checkUserOwnsTokens(tokenIds);
        _checkOriginTokensNotBound(tokenIds);
        
        
        // Effects
        // Pass checks, map the ids so they cannot be used again.
        _addToUsedIds(tokenIds);

        // Update token data.
        _addNewTokenData(tokenIds);

        // Soulbind  status
        soulbind(newTokenId, _newLevel);

        // Interactions
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

        function approve(address to, uint256 tokenId) public override(IERC721, ERC721) {
            // allow merged to be approved
            if (currentTokenLevel[tokenId] > SoulboundLevel.Merged)  revert CannotApproveSoulboundToken(to, tokenId);
            super.approve(to, tokenId);

    }

    function _beforeTokenTransfer(address from, address to, uint256 tokenId) internal override {
        // allow Merged to be transfered.
        if (currentTokenLevel[tokenId] > SoulboundLevel.Merged) revert CannotTransferSoulboundToken(from, to, tokenId);
        super._beforeTokenTransfer(from, to, tokenId);
    }


    modifier tokenOwned(uint256 _tokenID) {
        if (ownerOf(_tokenID) != _msgSender()) revert TokenNotOwned();
        _;
    }
}
