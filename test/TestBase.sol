// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.18;

import {Test} from "lib/forge-std/src/Test.sol";
import {Rebirth} from "src/Rebirth.sol";
import {MusicBox} from "src/MusicBox.sol";
import {IRebirth} from "src/interfaces/Rebirth/IRebirth.sol";
import {MockERC721} from "test/mocks/mockERC721.sol";
import {IERC721} from "src/interfaces/ERC721/IERC721.sol";

abstract contract TestBase is Test {
    Rebirth rebirth;
    MusicBox musicBox;
    MockERC721 mockERC721Single;
    MockERC721 mockERC721Multi;

    address mockERC721SingleAddress;
    address mockERC721MultiAddress;

    address sanOriginAddress;
    address musicBoxAddress;

    address rebirthAddress;

    address user;

    uint256[6] _levelPrices;

    uint256[] partnerTokensToCheckSingle = [1];
    uint256[] partnerTokensToCheckMulti = [2, 3, 4];
    address partnerTokenAddress;

    uint256[] notBoundTokens;
    uint256[] isBoundTokens; // middle will fail.

    uint256[] notBoundTokensPartner;
    uint256[] isBoundTokensPartner;

    function initShared() public {
        vm.startPrank(user); // User becomes the owner of everything..
        vm.deal(user, 10 ether);
        _levelPrices[0] = 0;
        _levelPrices[1] = 333000000000000000;
        _levelPrices[2] = 633000000000000000;
        _levelPrices[3] = 963000000000000000;
        _levelPrices[4] = 5000000000000000000;
        _levelPrices[5] = 10000000000000000000;
    }

    function deployContracts() public {
        MusicBox musicBox = new MusicBox( string("SanSoundMusicBox"),
            string("SMB"),
            string("https://example.com/"),
            string(""));

        musicBoxAddress = address(musicBox);
        MockERC721 mockERC721Single = new MockERC721();
        mockERC721SingleAddress = address(mockERC721Single);
        MockERC721 mockERC721Multi = new MockERC721();
        mockERC721MultiAddress = address(mockERC721Multi);
        rebirth = new Rebirth(
            string("SanSoundRebirth"),
            string("SRB"),
            string("https://example.com/"),
            string(""),
            sanOriginAddress,
            musicBoxAddress,
            _levelPrices
        );

        rebirthAddress = address(rebirth);
    }

    function _approveAllTokens(uint256[] memory tokenIds) private {
        for (uint256 i = 0; i < tokenIds.length; i++) {
            IERC721(sanOriginAddress).approve(rebirthAddress, tokenIds[i]);
        }
    }

    function testCheckOriginAddressIsValid() public {
        address san = rebirth.sanOriginAddress();
        assertTrue(rebirth.isValidContract(san));
    }

    function testAddContractToValidListFuzzy(address _partnerAddress, uint8 _numTokensRequired, bool _isValid) public {
        vm.assume(_partnerAddress != address(0));
        vm.assume(_numTokensRequired != 0);
        _addContracttoValidList(_partnerAddress, _numTokensRequired, _isValid);
    }

    function _addContracttoValidList(address _partnerAddress, uint8 _numTokensRequired, bool _isValid) private {
        rebirth.updatePartnerAddress(_partnerAddress, _numTokensRequired, _isValid);
    }

    function testMintWithMultiSanOrigin() public payable {
        emit log_uint(user.balance);
        uint256 price = _levelPrices[1] - _levelPrices[0];
        _approveAllTokens(notBoundTokens);
        bool success = rebirth.mintFromSanOrigin{value: price}(notBoundTokens, IRebirth.AccessLevel(1));

        assertTrue(success);
        emit log_uint(user.balance);

        // try again, this time with revert
        vm.expectRevert();
        rebirth.mintFromSanOrigin{value: price}(notBoundTokens, IRebirth.AccessLevel(1));
    }

    function testMintWithPartnerSingle() public {
        emit log_uint(user.balance);
        uint256 price = _levelPrices[1] - _levelPrices[0];

        emit log_address(mockERC721SingleAddress);

        _addContracttoValidList(mockERC721SingleAddress, 1, true);
        _approveAllTokens(notBoundTokensPartner);
        bool success = rebirth.mintFromPartner{value: price}(
            notBoundTokensPartner, IRebirth.AccessLevel(1), partnerTokensToCheckSingle, mockERC721SingleAddress
        );
        assertTrue(success);
        emit log_uint(user.balance);

        // try again, this time with revert
        vm.expectRevert();
        rebirth.mintFromPartner{value: price}(
            notBoundTokensPartner, IRebirth.AccessLevel(1), partnerTokensToCheckSingle, mockERC721SingleAddress
        );
    }

    function testMintWithPartnerMultiple() public {
        emit log_uint(user.balance);
        uint256 price = _levelPrices[1] - _levelPrices[0];

        _addContracttoValidList(mockERC721MultiAddress, 3, true);
        _approveAllTokens(notBoundTokensPartner);

        bool success = rebirth.mintFromPartner{value: price}(
            notBoundTokensPartner, IRebirth.AccessLevel(1), partnerTokensToCheckMulti, mockERC721MultiAddress
        );
        assertTrue(success);
        emit log_uint(user.balance);

        // try again, this time with revert
        vm.expectRevert();
        rebirth.mintFromPartner{value: price}(
            notBoundTokensPartner, IRebirth.AccessLevel(1), partnerTokensToCheckMulti, mockERC721MultiAddress
        );
    }

    function testUpgradeAccessLevel() public {
        testMintWithMultiSanOrigin();
        uint256 price = _levelPrices[2] - _levelPrices[1];
        bool success = rebirth.upgradeAccessLevel{value: price}(1, IRebirth.AccessLevel(2));

        assertTrue(success);
    }

    function testFailMintIsBound() public {
        assertTrue(rebirth.mintFromSanOrigin(isBoundTokens, IRebirth.AccessLevel(0)));
    }

    function testFailMintNotOwned() public {
        vm.stopPrank(); // User becomes the owner of everything..
        vm.prank(address(1));
        assertTrue(rebirth.mintFromSanOrigin(isBoundTokens, IRebirth.AccessLevel(0)));
    }
}
