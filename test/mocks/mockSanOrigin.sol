//SPDX-License-Identifier: UNLICENSED

/// @title Mock ERC721
/// @author Maffaz

pragma solidity ^0.8.18;

import {Base721, IERC721, ERC721} from "src/token/ERC721/Base721.sol";

contract MockSanOrigin is Base721 {
    mapping(uint256 => uint256) public tokenLevel;

    constructor() Base721("SO Mock", "SOM", "https://www.example.com/") {
        for (uint256 i = 0; i < 42; i++) {
            _safeMint(msg.sender, i + 1);

            // Soulbound Level 1
            if (i > 20) {
                tokenLevel[i] = 1;
            }

            // Soulbound level 3
            if (i > 38) {
                tokenLevel[i] = 3;
            }
            setApprovalForAll(msg.sender, true);
        }
    }

    function TransferUnbound(address to, uint256 start, uint256 end) public {
        for (uint256 i = start; i < end; i++) {
            _safeTransferFrom(msg.sender, to, i);
        }
    }

    function TransferBound(address to, uint256 start, uint256 end) public {
        for (uint256 i = start; i < end; i++) {
            _safeTransferFrom(msg.sender, to, i);
        }
    }

    function _safeTransferFrom(address from, address to, uint256 tokenId) public {
        approve(msg.sender, tokenId);
        safeTransferFrom(from, to, tokenId);
    }

    function mint() public {
        _safeMint((msg.sender), totalSupply + 1);
    }
}
