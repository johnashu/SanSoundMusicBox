//SPDX-License-Identifier: UNLICENSED

/// @title Musix Box NFT
/// @author Maffaz

pragma solidity ^0.8.18;

import {Base721, IERC721, ERC721} from "src/token/ERC721/Base721.sol";
import {IMusicBox} from "src/interfaces/MusicBox/IMusicBox.sol";

contract MusicBox is Base721, IMusicBox {
    uint256 public constant MAX_SUPPLY = 3333;

    address SANCTUARY_ADDRESS;

    mapping(uint tokenId => MusicBoxLevel) tokenLevel;

    constructor(string memory _name, string memory _symbol, string memory _contractURI, string memory _baseURI)
        Base721(_name, _symbol, _contractURI, _baseURI)
    {}

    function mintFromSantuary(address _to, MusicBoxLevel musicBoxLevel, uint _amount) external {
        unchecked {
            for (uint256 i = 0; i < _amount; i++) {
                uint newId = _getTokenIdAndIncrement();
                userMinted[_to] += 1;
                tokenLevel[newId] = musicBoxLevel;
                _safeMint(_to, newId);
            }
        }
    }
}
