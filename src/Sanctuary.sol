// SPDX-License-Identifier: UNLICENSED
/// @title San Sound Sanctuary Rebirth NFT
/// @author Maffaz

// We wont check to see if the token is already minted as we calculate from the supply and increment.
// We dont check Owner as it comes from msg.sender AND external tokenId

pragma solidity ^0.8.18;

import {TokenLevels} from "src/levels/TokenLevels.sol";
import {IRebirth} from "src/interfaces/Sanctuary/IRebirth.sol";
import {ITokenLevels} from "src/interfaces/Levels/ITokenLevels.sol";
import {Base721, IERC721, ERC721, Strings} from "src/token/ERC721/Base721.sol";
import {ISanOriginNFT} from "src/interfaces/SanSound/ISanOriginNFT.sol";
import {IMusicBox} from "src/interfaces/MusicBox/IMusicBox.sol";
import {MusicBox} from "src/MusicBox.sol";

contract Sanctuary is TokenLevels, IRebirth, Base721 {
    uint96 public constant ORIGIN_TOKENS_REQUIRED_TO_REBIRTH = 3;
    address BURN_ADDRESS = 0x000000000000000000000000000000000000dEaD;

    address public immutable SAN_ORIGIN_ADDRESS;
    address public immutable MUSIC_BOX_ADDRESS;

    mapping(uint256 SanctuaryId => uint256 originId) public originSanctuaryTokenMap;
    mapping(address contractAddress => mapping(uint256 tokenId => bool isUsed)) public usedTokens;

    mapping(address contractAddress => bool isValid) public isValidContract;

    constructor(
        string memory _name,
        string memory _symbol,
        string memory _baseURI,
        string memory _contractURI,
        string memory _nameMusicBox,
        string memory _symbolMusicBox,
        string memory _baseURIMusicBox,
        string memory _contractURIMusicBox,
        address _SAN_ORIGIN_ADDRESS,
        uint256[NUM_OF_LEVELS] memory _levelPrices
    ) Base721(_name, _symbol, _baseURI, _contractURI) TokenLevels(_levelPrices) {
        SAN_ORIGIN_ADDRESS = _SAN_ORIGIN_ADDRESS;
        isValidContract[_SAN_ORIGIN_ADDRESS] = true;

        MusicBox musicBox = new MusicBox( 
            _nameMusicBox, 
            _symbolMusicBox, 
            _baseURIMusicBox, 
            _contractURIMusicBox,
            address(this)
            );

        MUSIC_BOX_ADDRESS = address(musicBox);
        musicBox.transferOwnership(msg.sender);
    }

    // GETTERS

    /// @dev returns an array of the tokens assigned to the user.
    /// @param _owner Address of the tokens requested.
    /// @return tokensOwned Tokens that address owns
    function tokensOwnedByAddress(address _owner) public view returns (uint256[] memory tokensOwned) {
        if (_owner == address(0)) revert ZeroAddress();
        return walletOfOwner(_owner);
    }

    // SETTERS
    /// @notice Update a partner address
    /// @dev SAN_ORIGIN_ADDRESS is added in construction so we cant change it.
    /// @param _partnerAddress Address of the Partner Contract.
    /// @param _isValid true to be valid (add) or false to be invalid
    function updatePartnerAddress(address _partnerAddress, bool _isValid) public onlyOwner {
        if (_partnerAddress == SAN_ORIGIN_ADDRESS || _partnerAddress == address(0)) {
            revert contractAddressNotValid();
        }
        isValidContract[_partnerAddress] = _isValid;
    }

    // MINT FUNCTIONS
    /// @notice Send three SAN Origin NFTs to the Sanctuary receive a Rare SAN Music Box NFT
    /// @param originTokenIds San Origin Id(s) to Rebirth
    /// @param _newLevel Token level requested
    function mintWith3UnboundSanOrigin(uint256[] calldata originTokenIds, TokenLevel _newLevel) public payable {
        _processChecks(originTokenIds);
        _burnMintRebirth(originTokenIds, _newLevel, IMusicBox.MusicBoxLevel.Rare);
    }

    /// @notice Soulbind an existing SAN Origin NFT to receive a Legendary SAN Music Box NFT.
    /// @dev Checks Soulbind and then mints.
    /// @param originTokenId San Origin Id to Rebirth
    /// @param _newLevel Token level requested
    function mintFromSoulbound(uint256 originTokenId, TokenLevel _newLevel) public payable {
        _checkUserOwnsToken(originTokenId, SAN_ORIGIN_ADDRESS);
        _mintRebirth(
            originTokenId,
            _newLevel,
            TokenLevel(_checkOriginTokensAreBound(originTokenId)),
            IMusicBox.MusicBoxLevel.Legendary
        );
    }

    /// @notice Rebirth and mint from a partner, Send a Scout SAN Origin NFT to the Sanctuary, which
    /// requires one SAN Origin NFT and an accompanying partner NFT (0N1 Force, Mutant Apes, WoW, Etc),
    /// for a common SAN Music Box NFT.
    /// @param originTokenId San Origin Id(s) to Rebirth
    /// @param _newLevel Token level requested
    /// @param partnerTokenId TokenId from the Partner NFT to chec.k
    /// @param _partnerAddress Token Contract address to call for checks.
    function mintFromPartner(
        uint256 originTokenId,
        TokenLevel _newLevel,
        uint256 partnerTokenId,
        address _partnerAddress
    ) public payable {
        if (_partnerAddress == SAN_ORIGIN_ADDRESS || _partnerAddress == address(0) || !isValidContract[_partnerAddress])
        {
            revert contractAddressNotValid();
        }
        _checkUserOwnsToken(originTokenId, SAN_ORIGIN_ADDRESS);
        _checkUserOwnsToken(partnerTokenId, _partnerAddress);
        _checkOriginTokensNotBound(originTokenId);
        // Burn San Origin
        ISanOriginNFT(SAN_ORIGIN_ADDRESS).safeTransferFrom(msg.sender, BURN_ADDRESS, originTokenId, "");
        _mintRebirth(originTokenId, _newLevel, TokenLevel.Unbound, IMusicBox.MusicBoxLevel.Common);
    }

    // PRIVATE FUNCTIONS

    /// @dev Checks the caller owns the tokens and adds to `usedTokens` or reverts
    /// @dev used for the 'mint 3 from san origin' option.
    /// @param originTokenIds Tokens to Check.
    function _processChecks(uint256[] calldata originTokenIds) private {
        if (originTokenIds.length != ORIGIN_TOKENS_REQUIRED_TO_REBIRTH) revert MintAmountTokensIncorrect();
        unchecked {
            for (uint256 i; i < ORIGIN_TOKENS_REQUIRED_TO_REBIRTH; i++) {
                _checkUserOwnsToken(originTokenIds[i], SAN_ORIGIN_ADDRESS);
                _checkOriginTokensNotBound(originTokenIds[i]);
            }
        }
    }

    /// @dev Checks the caller owns the token and adds to `usedTokens` or reverts
    /// @param tokenId Token to Check.
    /// @param _tokenAddress Address or contract to check (San Origin / Partners).
    function _checkUserOwnsToken(uint256 tokenId, address _tokenAddress) private {
        if (usedTokens[_tokenAddress][tokenId] != false) revert TokenAlreadyUsed();
        if (IERC721(_tokenAddress).ownerOf(tokenId) != msg.sender) revert TokenNotOwned();
        usedTokens[_tokenAddress][tokenId] = true;
    }

    /// @notice Check for SoulBound Tokens
    /// @dev Make sure all token passed are SoulBound.
    /// @param tokenId San Origin Id(s) to Rebirth.
    function _checkOriginTokensAreBound(uint256 tokenId) private view returns (uint256 level) {
        if ((level = ISanOriginNFT(SAN_ORIGIN_ADDRESS).tokenLevel(tokenId)) == 0) revert TokenUnBound();
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
        // Burn San Origin
        ISanOriginNFT(SAN_ORIGIN_ADDRESS).batchSafeTransferFrom(msg.sender, BURN_ADDRESS, originTokenIds, "");

        // Rebirth in the Santuary
        _batchRebirth(_newLevel, originTokenIds);

        // Mint MusicBox NFT
        IMusicBox(MUSIC_BOX_ADDRESS).mintFromSantuary(msg.sender, _musicBoxLevel);
    }

    /// @dev Finalise the storage values and upgrade the tokens.
    /// @dev Transfer San Origin NFT to the 'BURN_ADDRESS' and Mint a new 'SoulBound' Santuary NFT and MusicBox NFT.
    /// @param originTokenId OriginTokens to Burn and Ids to mint with.
    /// @param _newLevel Level to upgrade with - All tokens must be at the same level to tx the Soulbound level from San Origin -> Sanctuary.
    /// @param _musicBoxLevel Common, Rare or Epic depending on the source of the mint.
    function _mintRebirth(
        uint256 originTokenId,
        TokenLevel _newLevel,
        TokenLevel _currentLevel,
        IMusicBox.MusicBoxLevel _musicBoxLevel
    ) private {
        // Rebirth in the Santuary
        _rebirth(_newLevel, _currentLevel, originTokenId);

        // Mint MusicBox NFT
        IMusicBox(MUSIC_BOX_ADDRESS).mintFromSantuary(msg.sender, _musicBoxLevel);
    }

    function _batchRebirth(TokenLevel _newLevel, uint256[] calldata originTokenIds) private {
        uint256 currentId = totalSupply;

        // Update balance once
        unchecked {
            totalSupply += ORIGIN_TOKENS_REQUIRED_TO_REBIRTH;

            for (uint256 i; i < ORIGIN_TOKENS_REQUIRED_TO_REBIRTH; i++) {
                uint256 newId = currentId + i + 1;
                _ownerOf[newId] = msg.sender;
                originSanctuaryTokenMap[newId] = originTokenIds[i];
                _upgradeTokenLevel(newId, _newLevel, TokenLevel.Unbound);
                emit Rebirth(msg.sender, originTokenIds[i], newId);
                emit Transfer(address(0), msg.sender, newId);
            }
        }
    }

    /// @dev After mint, tokens are SouldBound and cannot be burned /tx.
    function _rebirth(TokenLevel _newLevel, TokenLevel _currentLevel, uint256 originTokenId) private {
        uint256 newId = _getTokenIdAndIncrement();

        // Upgrade
        _upgradeTokenLevel(newId, _newLevel, _currentLevel);
        originSanctuaryTokenMap[newId] = originTokenId;

        _ownerOf[newId] = msg.sender;

        emit Rebirth(msg.sender, originTokenId, newId);
        emit Transfer(address(0), msg.sender, newId);
    }

    // overrides

    function tokenURI(uint256 _tokenId) public view override returns (string memory) {
        if (!_exists(_tokenId)) revert TokenDoesNotExist();
        return string(
            abi.encodePacked(
                baseURI,
                Strings.toString(uint256(tokenLevel[_tokenId])),
                "/",
                Strings.toString(originSanctuaryTokenMap[_tokenId]),
                ".json"
            )
        );
    }

    function approve(address spender, uint256 id) public virtual override(ERC721, IERC721) {
        revert CannotApproveBoundedToken();
    }

    function setApprovalForAll(address operator, bool approved) public virtual override(ERC721, IERC721) {
        revert CannotApproveBoundedToken();
    }

    function transferFrom(address from, address to, uint256 id) public virtual override(ERC721, IERC721) {
        revert CannotTransferBoundedToken();
    }

    function safeTransferFrom(address from, address to, uint256 id) public virtual override(ERC721, IERC721) {
        revert CannotTransferBoundedToken();
    }

    function safeTransferFrom(address from, address to, uint256 id, bytes calldata data)
        public
        virtual
        override(ERC721, IERC721)
    {
        revert CannotTransferBoundedToken();
    }
}
