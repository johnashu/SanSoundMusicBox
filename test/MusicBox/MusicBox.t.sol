// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.18;

import {
    MintWithThreeUnboundedOrigin,
    ITokenLevels,
    IMusicBox,
    MusicBox
} from "test/Sanctuary/_MintWithThreeUnboundedOrigin.t.sol";

contract TestMusicBox is MintWithThreeUnboundedOrigin {
    address user;
    address char = makeAddr("CharactersAddress");
    address[] users;

    uint256[] batchFails = [1];
    uint256[] mulitpleMusicBox = [1, 2, 3, 4, 5, 6];

    function setUp() public {
        user = makeAddr("MusicBoxUser");
        users.push(user);
        _setUp(users, true);
        vm.stopPrank();
        vm.startPrank(user);
    }

    function testOwnerOfMusicBox() public {
        _mintWithMultiSanOrigin(notBoundTokens, user);

        assertEq((musicBox.owner() == OWNER), true);
    }

    function testSetCharactersAddress() public {
        vm.expectRevert();
        musicBox.setCharactersAddress(char);

        vm.expectRevert();
        musicBox.setCharactersAddress(address(0));

        vm.stopPrank();
        vm.prank(OWNER);
        musicBox.setCharactersAddress(char);

        assertEq(char, musicBox.charactersAddress());
    }

    function testSetLockUpTime() public {
        _mintWithMultiSanOrigin(notBoundTokens, user);

        testSetCharactersAddress();
        vm.stopPrank();
        vm.prank(char);
        uint256 lockupTime = block.timestamp + 10 days;
        musicBox.setLockupTime(lockupTime, 1, user);

        assertEq(musicBox.lockupTime(1), lockupTime);
        assertEq(uint256(IMusicBox.MusicBoxLevel.Locked), uint256(musicBox.tokenLevel(1)));

        vm.stopPrank();
        vm.prank(user);
        vm.expectRevert();
        musicBox.transferFrom(user, address(1), 1);
        vm.expectRevert();
        musicBox.safeTransferFrom(user, address(1), 1);
        vm.expectRevert();
        musicBox.safeTransferFrom(user, address(1), 1, "");
        vm.expectRevert();
        musicBox.batchTransferFrom(user, address(1), batchFails);
        vm.expectRevert();
        musicBox.batchSafeTransferFrom(user, address(1), batchFails, "");
    }

    function testFailSetLockUpTime_WrongCallingAddress() public {
        _mintWithMultiSanOrigin(notBoundTokens, user);

        testSetCharactersAddress();
        uint256 lockupTime = block.timestamp + 10 days;
        musicBox.setLockupTime(lockupTime, 1, user);
    }

    function testFailSetLockUpTime_LockupTimeZero() public {
        _mintWithMultiSanOrigin(notBoundTokens, user);

        testSetCharactersAddress();
        vm.stopPrank();
        vm.prank(char);
        uint256 lockupTime;
        musicBox.setLockupTime(lockupTime, 1, user);
    }

    function testFailSetLockUpTime_NotOwner() public {
        _mintWithMultiSanOrigin(notBoundTokens, user);

        testSetCharactersAddress();
        vm.stopPrank();
        vm.prank(char);
        uint256 lockupTime;
        musicBox.setLockupTime(lockupTime, 100, user);
    }

    function testFailMintFromSanctuary(address caller) public {
        vm.assume(caller != address(0));
        _mintWithMultiSanOrigin(notBoundTokens, user);

        musicBox.mintFromSantuary(caller, IMusicBox.MusicBoxLevel.Rare);
    }

    function testSetRoyalties() public {
        vm.expectRevert();
        musicBox.setRoyalties(user, 900);
        vm.stopPrank();
        vm.startPrank(OWNER);
        vm.expectRevert();
        musicBox.setRoyalties(user, 1000);
        musicBox.setRoyalties(user, 900);
        uint256 royaltyAmountExpected = 90000;
        (address receiver, uint256 royaltyAmount) = musicBox.royaltyInfo(uint256(0), uint256(1000000));
        assertEq(royaltyAmountExpected, royaltyAmount);
    }

    function testTransferFrom() public {
        // Fails covered in `testSetLockUpTime`
        for (uint256 i; i < multipleNotBoundTokens.length; i++) {
            _mintWithMultiSanOrigin(multipleNotBoundTokens[i], user);
        }

        musicBox.setApprovalForAll(user, true);

        musicBox.transferFrom(user, address(1), 1);
        musicBox.safeTransferFrom(user, address(1), 2);
        musicBox.safeTransferFrom(user, address(1), 3, "");
        musicBox.transferFrom(user, address(1), 4);
        musicBox.safeTransferFrom(user, address(1), 5);
        musicBox.safeTransferFrom(user, address(1), 6, "");
    }

    function testBatchSafeTransferFrom() public {
        // Fails covered in `testSetLockUpTime`
        for (uint256 i; i < multipleNotBoundTokens.length; i++) {
            _mintWithMultiSanOrigin(multipleNotBoundTokens[i], user);
        }

        musicBox.batchSafeTransferFrom(user, address(1), mulitpleMusicBox, "");
        mockSanOrigin.batchSafeTransferFrom(user, address(1), mulitpleMusicBox, "");
    }

    function testBatchTransferFrom() public {
        // Fails covered in `testSetLockUpTime`
        for (uint256 i; i < multipleNotBoundTokens.length; i++) {
            _mintWithMultiSanOrigin(multipleNotBoundTokens[i], user);
        }

        musicBox.batchTransferFrom(user, address(1), mulitpleMusicBox);
        mockSanOrigin.batchTransferFrom(user, address(1), mulitpleMusicBox);
    }
}
