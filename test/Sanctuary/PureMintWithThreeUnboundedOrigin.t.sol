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
        // _setUp(users, false);
        vm.stopPrank();
        vm.startPrank(user);
    }

    function testMAXMintWithMultiSanOrigin() public payable {
        // uint256[] memory tokens1 = uint256Sequential(1, 3);
        // for (uint256 i; i < tokens1.length; i++) {
        //     emit log_uint(tokens1[i]);
        // }

        uint256 i = 1;
        while (i < 9) {
            // emit log_uint(i);
            // emit log_uint(i + 3);

            // _mintWithMultiSanOrigin(uint256Sequential(i, i + 2), user);

            uint256[] memory tokens = uint256Sequential(i, i + 2);

            for (uint256 i; i < tokens.length; i++) {
                emit log_uint(tokens[i]);
            }

            i += 3;
        }

        // emit log_uint(i);
        // emit log_uint(i + 1);
        // emit log_uint(i + 3);
        // i = i + 3;
        // _mintWithMultiSanOrigin(uint256Sequential(i, i + 2), user);

        // _mintWithMultiSanOrigin(tokens, user);
    }
}
