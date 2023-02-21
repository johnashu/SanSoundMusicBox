// SPDX-License-Identifier: MIT
pragma solidity ^0.8.12;

import "src/interfaces/ERC721/IERC721.sol";
import "src/utils/Strings.sol";
import "src/utils/Address.sol";

abstract contract ERC721 is IERC721 {
    using Address for address;
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

    mapping(address => uint256) internal _balanceOf;

    function ownerOf(uint256 id) public view virtual returns (address owner) {
        require((owner = _ownerOf[id]) != address(0), "NOT_MINTED");
    }

    function balanceOf(address owner) public view virtual returns (uint256) {
        if (owner == address(0))  revert ZeroAddress();

        return _balanceOf[owner];
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

    function _burnAddress() internal view virtual returns (address) {
        return address(0x000000000000000000000000000000000000dEaD);
    }

    function approve(address spender, uint256 id) public virtual {
        address owner = _ownerOf[id];

        if (msg.sender != owner || !isApprovedForAll[owner][msg.sender]) revert NotAuthorised();

        getApproved[id] = spender;

        emit Approval(owner, spender, id);
    }

    function setApprovalForAll(address operator, bool approved) public virtual {
        isApprovedForAll[msg.sender][operator] = approved;

        emit ApprovalForAll(msg.sender, operator, approved);
    }

    function transferFrom(address from, address to, uint256 id) public virtual {
         _canTransfer(id);
        if(from != _ownerOf[id]) revert NotOwner();

        if(to == address(0)) revert ZeroAddress();

        if(
            msg.sender != from || !isApprovedForAll[from][msg.sender] || msg.sender != getApproved[id]
        ) revert NotAuthorised();

        // Underflow of the sender's balance is impossible because we check for
        // ownership above and the recipient's balance can't realistically overflow.
        unchecked {
            _balanceOf[from]--;

            _balanceOf[to]++;
        }

        _ownerOf[id] = to;

        delete getApproved[id];

        emit Transfer(from, to, id);
    }

    function safeTransferFrom(address from, address to, uint256 id) public virtual {
        transferFrom(from, to, id);

        if(
            to.code.length != 0
                || ERC721TokenReceiver(to).onERC721Received(msg.sender, from, id, "")
                    != ERC721TokenReceiver.onERC721Received.selector
        ) revert UnSafeRecipient();
    }

    function safeTransferFrom(address from, address to, uint256 id, bytes calldata data) public virtual {
        transferFrom(from, to, id);

        if(
            to.code.length != 0
                || ERC721TokenReceiver(to).onERC721Received(msg.sender, from, id, data)
                    != ERC721TokenReceiver.onERC721Received.selector
        ) revert UnSafeRecipient();
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
                        INTERNAL MINT/BURN LOGIC
    //////////////////////////////////////////////////////////////*/

    function _mint(address to, uint256 id) internal virtual {
        if(to == address(0)) revert ZeroAddress();

        if (_ownerOf[id] != address(0)) revert TokenAlreadyMinted();

        // Counter overflow is incredibly unrealistic.
        unchecked {
            _balanceOf[to]++;
        }

        _ownerOf[id] = to;
        emit Transfer(address(0), to, id);
    }


    function _burn(uint256 id) internal virtual {
        _canTransfer(id);
        address owner = _ownerOf[id];

        if (owner == address(0)) revert TokenNotMinted();

        // Ownership check above ensures no underflow.
        unchecked {
            _balanceOf[owner]--;
        }

        delete _ownerOf[id];

        delete getApproved[id];

        totalSupply--;

        emit Transfer(owner, address(0), id);
    }

     

    /*//////////////////////////////////////////////////////////////
                        INTERNAL SAFE MINT LOGIC
    //////////////////////////////////////////////////////////////*/

    function _safeMint(address to, uint256 id) internal virtual {
        _mint(to, id);

        if (
            to.code.length != 0
                || ERC721TokenReceiver(to).onERC721Received(msg.sender, address(0), id, "")
                    != ERC721TokenReceiver.onERC721Received.selector
        ) revert UnSafeRecipient();
    }



    function _safeMint(address to, uint256 id, bytes memory data) internal virtual {
        _mint(to, id);

      if (
            to.code.length != 0
                || ERC721TokenReceiver(to).onERC721Received(msg.sender, address(0), id, data)
                    != ERC721TokenReceiver.onERC721Received.selector
        ) revert UnSafeRecipient();
    }

    /**
     * @dev Hook that is called before any token transfer. This includes minting
     * and burning.
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
