// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.18;

import {TestBase, ITokenLevels, IMusicBox, MusicBox, IERC721} from "test/TestBase.sol";

contract MintWithThreeUnboundedOrigin is TestBase {
    bool matchIn3Unbounded = false;

    function _mintWithMultiSanOrigin(uint256[] memory tokens, address user) internal {
        uint256 _cur = 0;
        uint256 _new = 1;
        ITokenLevels.TokenLevel level = ITokenLevels.TokenLevel(_new);

        _approveAllTokens(tokens);
        // Mint the Tokens
        sanctuary.mintWith3UnboundSanOrigin{value: _getPrice(_new, _cur)}(tokens, level);

        uint256[] memory expected = tokens;
        uint256 expectedMB = tokens[2] / 3;
        if (!matchIn3Unbounded) {
            expected = expectedMultiple;
            expectedMB = expectedSingle;
        }

        _checkAfterMint(tokens, expected, level, user);
        _checkMusicBoxTokenLevel(IMusicBox.MusicBoxLevel.Rare, expectedMB, user);
    }
}
