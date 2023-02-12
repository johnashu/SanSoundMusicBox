//SPDX-License-Identifier: UNLICENSED

/// @title Mock ERC721
/// @author Maffaz

pragma solidity ^0.8.18;

import {Base721, IERC721, ERC721} from "src/token/ERC721/Base721.sol";

contract MockSanOrigin is Base721 {
    address public constant BURN_ADDRESS = 0x000000000000000000000000000000000000dEaD;
    uint256 public constant MAX_SUPPLY = 3333;
    mapping(uint256 => uint256) public tokenLevel;

    constructor() Base721("San Origin Mock", "SOM", "", "") {
        for (uint256 i = 0; i < 42; i++) {
            _safeMint(msg.sender, i + 1);

            // SoulbOund Level 1
            if (i > 20) {
                tokenLevel[i] = 1;
            }

            // Soulbound level 3
            if (i > 38) {
                tokenLevel[i] = 3;
            }
            isApprovedForAll(msg.sender, msg.sender);
        }
    }

    function TransferUnbound(address to, uint256 start, uint256 end) public {
        for (uint256 i = start; i < end; i++) {
            _safeTransferFrom(_msgSender(), to, i);
        }
    }

    function TransferBound(address to, uint256 start, uint256 end) public {
        for (uint256 i = start; i < end; i++) {
            _safeTransferFrom(_msgSender(), to, i);
        }
    }

    function _safeTransferFrom(address from, address to, uint256 tokenId) public {
        _approve(msg.sender, tokenId);
        safeTransferFrom(from, to, tokenId);
    }

    function mint() public {
        _safeMint((msg.sender), totalSupply() + 1);
    }
}
