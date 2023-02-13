//SPDX-License-Identifier: UNLICENSED

/// @title San Sound Musix Box NFT
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

    /// @notice Mints X Amount of tokens received from the Sanctuary Contract.
    /// @dev The Sanctuary Contract deploys and sets its address in this contract.  Only that address can mint to it.
    /// @param _to Address to send the minted Token to.
    /// @param musicBoxLevel MusicBox level Common, Rare, Epic as sent by the Sanctuary.
    /// @param _amount The number of tokens to mint.
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
