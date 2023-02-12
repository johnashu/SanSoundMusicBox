// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.18;

import {MintWithBoundedOrigin, ITokenLevels, IMusicBox, MusicBox} from "test/Sanctuary/_MintWithBoundedOrigin.t.sol";

contract TestMintWithBoundedOrigin is MintWithBoundedOrigin {
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
        _mintWithSanSoundBoundMultiple(isBoundTokensSingle, user);
    }

    function testMintWithSanSoundBoundMultiple() public {
        _mintWithSanSoundBoundMultiple(isBoundTokens, user);
    }

    function testUpgradeTokenLevelSoulBound() public {
        _mintWithSanSoundBoundMultiple(isBoundTokens, user);

        uint256 token = isBoundTokens[0];
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
        _mintWithSanSoundBoundMultiple(noTokens, user);
    }

    function testFailTokensWithDifferentLevels() public {
        _mintWithSanSoundBoundMultiple(isBoundTokensMismatched, user);
    }
}
