// // SPDX-License-Identifier: UNLICENSED
// pragma solidity ^0.8.18;

// import "lib/forge-std/src/Test.sol";
// import "src/MusicBox.sol";

// contract TestMusicBox is Test {
//     MusicBox musicBox;
//     ISanOriginNFT sanOriginNFT;

//     address user = 0x8D23fD671300c409372cFc9f209CDA59c612081a;

//     function setUp() public {
//         uint256[] memory _levelPrices = new uint[](5);
//         _levelPrices[0] = 0;
//         _levelPrices[1] = 333000000000000000;
//         _levelPrices[2] = 633000000000000000;
//         _levelPrices[3] = 963000000000000000;
//         _levelPrices[4] = 5000000000000000000;

//         musicBox = new MusicBox(
//             string("SanSoundMusicBox"),
//             string("SMB"),
//             string("https://example.com/"),
//             string(""),
//             _levelPrices
//         );
//         sanOriginNFT = musicBox.sanOriginNFT();
//     }

//     function testMint() public {
//         uint256[] memory notBoundTokens = new uint[](3);
//         notBoundTokens[0] = 452;
//         notBoundTokens[1] = 472;
//         notBoundTokens[2] = 6271;
//         uint256 tokenLevel = sanOriginNFT.tokenLevel(notBoundTokens[0]);
//         emit log_uint(tokenLevel);
//         vm.prank(user);
//         assertTrue(musicBox.mergeTokens(notBoundTokens, SANSoulbindable.SoulboundLevel(0)));
//         // try again, this time with revert
//         vm.prank(user);
//         vm.expectRevert();
//         assertTrue(musicBox.mergeTokens(notBoundTokens, SANSoulbindable.SoulboundLevel(0)));
//     }

//     function testFailMintNotBound() public {
//         uint256[] memory isBoundTokens = new uint[](3);

//         isBoundTokens[0] = 452;
//         isBoundTokens[1] = 1055;
//         isBoundTokens[2] = 3829;
//         vm.expectRevert();
//         vm.prank(user);
//         assertTrue(musicBox.mergeTokens(isBoundTokens, SANSoulbindable.SoulboundLevel(0)));
//     }

//     function testFailMintNotOwned() public {
//         uint256[] memory notBoundTokens = new uint[](3);
//         notBoundTokens[0] = 452;
//         notBoundTokens[1] = 471;
//         notBoundTokens[2] = 6222;

//         vm.expectRevert();
//         vm.prank(user);
//         assertTrue(musicBox.mergeTokens(notBoundTokens, SANSoulbindable.SoulboundLevel(0)));
//     }

//     // function testGetAllUnboundTokens() public returns (uint256[] memory) {
//     //     uint256[] memory notBound = new uint256[](10000);
//     //     uint256 c;
//     //     for (uint256 i = 1; i < 10000; i++) {
//     //         uint256 tokenLevel = sanOriginNFT.tokenLevel(i);
//     //         if (tokenLevel == 0) {
//     //             notBound[c] = i;
//     //         }
//     //         c++;
//     //     }

//     //     return notBound;
//     // }

//     //    function testIsBoundOriginTokens() public {
//     //     uint[] memory isBoundTokens = new uint[](3);

//     //     isBoundTokens[0] = 789;
//     //     isBoundTokens[1] = 1055;
//     //     isBoundTokens[2] = 3829;
//     //     assertTrue(musicBox.checkUserOwnsTokens(isBoundTokens, user));
//     // }

//     // function testGetAll() public // returns (uint[] memory, uint[] memory)
//     // {
//     //     uint balance = sanOriginNFT.balanceOf(user);
//     //     emit log_named_uint("User BALANCE: ", balance);
//     //     uint[] memory isBound = new uint256[](balance);
//     //     uint[] memory notBound = new uint256[](balance);
//     //     uint c;
//     //     for (uint i = 0; i < balance; i++) {
//     //         uint tokenId = sanOriginNFT.tokenOfOwnerByIndex(user, i);
//     //         uint tokenLevel = sanOriginNFT.tokenLevel(tokenId);
//     //         if (tokenLevel != 0) {
//     //             isBound[c] = tokenId;
//     //         } else {
//     //             notBound[c] = tokenId;
//     //         }
//     //         c++;
//     //     }

//     //     // return (isBound, notBound);
//     // }
//     // function testGetUserMintedOrigin() external {
//     //     uint minted = musicBox.getUserMintedOrigin(user);
//     //     emit log_named_uint("User Minted: ", minted);
//     //     assertEq(3, minted);
//     // }

//     // function testGetBalanceOfOrigin() external {
//     //     uint balance = musicBox.getBalanceOfOrigin(user);
//     //     emit log_named_uint("User BALANCE: ", balance);
//     //     assertEq(balance, 53);
//     // }

//     // function testUserSoulbindCreditsOrigin() external {
//     //     uint expected = 666000000000000000;
//     //     uint balance = musicBox.getUserSoulbindCreditsOrigin(user);
//     //     emit log_named_uint("User Soulbind credits: ", balance);
//     //     assertEq(balance, expected);
//     // }
// }
