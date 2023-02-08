//SPDX-License-Identifier: UNLICENSED

/// @title Mock ERC721
/// @author Maffaz

pragma solidity ^0.8.18;

import {ERC721Enumerable, ERC721} from "src/token/ERC721/ERC721Enumerable.sol";
import {Ownable} from "src/utils/Ownable.sol";

contract MockSanOrigin is ERC721Enumerable, Ownable {
    mapping(uint256 => uint256) public tokenLevel;

    constructor() ERC721("Mock1", "MK1", 1) {
        for (uint256 i = 1; i < 21; i++) {
            _safeMint(msg.sender, i);
            if (i > 10) {
                tokenLevel[i] = 1;
            }
        }
    }

    function mint() public {
        _safeMint((msg.sender), totalSupply() + 1);
    }

    function _safeTransferFrom(address from, address to, uint256 tokenId) public {
        _approve(msg.sender, tokenId);
        safeTransferFrom(from, to, tokenId);
    }

    function tokenURI(uint256 _tokenId) public view override returns (string memory) {}
}
