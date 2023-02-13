// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.18;

import {TokenLevels} from "src/levels/TokenLevels.sol";
import {Base721, IERC721, ERC721} from "src/token/ERC721/Base721.sol";
import {ISanOriginNFT} from "src/interfaces/SanSound/ISanOriginNFT.sol";
import {IMusicBox} from "src/interfaces/MusicBox/IMusicBox.sol";
import {MusicBox} from "src/MusicBox.sol";

contract Sanctuary is TokenLevels, Base721 {
    uint8 public constant ORIGIN_TOKENS_REQUIRED_TO_MINT = 3;
    uint8 public constant WITH_PARTNER_TOKENS_REQUIRED_TO_MINT = 1;
    uint256 public constant MAX_SUPPLY = 3333;
    uint256 public constant MAX_BULK_MINT = 10;

    address public immutable SAN_ORIGIN_ADDRESS;
    address public immutable MUSIC_BOX_ADDRESS;
    address public immutable BURN_ADDRESS = 0x000000000000000000000000000000000000dEaD;

    mapping(uint256 tokenId => address tokenOwner) public ownerByToken;
    mapping(address ownerOfTokens => uint256[] tokensOwned) public tokensOwnedByAddress;
    mapping(address contractAddress => mapping(uint256 tokenId => bool isUsed)) public usedTokens;

    mapping(address contractAddress => bool isValid) public isValidContract;
    mapping(address contractAddress => uint8 _numTokens) public numPartnerTokensRequired;

    constructor(
        string memory _name,
        string memory _symbol,
        string memory _contractURI,
        string memory _baseURI,
        address _SAN_ORIGIN_ADDRESS,
        uint256[NUM_OF_LEVELS] memory _levelPrices
    ) Base721(_name, _symbol, _contractURI, _baseURI) TokenLevels(_levelPrices) {
        SAN_ORIGIN_ADDRESS = _SAN_ORIGIN_ADDRESS;
        isValidContract[_SAN_ORIGIN_ADDRESS] = true;

        MusicBox musicBox = new MusicBox( 
            string("SanSoundMusicBox"),
            string("SMB"),
            string("https://example.com/"),
            string(""),
            address(this));

        MUSIC_BOX_ADDRESS = address(musicBox);
        musicBox.transferOwnership(msg.sender);
    }

    // SETTERS

    /// @notice Update a partner address
    /// @dev SAN_ORIGIN_ADDRESS is added in construction so we dont want to change it.  Same with 0 address.
    /// @param _partnerAddress Address of the Partner Contract.
    /// @param _numTokensRequired tokens required to mint.
    /// @param _isValid true to be valid (add) or false to be invalid
    function updatePartnerAddress(address _partnerAddress, uint8 _numTokensRequired, bool _isValid) public onlyOwner {
        if (_partnerAddress == SAN_ORIGIN_ADDRESS || _partnerAddress == address(0) || _numTokensRequired == 0) {
            revert contractAddressNotValid();
        }
        isValidContract[_partnerAddress] = _isValid;
        numPartnerTokensRequired[_partnerAddress] = _numTokensRequired;
    }

    // MINT FUNCTIONS

    /// @notice Soulbind an existing SAN Origin NFT to receive a Legendary SAN Music Box NFT
    /// @dev Only Checks Soulbind and then mints
    /// @param originTokenIds San Origin Id(s) to Rebirth
    /// @param _newLevel Token level requested
    function mintFromSoulbound(uint256[] calldata originTokenIds, TokenLevel _newLevel) external payable {
        if (originTokenIds.length > MAX_BULK_MINT) revert MaximumBulkMintExceeded();
        _processChecks(originTokenIds, uint8(originTokenIds.length), SAN_ORIGIN_ADDRESS);
        _checkOriginTokensAreBound(originTokenIds);
        _burnMintRebirth(originTokenIds, _newLevel, IMusicBox.MusicBoxLevel(2));
    }

    /// @notice Send three SAN Origin NFTs to the Sanctuary receive a Rare SAN Music Box NFT
    /// @param originTokenIds San Origin Id(s) to Rebirth
    /// @param _newLevel Token level requested
    function mintFromSanOrigin(uint256[] calldata originTokenIds, TokenLevel _newLevel) external payable {
        _processChecks(originTokenIds, ORIGIN_TOKENS_REQUIRED_TO_MINT, SAN_ORIGIN_ADDRESS);
        _checkOriginTokensNotBound(originTokenIds);
        _burnMintRebirth(originTokenIds, _newLevel, IMusicBox.MusicBoxLevel(1));
    }

    /// @notice Rebirth and mint from a partner, Send a Scout SAN Origin NFT to the Sanctuary, which
    /// requires one SAN Origin NFT and an accompanying partner NFT (0N1 Force, Mutant Apes, WoW, Etc),
    /// for a common SAN Music Box NFT.
    /// @param originTokenIds San Origin Id(s) to Rebirth
    /// @param _newLevel Token level requested
    /// @param partnerTokenIds TokenIds from the Partner NFTs to check against
    /// @param _contractAddress Token Contract address to call for checks.

    function mintFromPartner(
        uint256[] calldata originTokenIds,
        TokenLevel _newLevel,
        uint256[] calldata partnerTokenIds,
        address _contractAddress
    ) external payable {
        _checkPartnerContractAddress(_contractAddress);
        _processChecks(originTokenIds, WITH_PARTNER_TOKENS_REQUIRED_TO_MINT, SAN_ORIGIN_ADDRESS);
        _processChecks(partnerTokenIds, numPartnerTokensRequired[_contractAddress], _contractAddress);
        _checkOriginTokensNotBound(originTokenIds);
        _burnMintRebirth(originTokenIds, _newLevel, IMusicBox.MusicBoxLevel(0));
    }

    // PRIVATE FUNCTIONS
    function _processChecks(uint256[] calldata tokenIds, uint8 requiredTokens, address _address) private {
        if (tokenIds.length != requiredTokens) revert MintAmountTokensIncorrect();
        if (currentTokenId >= MAX_SUPPLY) revert MaxSupplyReached();
        if (balanceOf(_msgSender()) >= MAX_MINT_PER_ADDRESS) revert ExceedsMaxMintPerAddress();
        _checkUserOwnsTokens(tokenIds, _address);
    }

    /// @dev Checks the caller owns the tokens and adds to `usedTokens` or reverts
    /// @param tokenIds Tokens to Check.
    /// @param _tokenAddress Address or contract to check (San Origin / Partners).
    function _checkUserOwnsTokens(uint256[] calldata tokenIds, address _tokenAddress) private {
        unchecked {
            for (uint256 i = 0; i < tokenIds.length; i++) {
                if (usedTokens[_tokenAddress][tokenIds[i]] != false) revert TokenAlreadyUsed();
                if (IERC721(_tokenAddress).ownerOf(tokenIds[i]) != _msgSender()) revert TokenNotOwned();
                usedTokens[_tokenAddress][tokenIds[i]] = true;
            }
        }
    }

    /// @dev Checks the partner address passed is correct.
    /// @param _partnerAddress Address of the partner to check.
    function _checkPartnerContractAddress(address _partnerAddress) private view {
        if (_partnerAddress == SAN_ORIGIN_ADDRESS || _partnerAddress == address(0) || !isValidContract[_partnerAddress])
        {
            revert contractAddressNotValid();
        }
    }

    /// @notice Check for SoulBound Tokens
    /// @dev Make sure all tokens passed are both SoulBound and the same level.
    /// @param tokenIds San Origin Id(s) to Rebirth.
    function _checkOriginTokensAreBound(uint256[] calldata tokenIds) private view {
        uint256 currentLevel;
        unchecked {
            for (uint256 i = 0; i < tokenIds.length; i++) {
                uint256 level = ISanOriginNFT(SAN_ORIGIN_ADDRESS).tokenLevel(tokenIds[i]);
                if (currentLevel == 0) {
                    currentLevel = level;
                }
                if (level == 0) revert TokenUnBound();
                if (level != currentLevel) revert TokenLevelMismatch();
            }
        }
    }

    /// @dev Check the Soulbound status of the San Origin Tokens passed.
    /// @param originTokenIds OriginTokens to Burn and Ids to mint with.
    function _checkOriginTokensNotBound(uint256[] calldata originTokenIds) private view {
        unchecked {
            for (uint256 i = 0; i < originTokenIds.length; i++) {
                if (ISanOriginNFT(SAN_ORIGIN_ADDRESS).tokenLevel(originTokenIds[i]) != 0) {
                    revert TokenAlreadyBoundInOrigin();
                }
            }
        }
    }

    /// @dev Transfer San Origin NFT to the 'BURN_ADDRESS' and Mint a new 'SoulBound' Santuary NFT.
    /// @param originTokenIds OriginTokens to Burn and Ids to mint with.
    function _burnOriginMintSanctuary(uint256[] calldata originTokenIds) private {
        unchecked {
            for (uint256 i = 0; i < originTokenIds.length; i++) {
                IERC721(SAN_ORIGIN_ADDRESS).transferFrom(_msgSender(), BURN_ADDRESS, originTokenIds[i]);
                _safeMint(_msgSender(), originTokenIds[i]);
            }
        }
    }

    /// @dev Finalise the storage values and upgrade the tokens.  Burn and mint to finish!
    /// @param originTokenIds OriginTokens to Burn and Ids to mint with.
    /// @param _newLevel Level to upgrade with - All tokens must be at the same level to tx the Soulbound level from San Origin -> Sanctuary.
    /// @param _musicBoxLevel Common, Rare or Epic depending on the source of the mint.
    function _burnMintRebirth(
        uint256[] calldata originTokenIds,
        TokenLevel _newLevel,
        IMusicBox.MusicBoxLevel _musicBoxLevel
    ) private {
        for (uint256 i = 0; i < originTokenIds.length; i++) {
            _upgradeTokenLevel(originTokenIds[i], _newLevel, TokenLevel(0)); // curLevel MUST be 0 to mint..
        }
        _burnOriginMintSanctuary(originTokenIds);
        IMusicBox(MUSIC_BOX_ADDRESS).mintFromSantuary(_msgSender(), _musicBoxLevel, originTokenIds.length);
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

    /// @dev Override mint to enable transfer by skipping the _beforeTokenTransfer function.
    ///      After mint, tokens are SouldBound and cannot be burned /tx.
    /// @param to Address to mint to
    /// @param tokenId id to mint
    function _mint(address to, uint256 tokenId) internal virtual override {
        if (to == address(0)) revert ZeroAddress();
        if (_exists(tokenId)) revert TokenAlreadyMinted(tokenId);

        tokensOwnedByAddress[_msgSender()].push(tokenId);
        ownerByToken[tokenId] = to;
        emit Transfer(address(0), to, tokenId);
    }

    /// @dev Override to Support Id<>Id assigments.
    /// @param owner a parameter just like in doxygen (must be followed by parameter name)
    /// @return tokens the return variables of a contract’s function state variable
    function balanceOf(address owner) public view virtual override(Base721) returns (uint256) {
        if (owner == address(0)) revert ZeroAddress();
        return tokensOwnedByAddress[owner].length;
    }

    /// @dev Override to Support Id<>Id assigments.
    /// @param tokenId token to find the address of.
    /// @return owner owner address of the token passed.
    function ownerOf(uint256 tokenId) public view virtual override(IERC721, ERC721) returns (address) {
        address owner = ownerByToken[tokenId];
        if (owner == address(0)) revert ZeroAddress();
        return owner;
    }

    /// @dev Override to Support Id<>Id assigments.
    /// @param tokenId token to find the address of.
    /// @return exists whether or not a tokenId exists or not.
    function _exists(uint256 tokenId) internal view virtual override(ERC721) returns (bool) {
        if (tokenId < _startingTokenID) return false;
        return ownerByToken[tokenId] != address(0);
    }
}
