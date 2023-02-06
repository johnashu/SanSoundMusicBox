// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.18;

import "lib/forge-std/src/Test.sol";
import "src/MusicBox.sol";
import "src/interfaces/MusicBox/IMusicBox.sol";

contract TestMusicBox is Test {
    uint256 constant FORK_BLOCK = 16507662;

    MusicBox musicBox;
    address sanOriginAddress = 0x33333333333371718A3C2bB63E5F3b94C9bC13bE;

    address user = 0x8D23fD671300c409372cFc9f209CDA59c612081a;

    uint256[6] _levelPrices;

    function setUp() public {
        vm.createSelectFork(vm.rpcUrl("mainnet"), FORK_BLOCK);
        _levelPrices[0] = 0;
        _levelPrices[1] = 333000000000000000;
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
    }

    function testCheckOriginAddressIsValid() public {
        address san = musicBox.sanOriginAddress();
        assertTrue(musicBox.isValidContract(san));
    }

    function testMintWithMultiSanOrigin() public {
        uint256[] memory notBoundTokens = new uint256[](3);
        notBoundTokens[0] = 452;
        notBoundTokens[1] = 472;
        notBoundTokens[2] = 6271;

        vm.startPrank(user);
        vm.deal(user, 10 ether);
        emit log_uint(user.balance);
        assertTrue(musicBox.mintFromSanOrigin(notBoundTokens, IMusicBox.TokenAccessLevel(0)));
        _upgradeAccessLevel();

        // try again, this time with revert
        vm.expectRevert();
        musicBox.mintFromSanOrigin(notBoundTokens, IMusicBox.TokenAccessLevel(0));

        _upgradeAccessLevel();
    }

    function _upgradeAccessLevel() public payable {
        (bool success, bytes memory data) =
            IMusicBox(address(musicBox)).upgradeAccessLevel(1, IMusicBox.TokenAccessLevel(2)){value: _levelPrices[5]}();
        // (
        // abi.encodeWithSignature(
        //     "upgradeAccessLevel(uint256,TokenAccessLevel)",
        //     "call upgradeAccessLevel",
        //     1,
        //     IMusicBox.TokenAccessLevel(2)
        // )
        // );

        // abi.encodeWithSelector(MyToken.balanceOf.selector, address(1)),
        // abi.encode(10)

        // emit log_boolean(success);

        // assertTrue(success);
    }

    // function testMintWithPartnerOrigin() public {
    //     uint256[] memory notBoundTokens = new uint256[](1);
    //     notBoundTokens[0] = 452;
    //     vm.prank(user);
    //     assertTrue(musicBox.mintFromSanOrigin(notBoundTokens, IMusicBox.TokenAccessLevel(0)));

    //     // try again, this time with revert
    //     vm.expectRevert();
    //     vm.prank(user);
    //     musicBox.mintFromSanOrigin(notBoundTokens, IMusicBox.TokenAccessLevel(0));
    // }

    // function testFailMintNotBound() public {
    //     uint256[] memory isBoundTokens = new uint256[](3);

    //     isBoundTokens[0] = 452;
    //     isBoundTokens[1] = 1055;
    //     isBoundTokens[2] = 3829;
    //     vm.prank(user);
    //     assertTrue(musicBox.mintFromSanOrigin(isBoundTokens, IMusicBox.TokenAccessLevel(0)));
    // }

    // function testFailMintNotOwned() public {
    //     uint256[] memory notBoundTokens = new uint256[](3);
    //     notBoundTokens[0] = 452;
    //     notBoundTokens[1] = 471;
    //     notBoundTokens[2] = 6222;

    //     vm.prank(user);
    //     assertTrue(musicBox.mintFromSanOrigin(notBoundTokens, IMusicBox.TokenAccessLevel(0)));
    // }
}
