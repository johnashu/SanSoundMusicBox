// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.18;

// Partner NfTs

// Let’s say 1 0n1 owned- you can merge 1 San for a new NFT (music box)

// 1 world of women owned - merge 1 San for music box

// 4 x mutant ape owned - merge 1 San

// But after those three are taken - 3 San for merge into music box

// 1 allowable per NFT collection, and only claimable once per ID

import {Base721, IERC721, ERC721} from "src/token/ERC721/Base721.sol";
import {ISanOriginNFT} from "src/interfaces/SanSound/ISanOriginNFT.sol";
import {IRebirth} from "src/interfaces/Rebirth/IRebirth.sol";
import {IMusicBox} from "src/interfaces/MusicBox/IMusicBox.sol";

contract Rebirth is Base721, IRebirth {
    uint8 public constant ORIGIN_TOKENS_REQUIRED_TO_MINT = 3;
    uint8 public constant WITH_PARTNER_TOKENS_REQUIRED_TO_MINT = 1;
    uint256 public constant MAX_SUPPLY = 3333;

    uint256 public constant NUM_OF_LEVELS = 6;
    address public immutable sanOriginAddress;
    address public immutable musicBoxAddress;

    address public constant BURN_ADDRESS = 0x000000000000000000000000000000000000dEaD;

    mapping(AccessLevel tokenAccessLevel => uint256 price) public levelPrice;
    mapping(uint256 tokenId => AccessLevel tokenAccessLevel) public currentTokenLevel;

    mapping(address contractAddress => bool isValid) public isValidContract;
    mapping(address contractAddress => mapping(uint tokenId => bool isUsed)) public usedTokens;
    mapping(address contractAddress => uint8 _numTokens) public numPartnerTokensRequired;

    constructor(
        string memory _name,
        string memory _symbol,
        string memory _contractURI,
        string memory _baseURI,
        address _sanOriginAddress,
        address _musicBoxAddress,
        uint256[NUM_OF_LEVELS] memory _levelPrices
    ) Base721(_name, _symbol, _contractURI, _baseURI) {
        levelPrice[AccessLevel.Unbound] = _levelPrices[0];
        levelPrice[AccessLevel.Merged] = _levelPrices[1];
        levelPrice[AccessLevel.Citizen] = _levelPrices[2];
        levelPrice[AccessLevel.Defiant] = _levelPrices[3];
        levelPrice[AccessLevel.Hanzoku] = _levelPrices[4];
        levelPrice[AccessLevel.The33] = _levelPrices[5];
        sanOriginAddress = _sanOriginAddress;
        musicBoxAddress = _musicBoxAddress;
        isValidContract[_sanOriginAddress] = true;
    }

    /// @notice Update a partner address
    /// @dev sanOriginAddress is added in construction so we dont want to change it.  Same with 0 address.
    /// @param _partnerAddress Address of the Partner Contract.
    /// @param _numTokensRequired tokens required to mint.
    /// @param _isValid true to be valid (add) or false to be invlaid
    function updatePartnerAddress(address _partnerAddress, uint8 _numTokensRequired, bool _isValid) public onlyOwner {
        if (_partnerAddress == sanOriginAddress || _partnerAddress == address(0) || _numTokensRequired == 0) {
            revert contractAddressNotValid();
        }
        isValidContract[_partnerAddress] = _isValid;
        numPartnerTokensRequired[_partnerAddress] = _numTokensRequired;
    }

    /// @notice Check Contract is valid
    /// @dev Revert if not a valid contract.
    /// @param _partnerAddress Address of the Partner Contract.
    function _checkContractAddress(address _partnerAddress) private view {
        if (_partnerAddress == sanOriginAddress || _partnerAddress == address(0) || !isValidContract[_partnerAddress]) {
            revert contractAddressNotValid();
        }
    }

    function _checkUserOwnsTokens(uint256[] calldata tokenIds, address _tokenAddress) private view returns (bool) {
        unchecked {
            for (uint256 i = 0; i < tokenIds.length; i++) {
                if (usedTokens[_tokenAddress][tokenIds[i]] != false) revert TokenAlreadyUsed();
                if (IERC721(_tokenAddress).ownerOf(tokenIds[i]) != _msgSender()) revert TokenNotOwned();
            }
        }
    }

    function _checkOriginTokensNotBound(uint256[] calldata tokenIds) private view returns (bool) {
        unchecked {
            for (uint256 i = 0; i < tokenIds.length; i++) {
                uint256 tokenLevel = ISanOriginNFT(sanOriginAddress).tokenLevel(tokenIds[i]);
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
        _checkOriginTokensNotBound(tokenIds);

        // Pass checks, map the ids so they cannot be used again.
        _addToUsedIds(tokenIds, _address);
    }

    /// @notice Soulbind an existing SAN Origin NFT to receive a Legendary SAN Music Box NFT
    /// @dev Only Checks Soulbind and then mints
    /// @param originTokenIds San Origin Id(s) to merge
    /// @return _newLevel Access level requested
    function mintFromSoulbound(uint256[] calldata originTokenIds, AccessLevel _newLevel)
        external
        payable
        returns (bool){
            _processChecks(originTokenIds, 1, sanOriginAddress);
            unchecked {
                for (uint256 i = 0; i < originTokenIds.length; i++) {
                    
                }
            }
            
        }

    /// @notice Send three SAN Origin NFTs to the Sanctuary receive a Rare SAN Music Box NFT
    /// @param originTokenIds San Origin Id(s) to merge
    /// @return _newLevel Access level requested
    function mintFromSanOrigin(uint256[] calldata originTokenIds, AccessLevel _newLevel)
        external
        payable
        returns (bool)
    {
        _processChecks(originTokenIds, ORIGIN_TOKENS_REQUIRED_TO_MINT, sanOriginAddress);
        return _mergeMint(originTokenIds, _newLevel);
    }

    /// @notice Merge and mint from a partner, Send a Scout SAN Origin NFT to the Sanctuary, which
    /// requires one SAN Origin NFT and an accompanying partner NFT (0N1 Force, Mutant Apes, WoW, Etc), 
    /// for a common SAN Music Box NFT.
    /// @param originTokenIds San Origin Id(s) to merge
    /// @return _newLevel Access level requested
    /// @param partnerTokenIds TokenIds from the Partner NFTs to check against
    /// @param _contractAddress Token Contract address to call for checks.

    function mintFromPartner(
        uint256[] calldata originTokenIds,
        AccessLevel _newLevel,
        uint256[] calldata partnerTokenIds,
        address _contractAddress
    ) external payable returns (bool) {
        _checkContractAddress(_contractAddress);
        _processChecks(originTokenIds, WITH_PARTNER_TOKENS_REQUIRED_TO_MINT, sanOriginAddress);
        _processChecks(partnerTokenIds, numPartnerTokensRequired[_contractAddress], _contractAddress);

        return _mergeMint(originTokenIds, _newLevel);
    }

    function _burnOriginTokens(uint256[] calldata originTokenIds) private {
        unchecked {
            for (uint256 i = 0; i < originTokenIds.length; i++) {
                // Burn them..
                IERC721(sanOriginAddress).transferFrom(_msgSender(), BURN_ADDRESS, originTokenIds[i]);
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

    function _mergeMint(uint256[] calldata originTokenIds, AccessLevel _newLevel) private returns (bool) {
        uint256 newTokenId = _getTokenIdAndIncrement();
        _upgradeAccessLevel(newTokenId, _newLevel, AccessLevel(0)); // curLevel MUST be 0 to mint..
        _burnOriginTokens(originTokenIds);
        _mintRebirthTokens(originTokenIds);
        // IMusicBox(musicBoxAddress).mint(_msgSender(), musicBoxLevel);
        return true;
    }


    function _upgradeAccessLevel(uint256 _tokenId, AccessLevel _newLevel, AccessLevel _curLevel)
        private
        returns (bool)
    {
        unchecked {
            uint256 price = levelPrice[_newLevel] - levelPrice[_curLevel];
            if (msg.value != price) revert IncorrectPaymentAmount();
        }
        currentTokenLevel[_tokenId] = _newLevel;
        emit AccessLevelUpdated(_msgSender(), _tokenId, _newLevel, _curLevel);
        return true;
    }

    function upgradeAccessLevel(uint256 _tokenId, AccessLevel _newLevel) public payable returns (bool) {
        AccessLevel curLevel = currentTokenLevel[_tokenId];
        if (ownerOf(_tokenId) != _msgSender()) revert TokenNotOwned();
        if (_newLevel == AccessLevel.Unbound) revert TokenUnBound();
        if (curLevel >= _newLevel) revert LevelAlreadyReached();
        currentTokenLevel[_tokenId] = _newLevel;

        return _upgradeAccessLevel(_tokenId, _newLevel, curLevel);
    }

    function setLevelPrices(uint256[NUM_OF_LEVELS] calldata _newPrices) external onlyOwner {
        if (_newPrices.length != NUM_OF_LEVELS) revert InvalidNumberOfLevelPrices();

        unchecked {
            uint256 previousPrice;
            for (uint256 i; i < NUM_OF_LEVELS; i++) {
                if (_newPrices[i] <= previousPrice) {
                    revert LevelPricesNotIncreasing();
                }
                levelPrice[AccessLevel(i + 1)] = _newPrices[i];
                previousPrice = _newPrices[i];
            }
        }
    }

    function userMaxAccessLevel(address _owner) external view returns (AccessLevel) {
        uint256 tokenCount = balanceOf(_owner);
        if (tokenCount == 0) return AccessLevel.Unbound;

        AccessLevel userMaxLevel;
        unchecked {
            for (uint256 i; i < tokenCount; i++) {
                AccessLevel level = currentTokenLevel[tokenOfOwnerByIndex(_owner, i)];
                if (level > userMaxLevel) userMaxLevel = level;
            }
        }
        return userMaxLevel;
    }

    function approve(address to, uint256 tokenId) public override(IERC721, ERC721) {
        // allow merged to be approved
        if (currentTokenLevel[tokenId] > AccessLevel.Merged) revert CannotApproveAccessLevel(to, tokenId);
        super.approve(to, tokenId);
    }

    function _beforeTokenTransfer(address from, address to, uint256 tokenId) internal override {
        // allow Merged to be transfered.
        if (currentTokenLevel[tokenId] > AccessLevel.Merged) {
            revert CannotTransferAccessLevelUpdatedToken(from, to, tokenId);
        }
        super._beforeTokenTransfer(from, to, tokenId);
    }

    receive() external payable {
        require(msg.value > 0, "You cannot send 0 ether");
    }
}
