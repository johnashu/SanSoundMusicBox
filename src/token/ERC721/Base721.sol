// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.18;

import {IBase721} from "src/interfaces/ERC721/IBase721.sol";
import {ERC721, IERC721, Strings} from "src/token/ERC721/ERC721.sol";
import {TokenRescuer} from "src/token/rescue/TokenRescuer.sol";
import {Ownable} from "src/utils/Ownable.sol";

/**
 * @title SanSound Base721
 * @author Maffaz
 */

abstract contract Base721 is IERC721, ERC721, TokenRescuer, IBase721 {
    /// The maximum token supply.  We do not use it as this is set in San Origin but we leave it for reading from external..
    uint256 public constant MAX_SUPPLY = 10000;
    /// The base URI for token metadata.
    string public baseURI;
    /// The contract URI for contract-level metadata.
    string public contractURI;

    constructor(string memory _name, string memory _symbol, string memory _baseURI, string memory _contractURI)
        ERC721(_name, _symbol, 1)
    {
        contractURI = _contractURI;
        baseURI = _baseURI;
    }

    function _getTokenIdAndIncrement() internal returns (uint256) {
        return ++totalSupply;
    }

    /**
     * @notice (only owner) Sets the base URI for token metadata.
     * @param _newBaseURI The new base URI.
     */

    function setBaseURI(string calldata _newBaseURI) external onlyOwner {
        baseURI = _newBaseURI;
    }

    /**
     * @notice (only owner) Sets the contract URI for contract metadata.
     * @param _newContractURI The new contract URI.
     */
    function setContractURI(string calldata _newContractURI) external onlyOwner {
        contractURI = _newContractURI;
    }

    /*//////////////////////////////////////////////////////////////
                              ERC721Enumerable LOGIC
    //////////////////////////////////////////////////////////////*/

    function tokenOfOwnerByIndex(address _tokenOwner, uint256 index) public view virtual returns (uint256 tokenId) {
        if (index > balanceOf(_tokenOwner)) revert IndexGreaterThanBalance();

        uint256 count = 0;
        unchecked {
            for (uint256 i = 0; i <= totalSupply; i++) {
                if (_tokenOwner == _ownerOf[i]) {
                    if (count == index) return i;
                    else count++;
                }
            }
        }

        revert OwnerIndexOutOfBounds();
    }

    /**
     * @notice Determines whether `_account` owns all token IDs `_tokenIds`.
     * @param _account The account to be checked for token ownership.
     * @param tokenIds An array of token IDs to be checked for ownership.
     * @return True if `_account` owns all token IDs `_tokenIds`, else false.
     */
    function isOwnerOf(address _account, uint256[] calldata tokenIds) public view returns (bool) {
        uint256 len = tokenIds.length;
        if (len > totalSupply) revert AmountExceedsSupply();
        unchecked {
            for (uint256 i; i < len; i++) {
                if (_ownerOf[tokenIds[i]] != _account) {
                    return false;
                }
            }
        }
        return true;
    }

    /**
     * @notice Returns an array of all token IDs owned by `_tokenOwner`.
     * @param _tokenOwner The address for which to return all owned token IDs.
     * @return An array of all token IDs owned by `_tokenOwner`.
     */
    function walletOfOwner(address _tokenOwner) public view returns (uint256[] memory) {
        uint256 tokenCount = balanceOf(_tokenOwner);
        if (tokenCount == 0) return new uint256[](0);

        uint256[] memory tokenIds = new uint256[](tokenCount);
        unchecked {
            for (uint256 i; i < tokenCount; i++) {
                tokenIds[i] = tokenOfOwnerByIndex(_tokenOwner, i);
            }
        }
        return tokenIds;
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
        (bool success,) = payable(msg.sender).call{value: _weiAmount}("");
        if (!success) revert FailedToWithdraw();
    }

    /// @param tokenId token to find the address of.
    /// @return exists whether or not a tokenId exists or not.
    function _exists(uint256 tokenId) internal view virtual returns (bool) {
        if (tokenId < _startingTokenID) return false;
        return ownerOf(tokenId) != address(0);
    }

    // FALLBACK & RECEIVE

    // Function to receive Ether. msg.data must be empty
    receive() external payable {}

    // Fallback function is called when msg.data is not empty
    fallback() external payable {}
}
