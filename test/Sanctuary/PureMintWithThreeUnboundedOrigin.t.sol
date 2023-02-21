// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.18;

import {
    MintWithThreeUnboundedOrigin,
    ITokenLevels,
    IMusicBox,
    MusicBox
} from "test/Sanctuary/_MintWithThreeUnboundedOrigin.t.sol";

contract TestMintWithThreeUnboundedOrigin is MintWithThreeUnboundedOrigin {
    address user;
    address[] users;

    function setUp() public {
        user = makeAddr("ThreeUnboundedUser");
        users.push(user);
        _setUp(users);
        vm.stopPrank();
        vm.startPrank(user);
    }

    function testMintWithMultiSanOrigin() public payable {
        _mintWithMultiSanOrigin(notBoundTokens, user);
    }
}
