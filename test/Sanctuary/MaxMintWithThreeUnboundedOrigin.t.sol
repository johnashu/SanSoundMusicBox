// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.18;

import {
    MintWithThreeUnboundedOrigin,
    ITokenLevels,
    IMusicBox,
    MusicBox
} from "test/Sanctuary/_MintWithThreeUnboundedOrigin.t.sol";

contract TestMaxMintWithThreeUnboundedOrigin is MintWithThreeUnboundedOrigin {
    address user;
    address[] users;

    function setUp() public {
        user = makeAddr("ThreeUnboundedUser");
        users.push(user);
        _setUp(users, false);
        vm.stopPrank();
        vm.startPrank(user);
    }

    function testMAXMintWithMultiSanOrigin() public payable {
        uint256 i = 1;
        matchIn3Unbounded = true;
        while (i < 10000) {
            uint256[] memory tokens = uint256Sequential(i, i + 2);
            _mintWithMultiSanOrigin(tokens, user);
            i += 3;
        }
    }
}
