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

import "src/interfaces/SanSound/ISAN721.sol";
import "src/utils/Ownable.sol";
import "src/token/ERC721Enumerable.sol";
import "src/token/ERC2981ContractWideRoyalties.sol";
import "src/token/TokenRescuer.sol";
import "src/interfaces/SanSound/ISanOriginNFT.sol";
import "src/interfaces/SanSound/SANSoulbindable.sol";

error MintAmountTokensIncorrect();

abstract contract SanSoundMusicBoxNFT is
    Ownable,
    ERC721Enumerable,
    ERC2981ContractWideRoyalties,
    TokenRescuer,
    ISAN721,
    SANSoulbindable
{
    // number of tokens to mint
    uint8 public constant TOKENS_REQUIRED_TO_MINT = 3;

    /// The base URI for token metadata.
    string public baseURI;

    /// The contract URI for contract-level metadata.
    string public contractURI;
    uint256 currentTokenId;

    ISanOriginNFT public sanOriginNFT;

    mapping(uint tokenId => TokenData tokenData) public tokenAccessData;
    mapping(uint originTokenId => bool isUsed) public usedOriginTokens;

    constructor(
        string memory _name,
        string memory _symbol,
        uint256 _startingTokenID,
        string memory _contractURI,
        string memory _baseURI
    ) ERC721(_name, _symbol, _startingTokenID) {
        sanOriginNFT = ISanOriginNFT(address(0x33333333333371718A3C2bB63E5F3b94C9bC13bE));
        contractURI = _contractURI;
        baseURI = _baseURI;
    }

    function checkUserOwnsTokens(uint256[] memory tokenIds, address _address)
        public
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

    function checkOriginTokensNotBound(uint256[] memory tokenIds) public view returns (bool) {
        unchecked {
            for (uint256 i = 0; i < TOKENS_REQUIRED_TO_MINT; i++) {
                uint256 tokenLevel = sanOriginNFT.tokenLevel(tokenIds[i]);
                if (tokenLevel != 0) revert TokenAlreadyBoundInOrigin();
            }
        }
        return true;
    }

    function checkSoulboundLevel(uint256 tokenId) public view returns (SoulboundLevel) {
        return tokenAccessData[tokenId].tokenSoulboundLevel;
    }

    function getTokenId() public returns (uint256) {
        return ++currentTokenId;
    }

    function mint(address _address, uint256[] memory tokenIds, SoulboundLevel accessRequested) public returns (bool) {
        // checkUserOwnsTokens(tokenIds, _address);
        checkOriginTokensNotBound(tokenIds);
        if (tokenIds.length != TOKENS_REQUIRED_TO_MINT) revert MintAmountTokensIncorrect();

        // Pass checks, map the id.
        unchecked {
            for (uint256 i = 0; i < TOKENS_REQUIRED_TO_MINT; i++) {
                usedOriginTokens[tokenIds[i]] = true;
            }
        }

        tokenAccessData[getTokenId()].tokenSoulboundLevel = accessRequested;

        _safeMint(_msgSender(), getTokenId()); // Check security..
        return true;
    }

    modifier notZeroAddress(address _address) {
        require(_address != address(0), "0x0 addr");
        _;
    }

    /**
     * @inheritdoc ERC165
     */
    function supportsInterface(bytes4 _interfaceId)
        public
        view
        override(ERC721Enumerable, ERC2981Base)
        returns (bool)
    {
        return super.supportsInterface(_interfaceId);
    }
}
