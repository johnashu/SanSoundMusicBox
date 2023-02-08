//SPDX-License-Identifier: UNLICENSED

/// @title Musix Box NFT
/// @author Maffaz

pragma solidity ^0.8.18;

import {Base721, IERC721, ERC721} from "src/token/ERC721/Base721.sol";

contract MusicBox is Base721 {
    uint256 public constant MAX_SUPPLY = 3333;

    constructor(string memory _name, string memory _symbol, string memory _contractURI, string memory _baseURI)
        Base721(_name, _symbol, _contractURI, _baseURI)
    {}
}
