// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.18;

import {MintWithBoundedOrigin, ITokenLevels, IMusicBox, MusicBox} from "test/Sanctuary/_MintWithBoundedOrigin.t.sol";

contract TestMusicBox is MintWithBoundedOrigin {
    address user;
    address[] users;

    function setUp() public {
        user = makeAddr("MusicBoxUser");
        users.push(user);
        _setUp(users);
        vm.stopPrank();
        vm.startPrank(user);
    }

    function testFailMintFromSanctuary(address caller) public {
        vm.assume(caller != address(0));
        _mintWithSanSoundBoundMultiple(isBoundTokens, user);
        musicBox.mintFromSantuary(caller, IMusicBox.MusicBoxLevel.Rare, 1);
    }
}
