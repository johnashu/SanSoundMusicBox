// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.18;

import {TestBase, ITokenLevels, IMusicBox, MusicBox, IERC721} from "test/TestBase.sol";

contract MintWithThreeUnBounded is TestBase {
    function _mintWithMultiSanOrigin(uint256[] memory tokens, address user) internal {
        uint256 _cur = 0;
        uint256 _new = 1;
        ITokenLevels.TokenLevel level = ITokenLevels.TokenLevel(_new);

        _approveAllTokens(tokens);
        // Mint the Tokens
        sanctuary.mintFromSanOrigin{value: _getPrice(_new, _cur)}(tokens, level);
        _checkAfterMint(tokens, level, user);
        _checkMusicBoxTokenLevel(IMusicBox.MusicBoxLevel.Rare, 1, user);
    }
}
