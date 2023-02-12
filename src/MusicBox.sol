//SPDX-License-Identifier: UNLICENSED

/// @title Musix Box NFT
/// @author Maffaz

pragma solidity ^0.8.18;

import {Base721, IERC721, ERC721} from "src/token/ERC721/Base721.sol";
import {IMusicBox} from "src/interfaces/MusicBox/IMusicBox.sol";

contract MusicBox is Base721, IMusicBox {
    address public immutable SANCTUARY_ADDRESS;
    uint256 public constant MAX_SUPPLY = 3333;

    mapping(uint256 tokenId => MusicBoxLevel) public tokenLevel;

    constructor(
        string memory _name,
        string memory _symbol,
        string memory _contractURI,
        string memory _baseURI,
        address _SANCTUARY_ADDRESS
    ) Base721(_name, _symbol, _contractURI, _baseURI) {
        SANCTUARY_ADDRESS = _SANCTUARY_ADDRESS;
    }

    function mintFromSantuary(address _to, MusicBoxLevel musicBoxLevel, uint256 _amount) external {
        if (_msgSender() != SANCTUARY_ADDRESS) revert OnlySanctuaryAllowedToMint();
        unchecked {
            for (uint256 i = 0; i < _amount; i++) {
                uint256 newId = _getTokenIdAndIncrement();
                userMinted[_to] += 1;
                tokenLevel[newId] = musicBoxLevel;
                _safeMint(_to, newId);
            }
        }
    }
}
