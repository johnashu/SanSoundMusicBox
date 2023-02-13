// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.18;

import {TestBase, ITokenLevels, IMusicBox, MusicBox, IERC721} from "test/TestBase.sol";
import {MintWithBoundedOrigin} from "test/Sanctuary/_MintWithBoundedOrigin.t.sol";

contract TestERC721MusicBox is TestBase, MintWithBoundedOrigin {
    address user;
    address[] users;
    uint256[] expected = [1, 2, 3];
    uint256[] notExpected = [100, 200, 300];

    function setUp() public {
        user = makeAddr("ERC721MusicBoxUser");
        users.push(user);
        _setUp(users);
        vm.stopPrank();
        vm.startPrank(user);
    }

    function testFailSendNftToMusicBoxWithNoERC721Receiver() public {
        IERC721(mockERC721SingleAddress).approve(musicBoxAddress, 1);
        IERC721(mockERC721SingleAddress).safeTransferFrom(user, musicBoxAddress, 1);
    }

    function testSetRoyalties() public {
        vm.expectRevert();
        musicBox.setRoyalties(user, 900);
        vm.stopPrank();
        vm.prank(OWNER);
        musicBox.setRoyalties(user, 900);
    }

    function testWithdraw() public payable {
        uint256 deposit = 50 ether;
        uint256 withdraw = 10 ether;
        uint256 ownerBalance = OWNER.balance + withdraw;
        (bool sent,) = payable(musicBoxAddress).call{value: deposit}("");
        require(sent, "Failed to send Ether");
        vm.expectRevert();
        musicBox.withdraw(withdraw);
        vm.stopPrank();
        vm.prank(OWNER);
        musicBox.withdraw(withdraw);
        assertEq(ownerBalance, OWNER.balance);
    }

    function testSafeWithdrawAll() public payable {
        uint256 deposit = 50 ether;
        uint256 ownerBalance = OWNER.balance + deposit;

        (bool sent,) = payable(musicBoxAddress).call{value: deposit}("");
        require(sent, "Failed to send Ether");

        vm.expectRevert();
        musicBox.safeWithdrawAll();

        vm.stopPrank();
        vm.prank(OWNER);

        musicBox.safeWithdrawAll();
        assertEq(ownerBalance, OWNER.balance);
    }

    function testSetBaseURI() public {
        string memory _newURI = "Test String";
        vm.stopPrank();
        vm.prank(OWNER);
        musicBox.setBaseURI(_newURI);
        assertEq(musicBox.baseURI(), _newURI);
    }

    function testSetContractURI() public {
        string memory _newURI = "Test String";
        vm.stopPrank();
        vm.prank(OWNER);
        musicBox.setContractURI(_newURI);
        assertEq(musicBox.contractURI(), _newURI);
    }

    function testWalletOfOwner() public {
        _mintWithSanSoundBoundMultiple(isBoundTokens, user);
        uint256[] memory tokenIds = musicBox.walletOfOwner(user);
        assertEq(tokenIds, expected);
    }

    function testIsOwnerOf() public {
        _mintWithSanSoundBoundMultiple(isBoundTokens, user);
        assertTrue(musicBox.isOwnerOf(user, expected));
    }

    function testFailIsOwnerOf() public {
        _mintWithSanSoundBoundMultiple(isBoundTokens, user);
        assertTrue(musicBox.isOwnerOf(user, notExpected));
    }
}
