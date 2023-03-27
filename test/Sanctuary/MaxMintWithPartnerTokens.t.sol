// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.18;

import {MintWithPartnerTokens, ITokenLevels, IMusicBox, MusicBox} from "test/Sanctuary/_MintWithPartnerTokens.t.sol";

contract TestMaxMintWithPartnerTokens is MintWithPartnerTokens {
    address user;
    address[] users;

    function setUp() public {
        user = makeAddr("PartnerTokensUser");
        users.push(user);
        _setUp(users, false);
        mockERC721Single.transferAll(user, 40, 10000);
        vm.stopPrank();
        vm.startPrank(user);
    }

    function testMAXMintWithPartnerTokens() public payable {
        uint256 i = 1;
        matchInPartner = true;
        while (i < 10000) {
            _mintWithPartner(mockERC721SingleAddress, i, i, user);
            i++;
        }
    }
}
