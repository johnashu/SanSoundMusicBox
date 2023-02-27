// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.18;

import {TestBase, ITokenLevels, IMusicBox, MusicBox} from "test/TestBase.sol";

contract MintWithPartnerTokens is TestBase {
    bool matchInPartner = false;

    function _mintWithPartner(address _address, uint256 _toCheckPartner, uint256 _toCheckOrigin, address user)
        internal
    {
        uint256 _cur = 0;
        uint256 _new = 1;
        ITokenLevels.TokenLevel level = ITokenLevels.TokenLevel(_new);
        _addContracttoValidList(_address, true);

        vm.startPrank(user);
        _approveToken(_toCheckOrigin);

        sanctuary.mintFromPartner{value: _getPrice(_new, _cur)}(_toCheckOrigin, level, _toCheckPartner, _address);

        uint256 expected = _toCheckOrigin;
        if (!matchInPartner) {
            expected = expectedSingle;
        }

        __checkAfterMint(_toCheckOrigin, expected, level, user);
        _checkMusicBoxTokenLevel(IMusicBox.MusicBoxLevel.Common, expected, user);
    }
}
