// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.18;

import {TestBase, ITokenLevels, IMusicBox, MusicBox, IERC721} from "test/TestBase.sol";

contract TestSanctuary is TestBase {
    address user;
    address[] users;

    function setUp() public {
        user = makeAddr("SanctuaryUser");
        users.push(user);
        _setUp(users, true);
        vm.stopPrank();
        vm.startPrank(user);
    }

    function testCheckOriginAddressIsValid() public {
        address san = sanctuary.SAN_ORIGIN_ADDRESS();
        assertTrue(sanctuary.isValidContract(san));
    }

    function testFailCheckOriginAddressIsValid(address _partnerAddress) public {
        assertTrue(sanctuary.isValidContract(_partnerAddress));
    }

    function testAddContractToValidListFuzzy(address _partnerAddress) public {
        vm.assume(_partnerAddress != address(0));
        vm.assume(_partnerAddress != SAN_ORIGIN_ADDRESS);
        vm.stopPrank();
        vm.startPrank(OWNER);
        _addContracttoValidList(_partnerAddress, true);
        assertTrue(sanctuary.isValidContract(_partnerAddress));
    }

    function testFailAddContractToValidList() public {
        vm.stopPrank();
        vm.startPrank(OWNER);
        vm.expectRevert();
        _addContracttoValidList(address(0), true);
        _addContracttoValidList(SAN_ORIGIN_ADDRESS, false);
    }
}
