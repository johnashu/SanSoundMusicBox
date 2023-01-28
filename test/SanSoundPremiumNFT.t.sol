// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.17;

import "forge-std/Test.sol";
import "../src/SanSoundPremiumNFT.sol";

contract TestSanSoundPremiumNFT is DSTest {
    SanSoundPremiumNFT sanPremiumNFT;
    ISanOrigin sanOriginSoulBound;

    address alice = address(1);
    address bob = address(2);

    function setUp() public {
        sanPremiumNFT = new SanSoundPremiumNFT();
        sanOriginSoulBound = sanPremiumNFT.sanOriginSoulBound();
    }

    function testMint() public {
        sanPremiumNFT.mint(alice, 1);
        sanPremiumNFT.mint(bob, 1);
    }

    function testGetUserMintedOrigin() external {
        address user = 0x8D23fD671300c409372cFc9f209CDA59c612081a;
        emit log_named_address("\nuser address", user);
        uint stateFromSanOrigin = sanPremiumNFT.getUserMintedOrigin(user);
        emit log_named_uint("User Minted: ", stateFromSanOrigin);
    }

    function testGetBalanceOfOrigin() external {
        address user = 0x8D23fD671300c409372cFc9f209CDA59c612081a;
        emit log_named_address("\nuser address", user);
        uint balance = sanPremiumNFT.getBalanceOfOrigin(user);
        emit log_named_uint("User BALANCE: ", balance);
    }

    function testUserSoulbindCreditsOrigin() external {
        uint expected = 666000000000000000;
        address user = 0x8D23fD671300c409372cFc9f209CDA59c612081a;
        emit log_named_address("\nuser address", user);
        uint balance = sanPremiumNFT.getUserSoulbindCreditsOrigin(user);
        emit log_named_uint("User BALANCE: ", balance);
        assertEq(balance, expected);
    }
}
