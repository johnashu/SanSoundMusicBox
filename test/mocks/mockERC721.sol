//SPDX-License-Identifier: UNLICENSED

/// @title Mock ERC721
/// @author Maffaz

pragma solidity ^0.8.18;

import {ERC721} from "src/token/ERC721/ERC721.sol";
import {Ownable} from "src/utils/Ownable.sol";

contract MockERC721 is ERC721, Ownable {
    constructor() ERC721("Mock1", "MK1", 1) {
        for (uint256 i; i < 42; i++) {
            _mint(msg.sender, i + 1);
        }
    }

    function transferAll(address to, uint256 start, uint256 end) public {
        for (uint256 i = start; i < end; i++) {
            transferFrom(msg.sender, to, i);
        }
    }

    function _transferFrom(address from, address to, uint256 tokenId) public {
        // approve(to, tokenId);
        transferFrom(from, to, tokenId);
    }

    function tokenURI(uint256 _tokenId) public view override returns (string memory) {}

    function _mint(address to, uint256 id) internal virtual {
        if (to == address(0)) revert ZeroAddress();

        if (_ownerOf[id] != address(0)) revert TokenAlreadyMinted();

        _ownerOf[id] = to;
        emit Transfer(address(0), to, id);
    }
}
