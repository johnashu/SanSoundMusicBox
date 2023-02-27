// SPDX-License-Identifier: AGPL-3.0-only
pragma solidity 0.8.18;

/// @notice Modern, minimalist, and gas efficient ERC-721 implementation.
/// @author Solmate (https://github.com/transmissions11/solmate/blob/main/src/tokens/ERC721.sol)
/// Maffaz - totalSupply / Custom Errors / Strings & Address Imports..

import {IERC721} from "src/interfaces/ERC721/IERC721.sol";
import {Strings} from "src/utils/Strings.sol";
import {Address} from "src/utils/Address.sol";

abstract contract ERC721 is IERC721 {
    // using Address for address;
    using Strings for uint256;

    /*//////////////////////////////////////////////////////////////
                         METADATA STORAGE/LOGIC
    //////////////////////////////////////////////////////////////*/
    uint256 internal immutable _startingTokenID;

    string public name;

    string public symbol;
    uint256 public totalSupply;

    function tokenURI(uint256 id) public view virtual returns (string memory);

    /*//////////////////////////////////////////////////////////////
                      ERC721 BALANCE/OWNER STORAGE
    //////////////////////////////////////////////////////////////*/

    mapping(uint256 => address) internal _ownerOf;

    function ownerOf(uint256 id) public view virtual returns (address owner) {
        if ((owner = _ownerOf[id]) == address(0)) revert TokenNotMinted();
    }

    // Use the old OZ implementation here as we are not using it internally and will save mint gas.
    // External contracts will be querying the Soulbound levels and max supply = 10k.
    function balanceOf(address owner) public view virtual override returns (uint256) {
        if (owner == address(0)) revert ZeroAddress();
        uint256 count;
        for (uint256 i; i <= totalSupply; i++) {
            if (owner == _ownerOf[i]) count++;
        }
        return count;
    }

    /*//////////////////////////////////////////////////////////////
                         ERC721 APPROVAL STORAGE
    //////////////////////////////////////////////////////////////*/

    mapping(uint256 => address) public getApproved;

    mapping(address => mapping(address => bool)) public isApprovedForAll;

    /**
     * @dev Initializes the contract by setting a `name` and a `symbol` to the token collection.
     */
    constructor(string memory name_, string memory symbol_, uint256 startingTokenID_) {
        name = name_;
        symbol = symbol_;
        _startingTokenID = startingTokenID_;
    }

    /*//////////////////////////////////////////////////////////////
                              ERC721 LOGIC
    //////////////////////////////////////////////////////////////*/

    function approve(address spender, uint256 id) public virtual {
        address owner = _ownerOf[id];

        if (!(msg.sender == owner || isApprovedForAll[owner][msg.sender])) revert NotAuthorised();

        getApproved[id] = spender;

        emit Approval(owner, spender, id);
    }

    function setApprovalForAll(address operator, bool approved) public virtual {
        isApprovedForAll[msg.sender][operator] = approved;

        emit ApprovalForAll(msg.sender, operator, approved);
    }

    function transferFrom(address from, address to, uint256 id) public virtual {
        _canTransfer(id);
        if (from != ownerOf(id)) revert NotOwner();

        if (to == address(0)) revert ZeroAddress();

        if (!(msg.sender == from || isApprovedForAll[from][msg.sender] || msg.sender == getApproved[id])) {
            revert NotAuthorised();
        }

        _ownerOf[id] = to;

        delete getApproved[id];

        emit Transfer(from, to, id);
    }

    function safeTransferFrom(address from, address to, uint256 id) public virtual {
        transferFrom(from, to, id);

        if (
            !(
                to.code.length == 0
                    || ERC721TokenReceiver(to).onERC721Received(msg.sender, from, id, "")
                        == ERC721TokenReceiver.onERC721Received.selector
            )
        ) {
            revert UnSafeRecipient();
        }
    }

    function safeTransferFrom(address from, address to, uint256 id, bytes calldata data) public virtual {
        transferFrom(from, to, id);

        if (
            !(
                to.code.length == 0
                    || ERC721TokenReceiver(to).onERC721Received(msg.sender, from, id, data)
                        == ERC721TokenReceiver.onERC721Received.selector
            )
        ) {
            revert UnSafeRecipient();
        }
    }

    /*//////////////////////////////////////////////////////////////
                              ERC165 LOGIC
    //////////////////////////////////////////////////////////////*/

    function supportsInterface(bytes4 interfaceId) public view virtual returns (bool) {
        return interfaceId == 0x01ffc9a7 // ERC165 Interface ID for ERC165
            || interfaceId == 0x80ac58cd // ERC165 Interface ID for ERC721
            || interfaceId == 0x5b5e139f; // ERC165 Interface ID for ERC721Metadata
    }

    /*//////////////////////////////////////////////////////////////
                        INTERNAL MINT/BURN LOGIC - Mint logic is handled in the corresponding contracts..
    //////////////////////////////////////////////////////////////*/
    //

    // function _mint(address to, uint256 id) internal virtual {
    //     if (to == address(0)) revert ZeroAddress();

    //     if (_ownerOf[id] != address(0)) revert TokenAlreadyMinted();

    //     _ownerOf[id] = to;
    //      emit Transfer(address(0), to, id);
    // }

    /*//////////////////////////////////////////////////////////////
                        INTERNAL SAFE MINT LOGIC
    //////////////////////////////////////////////////////////////*/

    // function _safeMint(address to, uint256 id) internal virtual {
    //     _mint(to, id);

    //     if (
    //         !(
    //             to.code.length == 0
    //                 || ERC721TokenReceiver(to).onERC721Received(msg.sender, address(0), id, "")
    //                     == ERC721TokenReceiver.onERC721Received.selector
    //         )
    //     ) {
    //         revert UnSafeRecipient();
    //     }
    // }

    // function _safeMint(address to, uint256 id, bytes memory data) internal virtual {
    //     _mint(to, id);

    //     if (
    //         !(
    //             to.code.length == 0
    //                 || ERC721TokenReceiver(to).onERC721Received(msg.sender, address(0), id, data)
    //                     == ERC721TokenReceiver.onERC721Received.selector
    //         )
    //     ) {
    //         revert UnSafeRecipient();
    //     }
    // }

    /**
     * @dev Hook that is called before any token transfer. This includes burning.
     */
    function _canTransfer(uint256 /*tokenId*/ ) internal virtual {}
}

/// @notice A generic interface for a contract which properly accepts ERC721 tokens.
/// @author Solmate (https://github.com/transmissions11/solmate/blob/main/src/tokens/ERC721.sol)
abstract contract ERC721TokenReceiver {
    function onERC721Received(address, address, uint256, bytes calldata) external virtual returns (bytes4) {
        return ERC721TokenReceiver.onERC721Received.selector;
    }
}
