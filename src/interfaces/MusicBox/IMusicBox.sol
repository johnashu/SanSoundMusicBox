//SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

interface IMusicBox {
    enum MusicBoxLevel {
        Common,
        Rare,
        Legendary
    }

    function mintFromSantuary(address _to, MusicBoxLevel musicBoxLevel, uint256 _amount) external;

    error OnlySanctuaryAllowedToMint();
}
