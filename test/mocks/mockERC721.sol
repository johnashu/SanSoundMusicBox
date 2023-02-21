//SPDX-License-Identifier: UNLICENSED

/// @title Mock ERC721
/// @author Maffaz

pragma solidity ^0.8.18;

import {ERC721} from "src/token/ERC721/ERC721.sol";
import {Ownable} from "src/utils/Ownable.sol";

contract MockERC721 is ERC721, Ownable {
    constructor() ERC721("Mock1", "MK1", 1) {
        for (uint256 i; i < 42; i++) {
            _safeMint(msg.sender, i + 1);
        }
    }

    function transferAll(address to, uint256 start, uint256 end) public {
        for (uint256 i = start; i < end; i++) {
            safeTransferFrom(msg.sender, to, i);
        }
    }

    function _safeTransferFrom(address from, address to, uint256 tokenId) public {
        approve(msg.sender, tokenId);
        safeTransferFrom(from, to, tokenId);
    }

    function tokenURI(uint256 _tokenId) public view override returns (string memory) {}
}
