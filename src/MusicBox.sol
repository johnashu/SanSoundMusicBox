// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.18;

// Once in a Soulbound state, the NFT acts as the holder’s token-gated login to the SAN Sound platform:

// Merged will not receive access to the SAN Sound platform.
// Citizen will receive one year of access to the SAN Sound platform. .33 ETH
// Defiant will receive LIFETIME access to the SAN Sound platform.    xxETH
// Hanzoku will receive LIFETIME access to the SAN Sound platform.  xxETH
// “The 33” will receive LIFETIME access to the SAN Sound platform. xxETH

// Fees can be changed

// Only Merged NFT's from orign are allowed - level 0 only
// 1. Soulbind 3 nfts that are at level 0 in the origin to create a new NFT MB (MusicBox) Token
// Soulbinding does not give access.  3 NFT's
// 2. Can transfer when Merged.
// 3. any level can be paid for can upgrade not downgrade.abi
// 4. no need to revoke if we can upgrade no problems.

import "src/SanSoundMusicBoxNFT.sol";

contract MusicBox is SanSoundMusicBoxNFT {
    mapping(SoulboundLevel => uint256) public levelPrice;
    mapping(uint256 => SoulboundLevel) public tokenLevel;

    constructor(
        string memory _name,
        string memory _symbol,
        uint256 _startingTokenID,
        string memory _contractURI,
        string memory _baseURI,
        uint256[] memory _levelPrices
    ) SanSoundMusicBoxNFT(_name, _symbol, _startingTokenID, _contractURI, _baseURI) {
        levelPrice[SoulboundLevel.Merged] = _levelPrices[0];
        levelPrice[SoulboundLevel.Citizen] = _levelPrices[1];
        levelPrice[SoulboundLevel.Defiant] = _levelPrices[2];
        levelPrice[SoulboundLevel.Hanzoku] = _levelPrices[3];
        levelPrice[SoulboundLevel.The33] = _levelPrices[4];
    }

    function tokenURI(uint256 _tokenID) public view override returns (string memory) {
        if (!_exists(_tokenID)) revert TokenDoesNotExist();
        return string(
            abi.encodePacked(
                baseURI, Strings.toString(uint256(tokenLevel[_tokenID])), "/", Strings.toString(_tokenID), ".json"
            )
        );
    }
}
