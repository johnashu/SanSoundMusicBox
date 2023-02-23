// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.18;

import {TestERC721Base, Strings} from "test/ERC721/ERC721TestBase.t.sol";

contract TestERC721MusicBox is TestERC721Base {
    function setUp() public {
        user = makeAddr("ERC721MusicBoxUser");
        users.push(user);
        _setUp(users);
        vm.stopPrank();
        vm.startPrank(user);
        erc721Contract = musicBox;
        erc721ContractAddress = musicBoxAddress;
    }

    function testSetRoyalties() public {
        vm.expectRevert();
        musicBox.setRoyalties(user, 900);
        vm.stopPrank();
        vm.prank(OWNER);
        musicBox.setRoyalties(user, 900);
    }

    function testGetURI() public {
        _mintWithMultiSanOrigin(notBoundTokens, user);
        uint256 tokenId = 1;
        uint256 tokenLevel = 2;
        string memory _expectedURI = string(
            abi.encodePacked(
                "https://example.com/", Strings.toString(tokenLevel), "/", Strings.toString(tokenId), ".json"
            )
        );

        string memory receivedUri = erc721Contract.tokenURI(tokenId);

        emit log_string(_expectedURI);
        emit log_string(receivedUri);
        assertEq(receivedUri, _expectedURI);
    }
}
