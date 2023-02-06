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
    address public constant sanOriginAddress = 0x33333333333371718A3C2bB63E5F3b94C9bC13bE;

    mapping(TokenAccessLevel tokenAccessLevel => uint256 price) public levelPrice;
    mapping(uint256 tokenId => TokenAccessLevel tokenAccessLevel) public currentTokenLevel;
    mapping(uint tokenId => uint256[] TokenIds) public tokensMergedFrom;

    mapping(address contractAddress => bool isValid) public isValidContract;
    mapping(address contractAddress => uint8 _numTokens) public numPartnerTokensRequired;
    mapping(address contractAddress => mapping(uint originTokenId => bool isUsed)) public usedTokens;

    constructor(
        string memory _name,
        string memory _symbol,
        string memory _contractURI,
        string memory _baseURI,
        uint256[NUM_OF_LEVELS] memory _levelPrices
    ) MusicBox721(_name, _symbol, _contractURI, _baseURI) {
        levelPrice[TokenAccessLevel.Unbound] = _levelPrices[0];
        levelPrice[TokenAccessLevel.Merged] = _levelPrices[1];
        levelPrice[TokenAccessLevel.Citizen] = _levelPrices[2];
        levelPrice[TokenAccessLevel.Defiant] = _levelPrices[3];
        levelPrice[TokenAccessLevel.Hanzoku] = _levelPrices[4];
        levelPrice[TokenAccessLevel.The33] = _levelPrices[5];
        isValidContract[sanOriginAddress] = true;
    }

    /// @notice Update a partner address
    /// @dev sanOriginAddress is added in construction so we dont want to change it.  Same with 0 address.
    /// @param _partnerAddress Address of the Partner Contract.
    /// @param _isValid true to be valid (add) or false to be invlaid
    function updatePartnerAddress(address _partnerAddress, uint8 numTokensRequired, bool _isValid) public onlyOwner {
        if (_partnerAddress == sanOriginAddress || _partnerAddress == address(0)) revert contractAddressNotValid();
        isValidContract[_partnerAddress] = _isValid;
    }

    /// @notice Check Contract is valid
    /// @dev Revert if not a valid contract.
    /// @param _partnerAddress Address of the Partner Contract.
    function _checkContractAddress(address _partnerAddress) private view {
        if (_partnerAddress == sanOriginAddress || _partnerAddress == address(0) || !isValidContract[_partnerAddress]) {
            revert contractAddressNotValid();
        }
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

    function _checkMintConstraints(uint256[] memory tokenIds, uint8 tokensRequired) private view {
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

    function _addNewTokenData(uint256 newTokenId, uint256[] memory tokenIds, TokenAccessLevel _newLevel) private {
        unchecked {
            userMinted[_msgSender()] += 1;
        }
        tokensMergedFrom[newTokenId] = tokenIds;
        currentTokenLevel[newTokenId] = _newLevel;
    }

    function _processChecks(uint256[] calldata tokenIds, uint8 requiredTokens, address _address) private {
        _checkMintConstraints(tokenIds, requiredTokens);
        _checkUserOwnsTokens(tokenIds, _address);
        _checkOriginTokensNotBound(tokenIds);

        // Pass checks, map the ids so they cannot be used again.
        _addToUsedIds(tokenIds, _address);
    }

    /// @notice Merge Tokens from San Origin.
    /// @param originTokenIds San Origin Id(s) to merge
    /// @return _newLevel Access level requested
    function mintFromSanOrigin(uint256[] calldata originTokenIds, TokenAccessLevel _newLevel)
        public
        payable
        returns (bool)
    {
        _processChecks(originTokenIds, ORIGIN_TOKENS_REQUIRED_TO_MINT, sanOriginAddress);
        return _mergeMint(originTokenIds, _newLevel);
    }

    /// @notice Merge and mint from a partner, amounts may vary for the checks.
    /// @param originTokenIds San Origin Id(s) to merge
    /// @return _newLevel Access level requested
    /// @param partnerTokenIds TokenIds from the Partner NFTs to check against
    /// @param _contractAddress Token Contract address to call for checks.

    function mintFromPartner(
        uint256[] calldata originTokenIds,
        TokenAccessLevel _newLevel,
        uint256[] calldata partnerTokenIds,
        address _contractAddress
    ) public payable returns (bool) {
        _checkContractAddress(_contractAddress);
        _processChecks(originTokenIds, PARTNER_TOKENS_REQUIRED_TO_MINT, sanOriginAddress);
        _processChecks(partnerTokenIds, numPartnerTokensRequired[_contractAddress], _contractAddress);

        return _mergeMint(originTokenIds, _newLevel);
    }

    function _mergeMint(uint256[] calldata originTokenIds, TokenAccessLevel _newLevel) private returns (bool) {
         uint256 newTokenId = _getTokenIdAndIncrement();
        _addNewTokenData(newTokenId, originTokenIds, _newLevel);
        _safeMint(_msgSender(), newTokenId);
        return true;
    }

    function upgradeAccessLevel(uint256 _tokenId, TokenAccessLevel _newLevel)
        public
        payable
        tokenOwned(_tokenId)
        returns (bool)
    {
        TokenAccessLevel curLevel = currentTokenLevel[_tokenId];
        if (_newLevel == TokenAccessLevel.Unbound) revert TokenUnBound();
        if (curLevel >= _newLevel) revert LevelAlreadyReached();

        unchecked {
            uint256 price = levelPrice[_newLevel] - levelPrice[curLevel];
            if (msg.value != price) revert IncorrectPaymentAmount();
        }
        currentTokenLevel[_tokenId] = _newLevel;
        _approve(address(0), _tokenId);
        emit AccessLevelUpdated(_msgSender(), _tokenId, _newLevel, curLevel);
        return true;
    }

    function setLevelPrices(uint256[NUM_OF_LEVELS] calldata _newPrices) external onlyOwner {
        if (_newPrices.length != NUM_OF_LEVELS) revert InvalidNumberOfLevelPrices();

        unchecked {
            uint256 previousPrice;
            for (uint256 i; i < NUM_OF_LEVELS; i++) {
                if (_newPrices[i] <= previousPrice) {
                    revert LevelPricesNotIncreasing();
                }
                levelPrice[TokenAccessLevel(i + 1)] = _newPrices[i];
                previousPrice = _newPrices[i];
            }
        }
    }

    function userMaxTokenAccessLevel(address _owner) external view returns (TokenAccessLevel) {
        uint256 tokenCount = balanceOf(_owner);
        if (tokenCount == 0) return TokenAccessLevel.Unbound;

        TokenAccessLevel userMaxLevel;
        unchecked {
            for (uint256 i; i < tokenCount; i++) {
                TokenAccessLevel level = currentTokenLevel[tokenOfOwnerByIndex(_owner, i)];
                if (level > userMaxLevel) userMaxLevel = level;
            }
        }
        return userMaxLevel;
    }

    function tokenURI(uint256 _tokenId) public view override returns (string memory) {
        if (!_exists(_tokenId)) revert TokenDoesNotExist();
        return string(
            abi.encodePacked(
                baseURI,
                Strings.toString(uint256(currentTokenLevel[_tokenId])),
                "/",
                Strings.toString(_tokenId),
                ".json"
            )
        );
    }

    function approve(address to, uint256 tokenId) public override(IERC721, ERC721) {
        // allow merged to be approved
        if (currentTokenLevel[tokenId] > TokenAccessLevel.Merged) revert CannotApproveAccessLevel(to, tokenId);
        super.approve(to, tokenId);
    }

    function _beforeTokenTransfer(address from, address to, uint256 tokenId) internal override {
        // allow Merged to be transfered.
        if (currentTokenLevel[tokenId] > TokenAccessLevel.Merged) {
            revert CannotTransferAccessLevelUpdatedToken(from, to, tokenId);
        }
        super._beforeTokenTransfer(from, to, tokenId);
    }

    modifier tokenOwned(uint256 _tokenId) {
        if (ownerOf(_tokenId) != _msgSender()) revert TokenNotOwned();
        _;
    }

    receive() external payable {
        require(msg.value > 0, "You cannot send 0 ether");
    }
}
