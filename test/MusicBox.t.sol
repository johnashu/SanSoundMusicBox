// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.18;

import "lib/forge-std/src/Test.sol";
import "src/MusicBox.sol";
import "src/interfaces/MusicBox/IMusicBox.sol";
import {MockERC721} from "test/mockERC721.sol";
import {IERC721} from "src/interfaces/ERC721/IERC721.sol";

contract TestMusicBox is Test {
    uint256 constant FORK_BLOCK = 16507662;

    MusicBox musicBox;
    MockERC721 mockERC721Single;
    MockERC721 mockERC721Multi;

    address sanOriginAddress = 0x33333333333371718A3C2bB63E5F3b94C9bC13bE;

    address user = 0x8D23fD671300c409372cFc9f209CDA59c612081a;

    uint256[6] _levelPrices;

    uint256[] notBoundTokens = [452, 472, 6271];
    uint256[] isBoundTokens = [452, 1055, 3829]; // middle will fail.

    uint256[] notBoundTokensPartner = [452];
    uint256[] isBoundTokensPartner = [1055];

    uint256[] partnerTokensToCheckSingle = [1];
    uint256[] partnerTokensToCheckMulti = [2, 3, 4];
    address partnerTokenAddress;

    function setUp() public {
        vm.createSelectFork(vm.rpcUrl("mainnet"), FORK_BLOCK);
        vm.startPrank(user); // User becomes the owner of everything..
        vm.deal(user, 10 ether);
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
        mockERC721Single = new MockERC721();
        mockERC721Multi = new MockERC721();
    }

    function testCheckOriginAddressIsValid() public {
        address san = musicBox.sanOriginAddress();
        assertTrue(musicBox.isValidContract(san));
    }

    function testAddContractToValidListFuzzy(address _partnerAddress, uint8 _numTokensRequired, bool _isValid) public {
        vm.assume(_partnerAddress != address(0));
        vm.assume(_numTokensRequired != 0);
        _addContracttoValidList(_partnerAddress, _numTokensRequired, _isValid);
    }

    function _addContracttoValidList(address _partnerAddress, uint8 _numTokensRequired, bool _isValid) private {
        musicBox.updatePartnerAddress(_partnerAddress, _numTokensRequired, _isValid);
    }

    function testMintWithMultiSanOrigin() public payable {
        emit log_uint(user.balance);
        uint256 price = _levelPrices[1] - _levelPrices[0];
        bool success = musicBox.mintFromSanOrigin{value: price}(notBoundTokens, IMusicBox.AccessLevel(1));

        assertTrue(success);
        emit log_uint(user.balance);

        // try again, this time with revert
        vm.expectRevert();
        musicBox.mintFromSanOrigin{value: price}(notBoundTokens, IMusicBox.AccessLevel(1));
    }

    function testMintWithPartnerSingle() public {
        emit log_uint(user.balance);
        uint256 price = _levelPrices[1] - _levelPrices[0];

        _addContracttoValidList(address(mockERC721Single), 1, true);
        bool success = musicBox.mintFromPartner{value: price}(
            notBoundTokensPartner, IMusicBox.AccessLevel(1), partnerTokensToCheckSingle, address(mockERC721Single)
        );
        assertTrue(success);
        emit log_uint(user.balance);

        // try again, this time with revert
        vm.expectRevert();
        musicBox.mintFromPartner{value: price}(
            notBoundTokensPartner, IMusicBox.AccessLevel(1), partnerTokensToCheckSingle, address(mockERC721Single)
        );
    }

    function testMintWithPartnerMultiple() public {
        emit log_uint(user.balance);
        uint256 price = _levelPrices[1] - _levelPrices[0];

        _addContracttoValidList(address(mockERC721Multi), 3, true);
        bool success = musicBox.mintFromPartner{value: price}(
            notBoundTokensPartner, IMusicBox.AccessLevel(1), partnerTokensToCheckMulti, address(mockERC721Multi)
        );
        assertTrue(success);
        emit log_uint(user.balance);

        // try again, this time with revert
        vm.expectRevert();
        musicBox.mintFromPartner{value: price}(
            notBoundTokensPartner, IMusicBox.AccessLevel(1), partnerTokensToCheckMulti, address(mockERC721Multi)
        );
    }

    function testUpgradeAccessLevel() public {
        testMintWithMultiSanOrigin();
        uint256 price = _levelPrices[2] - _levelPrices[1];
        bool success = musicBox.upgradeAccessLevel{value: price}(1, IMusicBox.AccessLevel(2));

        assertTrue(success);
    }

    function testFailMintIsBound() public {
        assertTrue(musicBox.mintFromSanOrigin(isBoundTokens, IMusicBox.AccessLevel(0)));
    }

    function testFailMintNotOwned() public {
        vm.stopPrank(); // User becomes the owner of everything..
        vm.prank(address(1));
        assertTrue(musicBox.mintFromSanOrigin(isBoundTokens, IMusicBox.AccessLevel(0)));
    }
}
