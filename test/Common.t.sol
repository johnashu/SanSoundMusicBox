// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.18;

import {TestBase} from "test/TestBase.sol";

contract TestCommon is TestBase {
    function testOwnerIsSanctuary() public {
        address ownerAddress = musicBox.owner();
        emit log_address(ownerAddress);
        assertEq((ownerAddress == sanctuaryAddress), true);
    }

    function testCheckOriginAddressIsValid() public {
        address san = sanctuary.SAN_ORIGIN_ADDRESS();
        assertTrue(sanctuary.isValidContract(san));
    }

    function testAddContractToValidListFuzzy(address _partnerAddress, uint8 _numTokensRequired, bool _isValid) public {
        vm.assume(_partnerAddress != address(0));
        vm.assume(_numTokensRequired != 0);
        _addContracttoValidList(_partnerAddress, _numTokensRequired, _isValid);
    }

    function testFailAddContractToValidList() public {
        vm.expectRevert();
        _addContracttoValidList(address(0), 2, true);
        _addContracttoValidList(msg.sender, 0, false);
    }
}
