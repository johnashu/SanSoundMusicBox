// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.18;

import {TestBase, ITokenLevels, IMusicBox, MusicBox} from "test/TestBase.sol";

contract MintWithBoundedOrigin is TestBase {
    bool matchIn = false;

    function _mintWithSanSoundBound(uint256 _toCheck, address user) internal {
        ITokenLevels.TokenLevel _cur = ITokenLevels.TokenLevel(uint256(mockSanOrigin.tokenLevel(_toCheck)) + 1);
        ITokenLevels.TokenLevel _new = _cur;
        ITokenLevels.TokenLevel level = ITokenLevels.TokenLevel(_new);

        uint256 price = _getPrice(uint256(_new), uint256(_cur));
        emit log_uint(price);

        sanctuary.mintFromSoulbound{value: price}(_toCheck, level);

        uint256 expected = _toCheck;
        if (!matchIn) {
            expected = expectedSingle;
        }

        __checkAfterMint(_toCheck, expected, level, user);
        _checkMusicBoxTokenLevel(IMusicBox.MusicBoxLevel.Legendary, expected, user);
    }
}
