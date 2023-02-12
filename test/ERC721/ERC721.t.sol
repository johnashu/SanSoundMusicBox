// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.18;

import {TestBase, ITokenLevels, IMusicBox, MusicBox, IERC721} from "test/TestBase.sol";
import {MintWithBoundedOrigin} from "test/Sanctuary/_MintWithBoundedOrigin.t.sol";

contract TestERC721 is TestBase, MintWithBoundedOrigin {
    address user;
    address[] users;
    uint256[] expected = [1, 2, 3];
    uint256[] notExpected = [100, 200, 300];

    function setUp() public {
        user = makeAddr("ERC721User");
        users.push(user);
        _setUp(users);
        vm.stopPrank();
        vm.startPrank(user);
    }

    function testFailSendNftToSanctuaryWithNoERC721Receiver() public {
        IERC721(mockERC721SingleAddress).approve(SANCTUARY_ADDRESS, 1);
        IERC721(mockERC721SingleAddress).safeTransferFrom(user, SANCTUARY_ADDRESS, 1);
    }

    function testSetRoyalties() public {
        vm.expectRevert();
        sanctuary.setRoyalties(user, 900);
        vm.stopPrank();
        vm.prank(OWNER);
        sanctuary.setRoyalties(user, 900);
    }

    function testWithdraw() public payable {
        uint256 deposit = 50 ether;
        uint256 withdraw = 10 ether;
        uint256 ownerBalance = OWNER.balance + withdraw;
        (bool sent,) = payable(SANCTUARY_ADDRESS).call{value: deposit}("");
        require(sent, "Failed to send Ether");
        vm.expectRevert();
        sanctuary.withdraw(withdraw);
        vm.stopPrank();
        vm.prank(OWNER);
        sanctuary.withdraw(withdraw);
        assertEq(ownerBalance, OWNER.balance);
    }

    function testSafeWithdrawAll() public payable {
        uint256 deposit = 50 ether;
        uint256 ownerBalance = OWNER.balance + deposit;

        (bool sent,) = payable(SANCTUARY_ADDRESS).call{value: deposit}("");
        require(sent, "Failed to send Ether");

        vm.expectRevert();
        sanctuary.safeWithdrawAll();

        vm.stopPrank();
        vm.prank(OWNER);

        sanctuary.safeWithdrawAll();
        assertEq(ownerBalance, OWNER.balance);
    }

    function testSetBaseURI() public {
        string memory _newURI = "Test String";
        vm.stopPrank();
        vm.prank(OWNER);
        sanctuary.setBaseURI(_newURI);
        assertEq(sanctuary.baseURI(), _newURI);
    }

    function testSetContractURI() public {
        string memory _newURI = "Test String";
        vm.stopPrank();
        vm.prank(OWNER);
        sanctuary.setContractURI(_newURI);
        assertEq(sanctuary.contractURI(), _newURI);
    }

    function testWalletOfOwner() public {
        _mintWithSanSoundBoundMultiple(isBoundTokens, user);
        uint256[] memory tokenIds = musicBox.walletOfOwner(user);
        emit log_uint(tokenIds[0]);
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
