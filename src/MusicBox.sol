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
    address sanOriginAddress = 0x33333333333371718A3C2bB63E5F3b94C9bC13bE;

    mapping(SoulboundLevel soulboundLevel => uint256 price) public levelPrice;
    mapping(uint256 tokenId => SoulboundLevel soulboundLevel) public currentTokenLevel;
    mapping(uint tokenId => uint256[] TokenIds) public tokensMergedFrom;
    mapping(address contractAddress => bool isValidContract) public isPartner;
    mapping(address contractAddress => mapping(uint originTokenId => bool isUsed)) public usedTokens;

    constructor(
        string memory _name,
        string memory _symbol,
        string memory _contractURI,
        string memory _baseURI,
        uint256[] memory _levelPrices
    ) MusicBox721(_name, _symbol, _contractURI, _baseURI) {
        levelPrice[SoulboundLevel.Unbound] = _levelPrices[0];
        levelPrice[SoulboundLevel.Merged] = _levelPrices[1];
        levelPrice[SoulboundLevel.Citizen] = _levelPrices[2];
        levelPrice[SoulboundLevel.Defiant] = _levelPrices[3];
        levelPrice[SoulboundLevel.Hanzoku] = _levelPrices[4];
        levelPrice[SoulboundLevel.The33] = _levelPrices[5];
    }

    /// @notice Update a partner address
    /// @dev true is valid and false is not
    /// @param _partnerAddress Address of the Partner Contract.
    /// @param _isValid true to be valid (add) or false to be invlaid
    function updatePartnerAddress(address _partnerAddress, bool _isValid) public onlyOwner {
        isPartner[_partnerAddress] = _isValid;
    }

    /// @notice Check Contract is valid
    /// @dev Revert if not a valid contract.
    /// @param _partnerAddress Address of the Partner Contract.
    function _checkContractAddress(address _partnerAddress) private pure {
        if (!isPartner[_partnerAddress]) revert contractAddressNotValid();
    }

    function _checkUserOwnsTokens(uint256[] memory tokenIds, address _tokenAddress) private view returns (bool) {
        unchecked {
            for (uint256 i = 0; i < tokenIds.length; i++) {
                if (usedTokens[_tokenAddress][tokenIds[i]] != false) revert TokenAlreadyUsed();
                if (ISanOriginNFT(_tokenAddress).ownerOf(tokenIds[i]) != _msgSender()) revert TokenNotOwned();
            }
        }
        return true;
    }

    function _checkOriginTokensNotBound(uint256[] memory tokenIds) private view returns (bool) {
        unchecked {
            for (uint256 i = 0; i < tokenIds.length; i++) {
                uint256 tokenLevel = ISanOriginNFT(sanOriginAddress).tokenLevel(tokenIds[i]);
                if (tokenLevel != 0) revert TokenAlreadyBoundInOrigin();
            }
        }
        return true;
    }

    function _checkMintConstraints(uint256[] memory tokenIds, uint8 tokensRequired) private {
        if (tokenIds.length > tokensRequired) revert MintAmountTokensIncorrect();
        if (currentTokenId >= MAX_SUPPLY) revert MaxSupplyReached();
        if (userMinted[_msgSender()] > MAX_MINT_PER_ADDRESS) revert ExceedsMaxMintPerAddress();
    }

    function _addToUsedIds(uint256[] memory tokenIds, address _tokenAddress) private {
        unchecked {
            for (uint256 i = 0; i < tokenIds.length; i++) {
                usedTokens[_tokenAddress][tokenIds[i]] = true;
            }
        }
    }

    function _addNewTokenData(uint256 newTokenId, uint256[] memory tokenIds, SoulboundLevel _newLevel) private {
        userMinted[_msgSender()] += 1;
        tokensMergedFrom[newTokenId] = tokenIds;
        currentTokenLevel[newTokenId] = _newLevel;
    }

    function mergeTokens(uint256[] memory tokenIds, SoulboundLevel _newLevel, address _contractAddress)
        public
        payable
        returns (bool)
    {
        uint8 tokensRequired = ORIGIN_TOKENS_REQUIRED_TO_MINT;
        // Checks
        if (_contractAddress != sanOriginAddress) {
            tokensRequired = PARTNER_TOKENS_REQUIRED_TO_MINT;
            _checkContractAddress(_contractAddress);
        } 

        _checkMintConstraints(tokenIds, tokensRequired);
        _checkUserOwnsTokens(tokenIds, _contractAddress);
        _checkOriginTokensNotBound(tokenIds);

        // Effects
        // Pass checks, map the ids so they cannot be used again.
        _addToUsedIds(tokenIds, _contractAddress);

        // New token Id
        uint256 newTokenId = _getTokenIdAndIncrement();
        // Update token data.
        _addNewTokenData(newTokenId, tokenIds, _newLevel);

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
        if (currentTokenLevel[tokenId] > SoulboundLevel.Merged) revert CannotApproveSoulboundToken(to, tokenId);
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
