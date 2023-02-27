// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.18;

import {MintWithBoundedOrigin, ITokenLevels, IMusicBox, MusicBox} from "test/Sanctuary/_MintWithBoundedOrigin.t.sol";

contract TestMintWithBoundedOrigin is MintWithBoundedOrigin {
    address user;
    address[] users;

    function setUp() public {
        user = makeAddr("OriginBoundedUser");
        users.push(user);
        _setUp(users, true);
        vm.stopPrank();
        vm.startPrank(user);
    }

    function testMintWithSanSoundBound() public {
        _mintWithSanSoundBound(isBoundSingleToken, user);
    }

    function testUpgradeTokenLevelSoulBound() public {
        testMintWithSanSoundBound();
        _upgradeTokenLevelSoulBound(expectedSingle, 2, 3);
    }

    function testFailMintIsNotBound() public {
        sanctuary.mintFromSoulbound{value: _getPrice(1, 0)}(notBoundSingleToken, ITokenLevels.TokenLevel.Rebirthed);
    }

    function testFailMintNotOwned() public {
        vm.stopPrank();
        vm.prank(address(1));
        sanctuary.mintFromSoulbound{value: _getPrice(1, 0)}(isBoundSingleToken, ITokenLevels.TokenLevel.Rebirthed);
    }

    function testUnableToApproveOrTransfersWhenSoulBound() public {
        testMintWithSanSoundBound();
        _failTransfer();
        _upgradeTokenLevelSoulBound(expectedSingle, 2, 3);
        _failTransfer();
    }
}
