// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.18;

// Partner NfTs

// Let’s say 1 0n1 owned- you can merge 1 San for a new NFT (music box)

// 1 world of women owned - merge 1 San for music box

// 4 x mutant ape owned - merge 1 San

// But after those three are taken - 3 San for merge into music box

// 1 allowable per NFT collection, and only claimable once per ID
import {TokenLevels} from "src/TokenLevels.sol";
import {Base721, IERC721, ERC721} from "src/token/ERC721/Base721.sol";
import {ISanOriginNFT} from "src/interfaces/SanSound/ISanOriginNFT.sol";
import {IMusicBox} from "src/interfaces/MusicBox/IMusicBox.sol";


contract Rebirth is TokenLevels, Base721 {
    uint8 public constant ORIGIN_TOKENS_REQUIRED_TO_MINT = 3;
    uint8 public constant WITH_PARTNER_TOKENS_REQUIRED_TO_MINT = 1;
    uint256 public constant MAX_SUPPLY = 3333;
    // uint256 public constant NUM_OF_LEVELS = 6;

    address public immutable SAN_ORIGIN_ADDRESS;
    address public immutable MUSIC_BOX_ADDRESS;
    address public immutable BURN_ADDRESS = 0x000000000000000000000000000000000000dEaD;

    // mapping(TokenLevel tokenLevel => uint256 price) public levelPrice;
    // mapping(uint256 tokenId => TokenLevel tokenLevel) public currentTokenLevel;

    mapping(address contractAddress => bool isValid) public isValidContract;
    mapping(address contractAddress => mapping(uint tokenId => bool isUsed)) public usedTokens;
    mapping(address contractAddress => uint8 _numTokens) public numPartnerTokensRequired;

    constructor(
        string memory _name,
        string memory _symbol,
        string memory _contractURI,
        string memory _baseURI,
        address _SAN_ORIGIN_ADDRESS,
        address _MUSIC_BOX_ADDRESS,
        uint256[NUM_OF_LEVELS] memory _levelPrices
    ) Base721(_name, _symbol, _contractURI, _baseURI) TokenLevels(_levelPrices) {
        // for (uint256 i = 0; i < NUM_OF_LEVELS; i++) {
        //     levelPrice[TokenLevel(i)] = _levelPrices[i];
        // }
        SAN_ORIGIN_ADDRESS = _SAN_ORIGIN_ADDRESS;
        MUSIC_BOX_ADDRESS = _MUSIC_BOX_ADDRESS;
        isValidContract[_SAN_ORIGIN_ADDRESS] = true;
    }
    /// @notice Update a partner address
    /// @dev SAN_ORIGIN_ADDRESS is added in construction so we dont want to change it.  Same with 0 address.
    /// @param _partnerAddress Address of the Partner Contract.
    /// @param _numTokensRequired tokens required to mint.
    /// @param _isValid true to be valid (add) or false to be invlaid

    function updatePartnerAddress(address _partnerAddress, uint8 _numTokensRequired, bool _isValid) public onlyOwner {
        if (_partnerAddress == SAN_ORIGIN_ADDRESS || _partnerAddress == address(0) || _numTokensRequired == 0) {
            revert contractAddressNotValid();
        }
        isValidContract[_partnerAddress] = _isValid;
        numPartnerTokensRequired[_partnerAddress] = _numTokensRequired;
    }

    /// @notice Check Contract is valid
    /// @dev Revert if not a valid contract.
    /// @param _partnerAddress Address of the Partner Contract.
    function _checkContractAddress(address _partnerAddress) private view {
        if (_partnerAddress == SAN_ORIGIN_ADDRESS || _partnerAddress == address(0) || !isValidContract[_partnerAddress])
        {
            revert contractAddressNotValid();
        }
    }

    function _checkUserOwnsTokens(uint256[] calldata tokenIds, address _tokenAddress) private view {
        unchecked {
            for (uint256 i = 0; i < tokenIds.length; i++) {
                if (usedTokens[_tokenAddress][tokenIds[i]] != false) revert TokenAlreadyUsed();
                if (IERC721(_tokenAddress).ownerOf(tokenIds[i]) != _msgSender()) revert TokenNotOwned();
            }
        }
    }

    function _checkOriginTokensAreBound(uint256[] calldata tokenIds) private view {
        unchecked {
            for (uint256 i = 0; i < tokenIds.length; i++) {
                uint256 tokenLevel = ISanOriginNFT(SAN_ORIGIN_ADDRESS).tokenLevel(tokenIds[i]);
                if (tokenLevel == 0) revert TokenUnBound();
            }
        }
    }

    function _checkOriginTokensNotBound(uint256[] calldata tokenIds) private view {
        unchecked {
            for (uint256 i = 0; i < tokenIds.length; i++) {
                uint256 tokenLevel = ISanOriginNFT(SAN_ORIGIN_ADDRESS).tokenLevel(tokenIds[i]);
                if (tokenLevel != 0) revert TokenAlreadyBoundInOrigin();
            }
        }
    }

    function _checkMintConstraints(uint256[] calldata tokenIds, uint8 tokensRequired) private view {
        if (tokenIds.length > tokensRequired) revert MintAmountTokensIncorrect();
        if (currentTokenId >= MAX_SUPPLY) revert MaxSupplyReached();
        if (userMinted[_msgSender()] > MAX_MINT_PER_ADDRESS) revert ExceedsMaxMintPerAddress();
    }

    function _addToUsedIds(uint256[] calldata tokenIds, address _tokenAddress) private {
        unchecked {
            for (uint256 i = 0; i < tokenIds.length; i++) {
                usedTokens[_tokenAddress][tokenIds[i]] = true;
            }
        }
    }

    function _processChecks(uint256[] calldata tokenIds, uint8 requiredTokens, address _address) private {
        _checkMintConstraints(tokenIds, requiredTokens);
        _checkUserOwnsTokens(tokenIds, _address);
        // Pass checks, map the ids so they cannot be used again.
        _addToUsedIds(tokenIds, SAN_ORIGIN_ADDRESS);
    }

    /// @notice Soulbind an existing SAN Origin NFT to receive a Legendary SAN Music Box NFT
    /// @dev Only Checks Soulbind and then mints
    /// @param originTokenIds San Origin Id(s) to merge
    /// @param _newLevel Token level requested
    function mintFromSoulbound(uint256[] calldata originTokenIds, TokenLevel _newLevel) external payable {
        _processChecks(originTokenIds, 1, SAN_ORIGIN_ADDRESS);
        _checkOriginTokensNotBound(originTokenIds);
        _mergeMint(originTokenIds, _newLevel, IMusicBox.MusicBoxLevel(2));
    }

    /// @notice Send three SAN Origin NFTs to the Sanctuary receive a Rare SAN Music Box NFT
    /// @param originTokenIds San Origin Id(s) to merge
    /// @param _newLevel Token level requested
    function mintFromSanOrigin(uint256[] calldata originTokenIds, TokenLevel _newLevel) external payable {
        _processChecks(originTokenIds, ORIGIN_TOKENS_REQUIRED_TO_MINT, SAN_ORIGIN_ADDRESS);
        _checkOriginTokensNotBound(originTokenIds);
        _mergeMint(originTokenIds, _newLevel, IMusicBox.MusicBoxLevel(1));
    }

    /// @notice Merge and mint from a partner, Send a Scout SAN Origin NFT to the Sanctuary, which
    /// requires one SAN Origin NFT and an accompanying partner NFT (0N1 Force, Mutant Apes, WoW, Etc),
    /// for a common SAN Music Box NFT.
    /// @param originTokenIds San Origin Id(s) to merge
    /// @param _newLevel Token level requested
    /// @param partnerTokenIds TokenIds from the Partner NFTs to check against
    /// @param _contractAddress Token Contract address to call for checks.

    function mintFromPartner(
        uint256[] calldata originTokenIds,
        TokenLevel _newLevel,
        uint256[] calldata partnerTokenIds,
        address _contractAddress
    ) external payable {
        _checkContractAddress(_contractAddress);
        _processChecks(originTokenIds, WITH_PARTNER_TOKENS_REQUIRED_TO_MINT, SAN_ORIGIN_ADDRESS);
        _processChecks(partnerTokenIds, numPartnerTokensRequired[_contractAddress], _contractAddress);
        _checkOriginTokensNotBound(originTokenIds);
        _burnOriginTokens(originTokenIds);
        _mergeMint(originTokenIds, _newLevel, IMusicBox.MusicBoxLevel(0));
    }

    function _burnOriginTokens(uint256[] calldata originTokenIds) private {
        unchecked {
            for (uint256 i = 0; i < originTokenIds.length; i++) {
                // Burn them..
                IERC721(SAN_ORIGIN_ADDRESS).transferFrom(_msgSender(), BURN_ADDRESS, originTokenIds[i]);
            }
        }
    }

    function _mintRebirthTokens(uint256[] calldata originTokenIds) private {
        unchecked {
            for (uint256 i = 0; i < originTokenIds.length; i++) {
                userMinted[_msgSender()] += 1;
                _safeMint(_msgSender(), originTokenIds[i]);
            }
        }
    }

    function _mergeMint(uint256[] calldata originTokenIds, TokenLevel _newLevel, IMusicBox.MusicBoxLevel _musicBoxLevel)
        private
    {
        uint256 newTokenId = _getTokenIdAndIncrement();
        _upgradeTokenLevel(newTokenId, _newLevel, TokenLevel(0)); // curLevel MUST be 0 to mint..
        _mintRebirthTokens(originTokenIds);
        IMusicBox(MUSIC_BOX_ADDRESS).mintFromSantuary(_msgSender(), _musicBoxLevel, originTokenIds.length);
    }

    // function _upgradeTokenLevel(uint256 _tokenId, TokenLevel _newLevel, TokenLevel _curLevel) private {
    //     unchecked {
    //         uint256 price = levelPrice[_newLevel] - levelPrice[_curLevel];
    //         if (msg.value != price) revert IncorrectPaymentAmount();
    //     }
    //     currentTokenLevel[_tokenId] = _newLevel;
    //     emit TokenLevelUpdated(_msgSender(), _tokenId, _newLevel, _curLevel);
    // }

    // function upgradeTokenLevel(uint256 _tokenId, TokenLevel _newLevel) public payable {
    //     TokenLevel curLevel = currentTokenLevel[_tokenId];
    //     if (ownerOf(_tokenId) != _msgSender()) revert TokenNotOwned();
    //     if (_newLevel == TokenLevel.Unbound) revert TokenUnBound();
    //     if (curLevel >= _newLevel) revert LevelAlreadyReached();
    //     currentTokenLevel[_tokenId] = _newLevel;

    //     _upgradeTokenLevel(_tokenId, _newLevel, curLevel);
    // }

    // function setLevelPrices(uint256[NUM_OF_LEVELS] calldata _newPrices) external onlyOwner {
    //     if (_newPrices.length != NUM_OF_LEVELS) revert InvalidNumberOfLevelPrices();

    //     unchecked {
    //         uint256 previousPrice;
    //         for (uint256 i; i < NUM_OF_LEVELS; i++) {
    //             if (_newPrices[i] <= previousPrice) {
    //                 revert LevelPricesNotIncreasing();
    //             }
    //             levelPrice[TokenLevel(i + 1)] = _newPrices[i];
    //             previousPrice = _newPrices[i];
    //         }
    //     }
    // }

    // function userMaxTokenLevel(address _owner) external view returns (TokenLevel) {
    //     uint256 tokenCount = balanceOf(_owner);
    //     if (tokenCount == 0) return TokenLevel.Unbound;

    //     TokenLevel userMaxLevel;
    //     unchecked {
    //         for (uint256 i; i < tokenCount; i++) {
    //             TokenLevel level = currentTokenLevel[tokenOfOwnerByIndex(_owner, i)];
    //             if (level > userMaxLevel) userMaxLevel = level;
    //         }
    //     }
    //     return userMaxLevel;
    // }

    function approve(address to, uint256 tokenId) public override(IERC721, ERC721) {
        // allow merged to be approved
        if (currentTokenLevel[tokenId] > TokenLevel.Merged) revert CannotApproveTokenLevel(to, tokenId);
        super.approve(to, tokenId);
    }

    function _beforeTokenTransfer(address from, address to, uint256 tokenId) internal override {
        // allow Merged to be transfered.
        if (currentTokenLevel[tokenId] > TokenLevel.Merged) {
            revert CannotTransferTokenLevelUpdatedToken(from, to, tokenId);
        }
        super._beforeTokenTransfer(from, to, tokenId);
    }

    receive() external payable {
        require(msg.value > 0, "You cannot send 0 ether");
    }
}
