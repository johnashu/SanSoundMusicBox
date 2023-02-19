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

    function testFailSetLevelPricesPriceIncrease() public {
        vm.stopPrank();
        vm.prank(OWNER);
        sanctuary.setLevelPrices(incorrectLevelPrices);
    }

    function testSetLevelPrices() public {
        vm.stopPrank();
        vm.prank(OWNER);
        sanctuary.setLevelPrices(newLevelPrices);
        for (uint256 i = 0; i < newLevelPrices.length; i++) {
            if (sanctuary.levelPrice(ITokenLevels.TokenLevel(i)) != newLevelPrices[i]) revert();
        }
    }

    function testFailSetLevelPricesNotOwner(address caller) public {
        vm.stopPrank();
        vm.prank(caller);
        sanctuary.setLevelPrices(newLevelPrices);
    }

    function testUserMaxTokenLevel() public {
        _mintWithSanSoundBound(isBoundSingleToken, user);
        ITokenLevels.TokenLevel maxLevel = sanctuary.userMaxTokenLevel(user);
        if (ITokenLevels.TokenLevel(1) != maxLevel) revert("Token LEvel Mismatch");
    }
}
