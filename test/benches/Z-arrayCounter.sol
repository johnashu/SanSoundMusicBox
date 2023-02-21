//SPDX-License-Identifier: UNLICENSED

/// @title Mock ERC721
/// @author Maffaz
import {Test} from "lib/forge-std/src/Test.sol";

pragma solidity ^0.8.18;

contract ArrayCounter {
    constructor() {
        for (uint256 i; i < 1000; i++) {
            array.push(i);
        }
    }

    mapping(uint256 => address) public ownerByTokenMap;
    address[] public _owners;

    uint256[] array;
    uint256 counter;

    function arrayLength() public view returns (uint256) {
        return array.length;
    }

    function getCounter() public view returns (uint256) {
        return counter;
    }

    function addArray(uint256 elem) public {
        array.push(elem);
    }

    function updateCounter() public {
        counter++;
    }

    function addOwnerByTokenMap(uint256 elem) public {
        ownerByTokenMap[elem] = msg.sender;
    }

    function addOwnerByTokenArray(address _address) public {
        _owners.push(_address);
    }

    function tokenOfOwnerByIndex(address owner) public view returns (uint256) {
        uint256 count;
        unchecked {
            for (uint256 i; i < _owners.length; i++) {
                if (owner == _owners[i]) {
                    return i;
                } else {
                    count++;
                }
            }
        }
    }
}

contract TestArrayCounter is Test {
    ArrayCounter ac;
    address findMe = makeAddr("FindMe");

    function setUp() public {
        ac = new ArrayCounter();
    }

    function testTokenOfOwnerByIndex() public {
        for (uint256 i; i < 10000; i++) {
            ac.tokenOfOwnerByIndex(findMe);
        }
    }

    function testGetCounter() public view {
        ac.getCounter();
    }

    function testArrayLength() public view {
        ac.arrayLength();
    }

    function testCounter() public {
        for (uint256 i; i < 10000; i++) {
            ac.updateCounter();
        }
    }

    function testArray() public {
        for (uint256 i; i < 10000; i++) {
            ac.addArray(i);
        }
    }

    function testAddOwnerByTokenArray() public {
        for (uint256 i; i < 10000; i++) {
            if (i == 5000) {
                ac.addOwnerByTokenArray(findMe);
            } else {
                ac.addOwnerByTokenArray(msg.sender);
            }
        }
    }

    function testAddOwnerByTokenMap() public {
        for (uint256 i; i < 10000; i++) {
            ac.addOwnerByTokenMap(i);
        }
    }
}
