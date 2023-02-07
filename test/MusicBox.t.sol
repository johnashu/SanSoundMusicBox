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
    uint256[] notBoundTokens = [452, 472, 6271];
    uint256[] notBoundTokensPartner = [452];
    uint256[] isBoundTokens = [452, 1055, 3829]; // middle will fail.
    uint256[] isBoundTokensPartner = [1055];
    uint[] partnerTokensToCheck = [1];
    address partnerTokenAddress;

    function setUp() public {
        vm.createSelectFork(vm.rpcUrl("mainnet"), FORK_BLOCK);
        _levelPrices[0] = 0;
        _levelPrices[1] = 333000000000000000;
        _levelPrices[2] = 633000000000000000;
        _levelPrices[3] = 963000000000000000;
        _levelPrices[4] = 5000000000000000000;
        _levelPrices[5] = 10000000000000000000;

        musicBox = new MusicBox(
            string("SanSoundMusicBox"),
            string("SMB"),
            string("https://example.com/"),
            string(""),
            _levelPrices
        );
        vm.startPrank(user);
        vm.deal(user, 10 ether);
    }

    function testCheckOriginAddressIsValid() public {
        address san = musicBox.sanOriginAddress();
        assertTrue(musicBox.isValidContract(san));
    }

    function testMintWithMultiSanOrigin() public payable {
        emit log_uint(user.balance);
        uint256 price = _levelPrices[1] - _levelPrices[0];
        bool success = musicBox.mintFromSanOrigin{value: price}(notBoundTokens, IMusicBox.AccessLevel(1));

        assertTrue(success);
        emit log_uint(user.balance);

        // try again, this time with revert
        vm.expectRevert();
        musicBox.mintFromSanOrigin(notBoundTokens, IMusicBox.AccessLevel(1));
    }

    function testUpgradeAccessLevel() public {
        testMintWithMultiSanOrigin();
        uint256 price = _levelPrices[2] - _levelPrices[1];
        bool success = musicBox.upgradeAccessLevel{value: price}(1, IMusicBox.AccessLevel(2));

        assertTrue(success);
    }

    function testMintWithPartnerOrigin() public {
        emit log_uint(user.balance);
        uint256 price = _levelPrices[1] - _levelPrices[0];
        bool success = musicBox.mintFromPartner{value: price}(notBoundTokensPartner, IMusicBox.AccessLevel(1), );

        assertTrue(success);
        emit log_uint(user.balance);

        // try again, this time with revert
        vm.expectRevert();
        musicBox.mintFromSanOrigin(notBoundTokens, IMusicBox.AccessLevel(1));
    }

    function testFailMintNotBound() public {
        vm.prank(user);
        assertTrue(musicBox.mintFromSanOrigin(isBoundTokens, IMusicBox.AccessLevel(0)));
    }

    function testFailMintNotOwned() public {
        vm.prank(user);
        assertTrue(musicBox.mintFromSanOrigin(notBoundTokens, IMusicBox.AccessLevel(0)));
    }
}
