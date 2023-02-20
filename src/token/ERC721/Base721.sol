// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.18;

import {IBase721} from "src/interfaces/ERC721/IBase721.sol";
import {ERC721, IERC721, Strings} from "src/token/ERC721/ERC721.sol";
import {
    ERC2981ContractWideRoyalties,
    ERC2981Base,
    ERC165,
    IERC165
} from "src/token/ERC2981/ERC2981ContractWideRoyalties.sol";
import {TokenRescuer} from "src/token/rescue/TokenRescuer.sol";
import {Ownable} from "src/utils/Ownable.sol";

/**
 * @title SanSound Base721
 * @author Maffaz
 */

abstract contract Base721 is IERC721, ERC721, TokenRescuer, IBase721, ERC2981ContractWideRoyalties {
    /// The maximum ERC-2981 royalties percentage (two decimals).
    uint256 public constant MAX_ROYALTIES_PCT = 930; // 9.3%

    /// The maximum number of mints per address
    uint256 public constant MAX_MINT_PER_ADDRESS = 3;

    /// The base URI for token metadata.
    string public baseURI;

    /// The contract URI for contract-level metadata.
    string public contractURI;

    constructor(string memory _name, string memory _symbol, string memory _contractURI, string memory _baseURI)
        ERC721(_name, _symbol, uint256(1))
    {
        contractURI = _contractURI;
        baseURI = _baseURI;
    }

    function _getTokenIdAndIncrement() internal returns (uint256) {
        return ++totalSupply;
    }

    /**
     * @notice Determines whether `_account` owns all token IDs `_tokenIds`.
     * @param _account The account to be checked for token ownership.
     * @param tokenIds An array of token IDs to be checked for ownership.
     * @return True if `_account` owns all token IDs `_tokenIds`, else false.
     */
    function isOwnerOf(address _account, uint256[] calldata tokenIds) public view returns (bool) {
        uint256 len = tokenIds.length;
        if (len > MAX_MINT_PER_ADDRESS) revert ExceedsMaxMintPerAddress();
        unchecked {
            for (uint256 i; i < len; ++i) {
                if (ownerOf(tokenIds[i]) != _account) {
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

        uint256[] memory tokenIds = new uint256[](tokenCount);
        unchecked {
            for (uint256 i; i < tokenCount; i++) {
                tokenIds[i] = tokenOfOwnerByIndex(_owner, i);
            }
        }
        return tokenIds;
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
     * @dev Reverts if empty.
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
     * @param _tokenIds An array of token IDs to transfer.
     */
    function batchTransferFrom(address _from, address _to, uint256[] calldata _tokenIds) external {
        unchecked {
            for (uint256 i = 0; i < _tokenIds.length; i++) {
                transferFrom(_from, _to, _tokenIds[i]);
            }
        }
    }

    /**
     * @notice Safely transfers multiple tokens from `_from` to `_to`.
     * @param _from The address from which to transfer tokens.
     * @param _to The address to which to transfer tokens.
     * @param _tokenIds An array of token IDs to transfer.
     */
    function batchSafeTransferFrom(address _from, address _to, uint256[] calldata _tokenIds, bytes calldata _data)
        external
    {
        unchecked {
            for (uint256 i = 0; i < _tokenIds.length; i++) {
                safeTransferFrom(_from, _to, _tokenIds[i], _data);
            }
        }
    }

    /// @dev Override to Support Id<>Id assigments.
    /// @param tokenId token to find the address of.
    /// @return exists whether or not a tokenId exists or not.
    function _exists(uint256 tokenId) internal view virtual returns (bool) {
        if (tokenId < _startingTokenID) return false;
        return ownerOf(tokenId) != address(0);
    }

    // Overrides.

    function supportsInterface(bytes4 _interfaceId) public view override(IERC165, ERC2981Base, ERC721) returns (bool) {
        return super.supportsInterface(_interfaceId);
    }

    function tokenURI(uint256 _tokenId) public view virtual override returns (string memory) {
        if (!_exists(_tokenId)) revert TokenDoesNotExist();
        return string(abi.encodePacked(baseURI, "/", Strings.toString(_tokenId), ".json"));
    }

    // FALLBACK & RECEIVE

    // Function to receive Ether. msg.data must be empty
    receive() external payable {}

    // Fallback function is called when msg.data is not empty
    fallback() external payable {}
}
