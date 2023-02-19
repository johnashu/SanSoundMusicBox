// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.18;

import {TestBase} from "test/TestBase.sol";

contract TestCommon is TestBase {
    address user;
    address[] users;

    function setUp() public {
        user = makeAddr("CommonUser");
        users.push(user);
        _setUp(users);
        vm.stopPrank();
        vm.startPrank(user);
    }

    function testCheckOriginAddressIsValid() public {
        address san = sanctuary.SAN_ORIGIN_ADDRESS();
        assertTrue(sanctuary.isValidContract(san));
    }

    function testAddContractToValidListFuzzy(address _partnerAddress, bool _isValid) public {
        vm.assume(_partnerAddress != address(0));
        vm.assume(_partnerAddress != SAN_ORIGIN_ADDRESS);
        vm.stopPrank();
        vm.startPrank(OWNER);
        _addContracttoValidList(_partnerAddress, _isValid);
    }

    function testFailAddContractToValidList() public {
        vm.stopPrank();
        vm.startPrank(OWNER);
        vm.expectRevert();
        _addContracttoValidList(address(0), true);
        _addContracttoValidList(SAN_ORIGIN_ADDRESS, false);
    }
}
