// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.18;

import {TestERC721Base, Strings} from "test/ERC721/ERC721TestBase.t.sol";

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

    function testGetURI() public {
        _mintWithMultiSanOrigin(notBoundTokens, user);
        for (uint256 i = 0; i < notBoundTokens.length; i++) {
            uint256 tokenId = notBoundTokens[i];
            uint256 tokenLevel = 1;
            string memory _expectedURI = string(
                abi.encodePacked(
                    "https://example.com/", Strings.toString(tokenLevel), "/", Strings.toString(tokenId), ".json"
                )
            );

            string memory receivedUri = erc721Contract.tokenURI(expectedMultiple[i]);

            emit log_string(_expectedURI);
            emit log_string(receivedUri);
            assertEq(receivedUri, _expectedURI);
        }
    }

    // No max mint per user required
    // function testFailExceedsUserMaxMint() public {
    //     for (uint256 i; i < multipleNotBoundTokens.length; i++) {
    //         _mintWithMultiSanOrigin(multipleNotBoundTokens[i], user);
    //     }
    // }

    // MAX SUPPLY IS DETERMINED BY SAN ORIGIN CONTRACT
    // function testFailExceedsMaxSupply() public {
    //     vm.assume(sanctuary.MAX_SUPPLY() == MOCK_MAX_SUPPLY);
    //     for (uint256 i; i < multipleNotBoundTokens.length; i++) {
    //         _mintWithMultiSanOrigin(multipleNotBoundTokens[i], user);
    //     }
    // }
}
