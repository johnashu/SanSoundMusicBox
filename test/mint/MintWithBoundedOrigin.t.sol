// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.18;

import {TestBase, ITokenLevels, IMusicBox, MusicBox} from "test/TestBase.sol";

contract TestMintWithSoulBound is TestBase {
    function testMintWithSanSoundBoundSingle() public {
        _mintWithSanSoundBoundMultiple(isBoundTokensSingle);
    }

    function testMintWithSanSoundBoundMultiple() public {
        _mintWithSanSoundBoundMultiple(isBoundTokens);
    }

    function _mintWithSanSoundBoundMultiple(uint256[] memory _toCheck) private {
        ITokenLevels.TokenLevel level = ITokenLevels.TokenLevel(1);
        uint256 _cur = 0;
        uint256 _new = 1;
        _approveAllTokens(_toCheck);

        sanctuary.mintFromSoulbound{value: _getPrice(1, 0)}(_toCheck, ITokenLevels.TokenLevel(1));
        _checkAfterMint(_toCheck, level);
        _checkMusicBoxTokenLevel(IMusicBox.MusicBoxLevel(0), 1);
    }

    function testUpgradeTokenLevelSoulBound() public {
        testMintWithSanSoundBoundMultiple();

        uint256 token = 1;
        ITokenLevels.TokenLevel level = ITokenLevels.TokenLevel(2);
        uint256 _cur = 1;
        uint256 _new = 2;

        sanctuary.upgradeTokenLevel{value: _getPrice(_new, _cur)}(token, level);
        _checkSanctuaryTokenLevel(level, token);
    }

    function testFailMintIsNotBound() public {
        sanctuary.mintFromSoulbound{value: _getPrice(1, 0)}(notBoundTokens, ITokenLevels.TokenLevel(1));
    }

    function testFailMintNotOwned() public {
        vm.stopPrank();
        vm.prank(address(1));
        sanctuary.mintFromSoulbound{value: _getPrice(1, 0)}(isBoundTokens, ITokenLevels.TokenLevel(1));
    }

    function testFailTransferWhenSoulBound() public {
        testUpgradeTokenLevelSoulBound();
        sanctuary.transferFrom(msg.sender, address(0x1), 1);
        sanctuary.transferFrom(msg.sender, address(0x0), 1);
    }
}
