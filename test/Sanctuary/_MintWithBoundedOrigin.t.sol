// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.18;

import {TestBase, ITokenLevels, IMusicBox, MusicBox} from "test/TestBase.sol";

contract MintWithBoundedOrigin is TestBase {
    function _mintWithSanSoundBoundMultiple(uint256[] memory _toCheck, address user) internal {
        uint256 _cur = 0;
        uint256 _new = 1;
        ITokenLevels.TokenLevel level = ITokenLevels.TokenLevel(_new);
        _approveAllTokens(_toCheck);

        sanctuary.mintFromSoulbound{value: _getPrice(_new, _cur)}(_toCheck, level);
        _checkAfterMint(_toCheck, level, user);
        _checkMusicBoxTokenLevel(IMusicBox.MusicBoxLevel.Legendary, 1, user);
    }
}
