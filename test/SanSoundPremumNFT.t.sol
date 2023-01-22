// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.17;

import "forge-std/Test.sol";
import "../src/SanSoundPremiumNFT.sol";

contract SanSoundPremiumNFTTest is Test {
    SanSoundPremiumNFT public sanSoundPremiumNFT;

    function setUp() public {
        sanSoundPremiumNFT = new SanSoundPremiumNFT();
        sanSoundPremiumNFT.setNumber(0);
    }

    function testIncrement() public {
        sanSoundPremiumNFT.increment();
        assertEq(sanSoundPremiumNFT.number(), 1);
    }

    function testSetNumber(uint256 x) public {
        sanSoundPremiumNFT.setNumber(x);
        assertEq(sanSoundPremiumNFT.number(), x);
    }
}
