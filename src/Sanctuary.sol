// SPDX-License-Identifier: UNLICENSED
/// @title San Sound Sanctuary Rebirth NFT
/// @author Maffaz
pragma solidity ^0.8.18;

import {TokenLevels} from "src/levels/TokenLevels.sol";
import {Base721, IERC721, ERC721} from "src/token/ERC721/Base721.sol";
import {ISanOriginNFT} from "src/interfaces/SanSound/ISanOriginNFT.sol";
import {IMusicBox} from "src/interfaces/MusicBox/IMusicBox.sol";
import {MusicBox} from "src/MusicBox.sol";

contract Sanctuary is TokenLevels, Base721 {
    uint128 public constant ORIGIN_TOKENS_REQUIRED_TO_REBIRTH = 3;

    address public immutable SAN_ORIGIN_ADDRESS;
    address public immutable MUSIC_BOX_ADDRESS;

    mapping(address ownerOfTokens => uint256[] tokensOwned) private _tokensOwnedByAddress;
    mapping(uint256 tokenId => address tokenOwner) public ownerByToken;

    mapping(address contractAddress => mapping(uint256 tokenId => bool isUsed)) public usedTokens;

    mapping(address contractAddress => bool isValid) public isValidContract;

    constructor(
        string memory _name,
        string memory _symbol,
        string memory _contractURI,
        string memory _baseURI,
        string memory _nameMusicBox,
        string memory _symbolMusicBox,
        string memory _contractURIMusicBox,
        string memory _baseURIMusicBox,
        address _SAN_ORIGIN_ADDRESS,
        uint256[NUM_OF_LEVELS] memory _levelPrices
    ) Base721(_name, _symbol, _contractURI, _baseURI, 3333) TokenLevels(_levelPrices) {
        SAN_ORIGIN_ADDRESS = _SAN_ORIGIN_ADDRESS;
        isValidContract[_SAN_ORIGIN_ADDRESS] = true;

        MusicBox musicBox = new MusicBox( 
            _nameMusicBox, 
            _symbolMusicBox, 
            _contractURIMusicBox, 
            _baseURIMusicBox,          
            address(this),
            3333
            );

        MUSIC_BOX_ADDRESS = address(musicBox);
        musicBox.transferOwnership(msg.sender);
    }

    // GETTERS

    /// @dev Override to Support Id<>Id assigments.
    /// @param _owner Address of the tokens requested.
    /// @return tokens Tokens that address owns
    function tokensOwnedByAddress(address _owner) public view returns (uint256[] memory) {
        if (_owner == address(0)) revert ZeroAddress();
        return _tokensOwnedByAddress[_owner];
    }

    // SETTERS
    /// @notice Update a partner address
    /// @dev SAN_ORIGIN_ADDRESS is added in construction so we dont want to change it.  Same with 0 address.
    /// @param _partnerAddress Address of the Partner Contract.
    /// @param _isValid true to be valid (add) or false to be invalid
    function updatePartnerAddress(address _partnerAddress, bool _isValid) public onlyOwner {
        if (_partnerAddress == SAN_ORIGIN_ADDRESS || _partnerAddress == address(0)) {
            revert contractAddressNotValid();
        }
        isValidContract[_partnerAddress] = _isValid;
    }

    // MINT FUNCTIONS

    /// @notice Soulbind an existing SAN Origin NFT to receive a Legendary SAN Music Box NFT.
    /// @dev Checks Soulbind and then mints.
    /// @param originTokenId San Origin Id to Rebirth
    /// @param _newLevel Token level requested
    function mintFromSoulbound(uint256 originTokenId, TokenLevel _newLevel) external payable {
        _processChecks(originTokenId, SAN_ORIGIN_ADDRESS);
        _checkOriginTokensAreBound(originTokenId);
        _burnMintRebirth(originTokenId, _newLevel, IMusicBox.MusicBoxLevel.Legendary);
        emit RebirthFromSoulBound(_msgSender(), originTokenId);
    }

    /// @notice Send three SAN Origin NFTs to the Sanctuary receive a Rare SAN Music Box NFT
    /// @param originTokenIds San Origin Id(s) to Rebirth
    /// @param _newLevel Token level requested
    function mintWith3UnboundSanOrigin(uint256[] calldata originTokenIds, TokenLevel _newLevel) external payable {
        _processChecks(originTokenIds, SAN_ORIGIN_ADDRESS);
        _checkOriginTokensNotBound(originTokenIds);
        _burnMintRebirth(originTokenIds, _newLevel, IMusicBox.MusicBoxLevel.Rare);
        emit RebirthFrom3SanOrigin(_msgSender(), originTokenIds);
    }

    /// @notice Rebirth and mint from a partner, Send a Scout SAN Origin NFT to the Sanctuary, which
    /// requires one SAN Origin NFT and an accompanying partner NFT (0N1 Force, Mutant Apes, WoW, Etc),
    /// for a common SAN Music Box NFT.
    /// @param originTokenId San Origin Id(s) to Rebirth
    /// @param _newLevel Token level requested
    /// @param partnerTokenId TokenIds from the Partner NFTs to check against
    /// @param _partnerAddress Token Contract address to call for checks.
    function mintFromPartner(
        uint256 originTokenId,
        TokenLevel _newLevel,
        uint256 partnerTokenId,
        address _partnerAddress
    ) external payable {
        if (_partnerAddress == SAN_ORIGIN_ADDRESS || _partnerAddress == address(0) || !isValidContract[_partnerAddress])
        {
            revert contractAddressNotValid();
        }
        _processChecks(originTokenId, SAN_ORIGIN_ADDRESS);
        _processChecks(partnerTokenId, _partnerAddress);
        _checkOriginTokensNotBound(originTokenId);
        _burnMintRebirth(originTokenId, _newLevel, IMusicBox.MusicBoxLevel.Common);
        emit RebirthFromPartnerAndOrigin(_msgSender(), originTokenId);
    }

    // PRIVATE FUNCTIONS

    /// @dev Checks the caller owns the tokens and adds to `usedTokens` or reverts
    /// @dev used for the 'mint 3 from san origin' option.
    /// @param tokenIds Tokens to Check.
    /// @param _tokenAddress Address or contract to check (San Origin / Partners).
    function _processChecks(uint256[] calldata tokenIds, address _tokenAddress) private {
        if (tokenIds.length != ORIGIN_TOKENS_REQUIRED_TO_REBIRTH) revert MintAmountTokensIncorrect();
        if (currentTokenId >= MAX_SUPPLY) revert MaxSupplyReached();
        if (balanceOf(_msgSender()) >= MAX_MINT_PER_ADDRESS) revert ExceedsMaxMintPerAddress();
        unchecked {
            for (uint256 i = 0; i < ORIGIN_TOKENS_REQUIRED_TO_REBIRTH; i++) {
                _checkUserOwnsToken(tokenIds[i], _tokenAddress);
            }
        }
    }

    /// @dev Checks the caller owns the tokenId and adds to `usedTokens` or reverts
    /// @param tokenId Tokens to Check.
    /// @param _tokenAddress Address or contract to check (San Origin / Partners).
    function _processChecks(uint256 tokenId, address _tokenAddress) private {
        if (currentTokenId >= MAX_SUPPLY) revert MaxSupplyReached();
        if (balanceOf(_msgSender()) >= MAX_MINT_PER_ADDRESS) revert ExceedsMaxMintPerAddress();
        _checkUserOwnsToken(tokenId, _tokenAddress);
    }

    /// @dev Checks the caller owns the token and adds to `usedTokens` or reverts
    /// @param tokenId Token to Check.
    /// @param _tokenAddress Address or contract to check (San Origin / Partners).
    function _checkUserOwnsToken(uint256 tokenId, address _tokenAddress) private {
        if (usedTokens[_tokenAddress][tokenId] != false) revert TokenAlreadyUsed();
        if (IERC721(_tokenAddress).ownerOf(tokenId) != _msgSender()) revert TokenNotOwned();
        usedTokens[_tokenAddress][tokenId] = true;
    }

    /// @notice Check for SoulBound Tokens
    /// @dev Make sure all token passed are SoulBound.
    /// @param tokenId San Origin Id(s) to Rebirth.
    function _checkOriginTokensAreBound(uint256 tokenId) private view {
        if (ISanOriginNFT(SAN_ORIGIN_ADDRESS).tokenLevel(tokenId) == 0) revert TokenUnBound();
    }

    /// @dev Check the Soulbound status of the San Origin Tokens passed.
    /// @param originTokenIds OriginTokens to Burn and Ids to mint with.
    function _checkOriginTokensNotBound(uint256[] calldata originTokenIds) private view {
        unchecked {
            for (uint256 i = 0; i < originTokenIds.length; i++) {
                _checkOriginTokensNotBound(originTokenIds[i]);
            }
        }
    }

    /// @dev Check the Soulbound status of the San Origin Token passed.
    /// @param originTokenId OriginToken to Burn and Id to mint with.
    function _checkOriginTokensNotBound(uint256 originTokenId) private view {
        if (ISanOriginNFT(SAN_ORIGIN_ADDRESS).tokenLevel(originTokenId) != 0) {
            revert TokenAlreadyBoundInOrigin();
        }
    }

    /// @dev Finalise the storage values and upgrade the tokens.
    /// @dev Transfer San Origin NFT to the 'BURN_ADDRESS' and Mint a new 'SoulBound' Santuary NFT and MusicBox NFT.
    /// @param originTokenIds OriginTokens to Burn and Ids to mint with.
    /// @param _newLevel Level to upgrade with - All tokens must be at the same level to tx the Soulbound level from San Origin -> Sanctuary.
    /// @param _musicBoxLevel Common, Rare or Epic depending on the source of the mint.
    function _burnMintRebirth(
        uint256[] calldata originTokenIds,
        TokenLevel _newLevel,
        IMusicBox.MusicBoxLevel _musicBoxLevel
    ) private {
        // Upgrade
        unchecked {
            for (uint256 i = 0; i < ORIGIN_TOKENS_REQUIRED_TO_REBIRTH; i++) {
                _upgradeTokenLevel(originTokenIds[i], _newLevel, TokenLevel(0)); // curLevel MUST be 0 to mint..
            }
        }
        // Burn San Origin
        ISanOriginNFT(SAN_ORIGIN_ADDRESS).batchSafeTransferFrom(_msgSender(), _burnAddress(), originTokenIds, "");

        // Rebirth in the Santuary
        unchecked {
            for (uint256 i = 0; i < ORIGIN_TOKENS_REQUIRED_TO_REBIRTH; i++) {
                _rebirth(originTokenIds[i]);
            }
        }

        // Mint MusicBox NFT
        IMusicBox(MUSIC_BOX_ADDRESS).mintFromSantuary(_msgSender(), _musicBoxLevel, ORIGIN_TOKENS_REQUIRED_TO_REBIRTH);
    }

    /// @dev Finalise the storage values and upgrade the tokens.
    /// @dev Transfer San Origin NFT to the 'BURN_ADDRESS' and Mint a new 'SoulBound' Santuary NFT and MusicBox NFT.
    /// @param originTokenId OriginTokens to Burn and Ids to mint with.
    /// @param _newLevel Level to upgrade with - All tokens must be at the same level to tx the Soulbound level from San Origin -> Sanctuary.
    /// @param _musicBoxLevel Common, Rare or Epic depending on the source of the mint.
    function _burnMintRebirth(uint256 originTokenId, TokenLevel _newLevel, IMusicBox.MusicBoxLevel _musicBoxLevel)
        private
    {
        // Upgrade
        _upgradeTokenLevel(originTokenId, _newLevel, TokenLevel(0)); // curLevel MUST be 0 to mint..

        // Burn San Origin
        ISanOriginNFT(SAN_ORIGIN_ADDRESS).safeTransferFrom(_msgSender(), _burnAddress(), originTokenId, "");

        // Rebirth in the Santuary
        _rebirth(originTokenId);

        // Mint MusicBox NFT
        IMusicBox(MUSIC_BOX_ADDRESS).mintFromSantuary(_msgSender(), _musicBoxLevel, 1);
    }

    // OVERRIDES for Soulbinding

    /// @dev Allow Unbound San Origin Tokens to be approved during Mint.
    /// @param to address to Approve
    /// @param tokenId tokenId to Approve.
    function approve(address to, uint256 tokenId) public override(IERC721, ERC721) {
        if (currentTokenLevel[tokenId] > TokenLevel.Unbound) revert CannotApproveTokenLevel(to, tokenId);
        super.approve(to, tokenId);
    }

    /// @dev Allow Unbound San Origin Tokens to be transferred during Mint. (Also prevents burning)
    /// @param from Transfer from address.
    /// @param to Transfer to address.
    /// @param tokenId tokenId to Transfer.
    function _beforeTokenTransfer(address from, address to, uint256 tokenId) internal override {
        if (currentTokenLevel[tokenId] > TokenLevel.Unbound) {
            revert CannotTransferTokenLevelUpdatedToken(from, to, tokenId);
        }
        super._beforeTokenTransfer(from, to, tokenId);
    }

    // OVERRIDES for token Mappings

    /// @dev After mint, tokens are SouldBound and cannot be burned /tx.
    /// @param tokenId id to mint
    function _rebirth(uint256 tokenId) private {
        if (_msgSender() == address(0)) revert ZeroAddress();
        if (_exists(tokenId)) revert TokenAlreadyMinted(tokenId);
        _tokensOwnedByAddress[_msgSender()].push(tokenId);
        ownerByToken[tokenId] = _msgSender();

        // We only need to check one to get the selector.
        if (!_checkOnERC721Received(address(0), _msgSender(), tokenId, "")) {
            revert nonERC721ReceiverImplementer();
        }
    }

    /// @dev Override to Support Id<>Id assigments.
    /// @param _owner _owner address of the token passed.
    /// @return tokens Number of tokens that address owns
    function balanceOf(address _owner) public view virtual override(Base721) returns (uint256) {
        if (_owner == address(0)) revert ZeroAddress();
        return _tokensOwnedByAddress[_owner].length;
    }

    /// @dev Override to Support Id<>Id assigments.
    /// @param tokenId token to find the address of.
    /// @return _owner _owner address of the token passed.
    function ownerOf(uint256 tokenId) public view virtual override(IERC721, ERC721) returns (address) {
        address _owner = ownerByToken[tokenId];
        if (_owner == address(0)) revert ZeroAddress();
        return _owner;
    }

    /// @dev Override to Support Id<>Id assigments.
    /// @param tokenId token to find the address of.
    /// @return exists whether or not a tokenId exists or not.
    function _exists(uint256 tokenId) internal view virtual override(ERC721) returns (bool) {
        if (tokenId < _startingTokenID) return false;
        return ownerByToken[tokenId] != address(0);
    }
}
