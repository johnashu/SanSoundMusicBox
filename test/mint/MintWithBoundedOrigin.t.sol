// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.18;

import {TestBase, ITokenLevels, IMusicBox, MusicBox} from "test/TestBase.sol";

contract TestMintWithSoulBound is TestBase {
    address user;
    address[] users;

    function setUp() public {
        user = makeAddr("OriginBoundedUser");
        users.push(user);
        _setUp(users);
        vm.stopPrank();
        vm.startPrank(user);
    }

    function testMintWithSanSoundBoundSingle() public {
        _mintWithSanSoundBoundMultiple(isBoundTokensSingle);
    }

    function testMintWithSanSoundBoundMultiple() public {
        _mintWithSanSoundBoundMultiple(isBoundTokens);
    }

    function _mintWithSanSoundBoundMultiple(uint256[] memory _toCheck) private {
        uint256 _cur = 0;
        uint256 _new = 1;
        ITokenLevels.TokenLevel level = ITokenLevels.TokenLevel(_new);
        _approveAllTokens(_toCheck);

        sanctuary.mintFromSoulbound{value: _getPrice(_new, _cur)}(_toCheck, level);
        _checkAfterMint(_toCheck, level, user);
        _checkMusicBoxTokenLevel(IMusicBox.MusicBoxLevel.Legendary, 1, user);
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
        _failTransfer();
    }

    function testFailNoTokens() public {
        _mintWithSanSoundBoundMultiple(isBoundTokens);
    }
}
