// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.18;

import "lib/forge-std/src/Test.sol";
import "src/MusicBox.sol";

contract TestMusicBox is Test {
    uint256 constant FORK_BLOCK = 16507662;

    MusicBox musicBox;
    ISanOriginNFT sanOriginNFT;

    address user = 0x8D23fD671300c409372cFc9f209CDA59c612081a;

    function setUp() public {
        vm.createSelectFork(vm.rpcUrl("mainnet"), FORK_BLOCK);
        uint256[] memory _levelPrices = new uint[](6);
        _levelPrices[0] = 0;
        _levelPrices[1] = 0;
        _levelPrices[2] = 333000000000000000;
        _levelPrices[3] = 633000000000000000;
        _levelPrices[4] = 963000000000000000;
        _levelPrices[5] = 5000000000000000000;

        musicBox = new MusicBox(
            string("SanSoundMusicBox"),
            string("SMB"),
            string("https://example.com/"),
            string(""),
            _levelPrices
        );
        sanOriginNFT = musicBox.sanOriginNFT();
    }

    function testMint() public {
        uint256[3] memory notBoundTokens;
        notBoundTokens[0] = 452;
        notBoundTokens[1] = 472;
        notBoundTokens[2] = 6271;
        uint256 tokenLevel = sanOriginNFT.tokenLevel(notBoundTokens[0]);
        emit log_uint(tokenLevel);
        vm.prank(user);
        assertTrue(musicBox.mergeTokens(notBoundTokens, IMusicBox.SoulboundLevel(0)));

        // try again, this time with revert
        vm.expectRevert();
        vm.prank(user);
        musicBox.mergeTokens(notBoundTokens, IMusicBox.SoulboundLevel(0));
    }

    function testFailMintNotBound() public {
        uint256[3] memory isBoundTokens;

        isBoundTokens[0] = 452;
        isBoundTokens[1] = 1055;
        isBoundTokens[2] = 3829;
        vm.prank(user);
        assertTrue(musicBox.mergeTokens(isBoundTokens, IMusicBox.SoulboundLevel(0)));
    }

    function testFailMintNotOwned() public {
        uint256[3] memory notBoundTokens;
        notBoundTokens[0] = 452;
        notBoundTokens[1] = 471;
        notBoundTokens[2] = 6222;

        vm.prank(user);
        assertTrue(musicBox.mergeTokens(notBoundTokens, IMusicBox.SoulboundLevel(0)));
    }
}
