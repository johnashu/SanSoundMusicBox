// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.17;

import "forge-std/Test.sol";
import "../src/SanSoundPremiumNFT.sol";

contract TestSanSoundPremiumNFT is Test {
    SanSoundPremiumNFT sanPremiumNFT;
    ISanOrigin sanOriginSoulBound;

    address alice = address(1);
    address bob = address(2);

    address user = 0x8D23fD671300c409372cFc9f209CDA59c612081a;

    function setUp() public {
        sanPremiumNFT = new SanSoundPremiumNFT();
        sanOriginSoulBound = sanPremiumNFT.sanOriginSoulBound();
    }

    function testMint() public {
        uint16[] memory isBoundTokens = new uint16[](3);

        isBoundTokens[0] = 789;
        isBoundTokens[1] = 1055;
        isBoundTokens[2] = 3829;
        assertTrue(sanPremiumNFT.mint(user, isBoundTokens));
    }

    function testFailMintNotBound() public {
        uint16[] memory notBoundTokens = new uint16[](3);
        notBoundTokens[0] = 452;
        notBoundTokens[1] = 472;
        notBoundTokens[2] = 6271;
        vm.expectRevert();
        assertTrue(sanPremiumNFT.mint(user, notBoundTokens));
    }

    function testFailMintNotOwned() public {
        uint16[] memory notBoundTokens = new uint16[](3);
        notBoundTokens[0] = 451;
        notBoundTokens[1] = 471;
        notBoundTokens[2] = 6222;
        vm.expectRevert();
        assertTrue(sanPremiumNFT.mint(user, notBoundTokens));
    }
    // function testIsBoundOriginTokens() public {
    //     uint16[] memory isBoundTokens = new uint16[](3);

    //     isBoundTokens[0] = 789;
    //     isBoundTokens[1] = 1055;
    //     isBoundTokens[2] = 3829;
    //     assertTrue(sanPremiumNFT.checkUserOwnsTokens(isBoundTokens, user));
    // }

    // function testGetAll() public // returns (uint[] memory, uint[] memory)
    // {
    //     uint balance = sanOriginSoulBound.balanceOf(user);
    //     emit log_named_uint("User BALANCE: ", balance);
    //     uint[] memory isBound = new uint256[](balance);
    //     uint[] memory notBound = new uint256[](balance);
    //     uint c;
    //     for (uint i = 0; i < balance; i++) {
    //         uint tokenId = sanOriginSoulBound.tokenOfOwnerByIndex(user, i);
    //         uint tokenLevel = sanOriginSoulBound.tokenLevel(tokenId);
    //         if (tokenLevel != 0) {
    //             isBound[c] = tokenId;
    //         } else {
    //             notBound[c] = tokenId;
    //         }
    //         c++;
    //     }

    //     // return (isBound, notBound);
    // }
    // function testGetUserMintedOrigin() external {
    //     uint minted = sanPremiumNFT.getUserMintedOrigin(user);
    //     emit log_named_uint("User Minted: ", minted);
    //     assertEq(3, minted);
    // }

    // function testGetBalanceOfOrigin() external {
    //     uint balance = sanPremiumNFT.getBalanceOfOrigin(user);
    //     emit log_named_uint("User BALANCE: ", balance);
    //     assertEq(balance, 53);
    // }

    // function testUserSoulbindCreditsOrigin() external {
    //     uint expected = 666000000000000000;
    //     uint balance = sanPremiumNFT.getUserSoulbindCreditsOrigin(user);
    //     emit log_named_uint("User Soulbind credits: ", balance);
    //     assertEq(balance, expected);
    // }
}
