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
    /// The maximum number of mints per address - Santuary dictates maximum for both as MusicBox cannot mint!
    uint256 public constant MAX_MINT_PER_ADDRESS = 3;
    /// The base URI for token metadata.
    string public baseURI;

    constructor(string memory _name, string memory _symbol, string memory _baseURI)
        ERC721(_name, _symbol, uint256(1))
    {
        baseURI = _baseURI;
    }

    function _getTokenIdAndIncrement() internal returns (uint256) {
        return ++totalSupply;
    }

    /*//////////////////////////////////////////////////////////////
                              ERC721Enumerable LOGIC
    //////////////////////////////////////////////////////////////*/

    function tokenOfOwnerByIndex(address owner, uint256 index) public view virtual returns (uint256 tokenId) {
        if (index > balanceOf(owner)) revert IndexGreaterThanBalance();

        uint256 count;
        unchecked {
            for (uint256 i = 1; i < totalSupply + 1; i++) {
                if (owner == ownerOf(i)) {
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
