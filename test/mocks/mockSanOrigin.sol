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
        for (uint256 i = 1; i < 21; i++) {
            _safeMint(msg.sender, i);
            if (i > 10) {
                tokenLevel[i] = 1;
            }
            isApprovedForAll(msg.sender, msg.sender);
        }
    }

    function mint() public {
        _safeMint((msg.sender), totalSupply() + 1);
    }
}
