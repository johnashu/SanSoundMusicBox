// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.18;

import {TestBase, ITokenLevels, IMusicBox, MusicBox} from "test/TestBase.sol";

contract MintWithBoundedOrigin is TestBase {
    function _mintWithSanSoundBound(uint256 _toCheck, address user) internal {
        uint256 _cur = 1;
        uint256 _new = 2;
        ITokenLevels.TokenLevel level = ITokenLevels.TokenLevel(_new);

        sanctuary.mintFromSoulbound{value: _getPrice(_new, _cur)}(_toCheck, level);
        __checkAfterMint(_toCheck, expectedSingle, level, user);
        _checkMusicBoxTokenLevel(IMusicBox.MusicBoxLevel.Legendary, 1, user);
    }
}
