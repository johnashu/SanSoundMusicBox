//SPDX-License-Identifier: UNLICENSED

/// @title Mock ERC721
/// @author Maffaz

pragma solidity ^0.8.0;

import "lib/openzeppelin-contracts/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import "lib/openzeppelin-contracts/contracts/access/Ownable.sol";

contract MockERC721 is ERC721Enumerable, Ownable {
    constructor() ERC721("Mock1", "MK1") {
        for (uint256 i = 0; i < 10; i++) {
            _safeMint(msg.sender, i + 1);
        }
    }

    function _safeTransferFrom(address from, address to, uint256 tokenId) public {
        _approve(msg.sender, tokenId);
        safeTransferFrom(from, to, tokenId);
    }
}
