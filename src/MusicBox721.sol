// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.18;

import "src/interfaces/MusicBox/IMusicBox721.sol";
// import "src/utils/Ownable.sol"; // inherited via TokenRescuer
import "src/token/ERC721/ERC721Enumerable.sol";
import "src/token/ERC2981/ERC2981ContractWideRoyalties.sol";
import "src/interfaces/SanSound/SANSoulbindable.sol";
import "src/token/rescue/TokenRescuer.sol";


abstract contract MusicBox721 is TokenRescuer, ERC721Enumerable, IMusicBox721, ERC-2981: NFT Royalty Standard , SANSoulbindable {
    // number of tokens to mint
    uint8 public constant MAX_TOKENS_REQUIRED_TO_MINT = 3;

    /// The maximum number of mints per address
    uint256 public constant MAX_MINT_PER_ADDRESS = 3;

    /// The maximum ERC-2981 royalties percentage (two decimals).
    uint256 public constant MAX_ROYALTIES_PCT = 930; // 9.3%
    
    uint256 public constant MAX_SUPPLY = 3333;

    /// The base URI for token metadata.
    string public baseURI;

    /// The contract URI for contract-level metadata.
    string public contractURI;

    // Current Token Id. Init at 0 but first mint will be Id = 1.
    uint256 public currentTokenId;

    // Balance of the contract in fees to withdraw.
    uint256 contractBalance;

    /**
     * @notice The total tokens minted by an address.
     */
    mapping(address tokenOwner => uint256 totalMinted) public userMinted;

    constructor(string memory _name, string memory _symbol, string memory _contractURI, string memory _baseURI)
        ERC721(_name, _symbol, uint256(1))
    {
        contractURI = _contractURI;
        baseURI = _baseURI;
    }

    function _getTokenIdAndIncrement() internal returns (uint256) {
        return ++currentTokenId;
    }

    /**
     * @notice Determines whether `_account` owns all token IDs `_tokenIDs`.
     * @param _account The account to be checked for token ownership.
     * @param _tokenIDs An array of token IDs to be checked for ownership.
     * @return True if `_account` owns all token IDs `_tokenIDs`, else false.
     */
    function isOwnerOf(address _account, uint256[MAX_MINT_PER_ADDRESS] calldata _tokenIDs) public view returns (bool) {
        unchecked {
            for (uint256 i; i < MAX_MINT_PER_ADDRESS; ++i) {
                if (ownerOf(_tokenIDs[i]) != _account) {
                    return false;
                }
            }
        }
        return true;
    }

    /**
     * @notice Returns an array of all token IDs owned by `_owner`.
     * @param _owner The address for which to return all owned token IDs.
     * @return An array of all token IDs owned by `_owner`.
     */
    function walletOfOwner(address _owner) public view returns (uint256[] memory) {
        uint256 tokenCount = balanceOf(_owner);
        if (tokenCount == 0) return new uint256[](0);

        uint256[] memory tokenIDs = new uint256[](tokenCount);
        unchecked {
            for (uint256 i; i < tokenCount; i++) {
                tokenIDs[i] = tokenOfOwnerByIndex(_owner, i);
            }
        }
        return tokenIDs;
    }

    /**
     * @notice (only owner) Sets the contract URI for contract metadata.
     * @param _newContractURI The new contract URI.
     */
    function setContractURI(string calldata _newContractURI) external onlyOwner {
        contractURI = _newContractURI;
    }

    /**
     * @notice (only owner) Sets the base URI for token metadata.
     * @param _newBaseURI The new base URI.
     */
    function setBaseURI(string calldata _newBaseURI) external onlyOwner {
        baseURI = _newBaseURI;
    }

    /**
     * @notice (only owner) Withdraws all ether to the caller.
     */
    function safeWithdrawAll() external onlyOwner {
        uint256 balance = address(this).balance;
        if (balance == 0) revert NothingToWithdraw();
        withdraw(balance);
    }

    /**
     * @notice (only owner) Withdraws `_weiAmount` wei to the caller.
     * @param _weiAmount The amount of ether (in wei) to withdraw.
     */
    function withdraw(uint256 _weiAmount) public onlyOwner {
        (bool success,) = payable(_msgSender()).call{value: _weiAmount}("");
        if (!success) revert FailedToWithdraw();
    }

        /**
     * @notice (only owner) Sets ERC-2981 royalties recipient and percentage.
     * @param _recipient The address to which to send royalties.
     * @param _value The royalties percentage (two decimals, e.g. 1000 = 10%).
     */
    function setRoyalties(address _recipient, uint256 _value) external onlyOwner {
        if (_value > MAX_ROYALTIES_PCT) revert ExceedsMaxRoyaltiesPercentage();

        _setRoyalties(_recipient, _value);
    }

        /**
     * @notice Transfers multiple tokens from `_from` to `_to`.
     * @param _from The address from which to transfer tokens.
     * @param _to The address to which to transfer tokens.
     * @param _tokenIDs An array of token IDs to transfer.
     */
    function batchTransferFrom(address _from, address _to, uint256[] calldata _tokenIDs) external {
        unchecked {
            for (uint256 i = 0; i < _tokenIDs.length; i++) {
                transferFrom(_from, _to, _tokenIDs[i]);
            }
        }
    }

    /**
     * @notice Safely transfers multiple tokens from `_from` to `_to`.
     * @param _from The address from which to transfer tokens.
     * @param _to The address to which to transfer tokens.
     * @param _tokenIDs An array of token IDs to transfer.
     */
    function batchSafeTransferFrom(address _from, address _to, uint256[] calldata _tokenIDs, bytes calldata _data)
        external
    {
        unchecked {
            for (uint256 i = 0; i < _tokenIDs.length; i++) {
                safeTransferFrom(_from, _to, _tokenIDs[i], _data);
            }
        }
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

    function _cappedMint(uint256 _mintAmount) private {
        _mint(_mintAmount);

        if (userMinted[_msgSender()] > MAX_MINT_PER_ADDRESS) {
            revert ExceedsMaxMintPerAddress();
        }
    }
}
