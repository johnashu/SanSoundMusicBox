// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.18;

import "src/interfaces/MusicBox/IMusicBox721.sol";
import "src/utils/Ownable.sol";
import "src/token/ERC721Enumerable.sol";
import "src/interfaces/SanSound/SANSoulbindable.sol";

abstract contract MusicBox721 is Ownable, ERC721Enumerable, IMusicBox721, SANSoulbindable {
    // number of tokens to mint
    uint8 public constant TOKENS_REQUIRED_TO_MINT = 3;

    /// The maximum number of mints per address
    uint256 public constant MAX_MINT_PER_ADDRESS = 3;

    /// The maximum token supply.
    // 9,748 Unbound SanOrigin Tokens
    // divided by 3 = 3249.3333
    // MAX_SUPPLY = 3249
    // Remaining NFTs = 1
    uint256 public constant MAX_SUPPLY = 3249;

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
    function isOwnerOf(address _account, uint256[] calldata _tokenIDs) public view returns (bool) {
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

    function approve(address to, uint256 tokenId) public pure override(IERC721, ERC721) {
        revert CannotApproveSoulboundToken(to, tokenId);
    }

    function _beforeTokenTransfer(address from, address to, uint256 tokenId) internal pure override {
        revert CannotTransferSoulboundToken(from, to, tokenId);
    }
}
