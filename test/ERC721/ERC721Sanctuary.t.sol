// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.18;

import {TestERC721Base} from "test/ERC721/ERC721TestBase.t.sol";

contract TestERC721Sanctuary is TestERC721Base {
    function setUp() public {
        user = makeAddr("ERC721SanctuaryUser");
        users.push(user);
        _setUp(users);
        vm.stopPrank();
        vm.startPrank(user);
        erc721Contract = sanctuary;
        erc721ContractAddress = SANCTUARY_ADDRESS;
    }

    function testFailExceedsUserMaxMint() public {
        for (uint256 i; i < multipleNotBoundTokens.length; i++) {
            _mintWithMultiSanOrigin(multipleNotBoundTokens[i], user);
        }
    }

    function testFailExceedsMaxSupply() public {
        vm.assume(sanctuary.MAX_SUPPLY() == MOCK_MAX_SUPPLY);
        for (uint256 i; i < multipleNotBoundTokens.length; i++) {
            _mintWithMultiSanOrigin(multipleNotBoundTokens[i], user);
        }
    }
}
