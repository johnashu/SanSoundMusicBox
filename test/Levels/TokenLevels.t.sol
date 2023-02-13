// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.18;

import {MintWithBoundedOrigin, ITokenLevels, IMusicBox, MusicBox} from "test/Sanctuary/_MintWithBoundedOrigin.t.sol";

contract TestLevels is MintWithBoundedOrigin {
    address user;
    address[] users;
    uint256[6] newLevelPrices;
    uint256[6] incLevelPrices;

    function setUp() public {
        user = makeAddr("TokensLevelUser");
        users.push(user);
        _setUp(users);
        vm.stopPrank();
        vm.startPrank(user);
        newLevelPrices[0] = 0;
        newLevelPrices[1] = 0;
        newLevelPrices[2] = 11100000000000000;
        newLevelPrices[3] = 22200000000000000;
        newLevelPrices[3] = 33300000000000000;
        newLevelPrices[5] = 444000000000000000;

        incLevelPrices[0] = 0;
        incLevelPrices[1] = 0;
        incLevelPrices[2] = 11100000000000000;
        incLevelPrices[3] = 22200000000000000;
        incLevelPrices[3] = 11100000000000000;
        incLevelPrices[5] = 444000000000000000;
    }

    function testSetLevelPrices() public {
        vm.stopPrank();
        vm.prank(OWNER);
        sanctuary.setLevelPrices(newLevelPrices);
        for (uint256 i = 0; i < newLevelPrices.length; i++) {
            assertEq(sanctuary.levelPrice(ITokenLevels.TokenLevel(i)), newLevelPrices[i]);
        }
    }

    function testFailSetLevelPricesNotOwner(address caller) public {
        vm.stopPrank();
        vm.prank(caller);
        sanctuary.setLevelPrices(newLevelPrices);
        for (uint256 i = 0; i < newLevelPrices.length; i++) {
            assertEq(sanctuary.levelPrice(ITokenLevels.TokenLevel(i)), newLevelPrices[i]);
        }
    }

    function testUserMaxTokenLevel() public {
        _mintWithSanSoundBoundMultiple(isBoundTokens, user);
        sanctuary.userMaxTokenLevel(user);
        // if (ITokenLevels.TokenLevel(1) != maxLevel) revert("Token LEvel Mismatch");
    }
}
