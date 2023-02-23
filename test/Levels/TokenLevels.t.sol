// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.18;

import {MintWithBoundedOrigin, IMusicBox, MusicBox} from "test/Sanctuary/_MintWithBoundedOrigin.t.sol";
import {ITokenLevels} from "src/interfaces/Levels/ITokenLevels.sol";

contract TestLevels is MintWithBoundedOrigin {
    address user;
    address[] users;
    uint256[6] newLevelPrices = [0, 0, 11100000000000000, 22200000000000000, 33300000000000000, 444000000000000000];
    uint256[6] incorrectLevelPrices =
        [0, 0, 11100000000000000, 22200000000000000, 11100000000000000, 444000000000000000];

    function setUp() public {
        user = makeAddr("TokensLevelUser");
        users.push(user);
        _setUp(users);
        vm.stopPrank();
        vm.startPrank(user);
    }

    function testSetLevelPrices() public {
        vm.stopPrank();
        vm.prank(OWNER);
        sanctuary.setLevelPrices(newLevelPrices);
        for (uint256 i; i < newLevelPrices.length; i++) {
            if (sanctuary.levelPrice(ITokenLevels.TokenLevel(i)) != newLevelPrices[i]) revert();
        }
    }

    function testFailSetLevelPricesPriceIncrease() public {
        vm.stopPrank();
        vm.prank(OWNER);
        sanctuary.setLevelPrices(incorrectLevelPrices);
    }

    function testFailSetLevelPricesNotOwner(address caller) public {
        vm.stopPrank();
        vm.prank(caller);
        sanctuary.setLevelPrices(newLevelPrices);
    }

    function testUserMaxTokenLevel() public {
        _mintWithSanSoundBound(isBoundSingleToken, user);
        ITokenLevels.TokenLevel maxLevel = sanctuary.userMaxTokenLevel(user);
        assertTrue(ITokenLevels.TokenLevel.Citizen == maxLevel);
    }

    function testFailUserMaxTokenLevelNoTokens() public {
        _mintWithSanSoundBound(isBoundSingleToken, user);
        vm.stopPrank();
        vm.startPrank(makeAddr("NoTokensUser"));
        ITokenLevels.TokenLevel maxLevel = sanctuary.userMaxTokenLevel(user);
        assertTrue(ITokenLevels.TokenLevel.Unbound == maxLevel);
    }

    function testFailUpgradeTokenTokenNotOwned(address caller) public {
        _mintWithSanSoundBound(isBoundSingleToken, user);
        vm.stopPrank();
        vm.prank(caller);
        sanctuary.upgradeTokenLevel(1, ITokenLevels.TokenLevel.Citizen);
    }

    function testFailUpgradeTokenTokenUnBound() public {
        _mintWithSanSoundBound(isBoundSingleToken, user);
        sanctuary.upgradeTokenLevel(1, ITokenLevels.TokenLevel.Unbound);
    }

    function testFailUpgradeTokenLevelAlreadyReached(address caller) public {
        _mintWithSanSoundBound(isBoundSingleToken, user);
        sanctuary.upgradeTokenLevel(1, ITokenLevels.TokenLevel.Rebirthed);
    }
}
