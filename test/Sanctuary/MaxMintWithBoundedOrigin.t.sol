// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.18;

import {MintWithBoundedOrigin, ITokenLevels, IMusicBox, MusicBox} from "test/Sanctuary/_MintWithBoundedOrigin.t.sol";

contract TestMaxMintWithBoundedOrigin is MintWithBoundedOrigin {
    address user;
    address[] users;

    function setUp() public {
        user = makeAddr("OriginBoundedUser");
        users.push(user);
        _setUp(users, false);
        mockSanOrigin.makeAllBound();
        vm.stopPrank();
        vm.startPrank(user);
    }

    function testMAXMintWithBoundedOrigin() public payable {
        uint256 i = 1;
        matchIn = true;
        while (i < 10000) {
            _mintWithSanSoundBound(i, user);
            i++;
        }
    }
}
