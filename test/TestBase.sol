// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.18;

import {Test} from "lib/forge-std/src/Test.sol";
import {Rebirth} from "src/Rebirth.sol";
import {ITokenLevels} from "src/interfaces/Levels/ITokenLevels.sol";

import {MusicBox} from "src/MusicBox.sol";
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
        _levelPrices[1] = 0;
        _levelPrices[2] = 333000000000000000;
        _levelPrices[3] = 633000000000000000;
        _levelPrices[3] = 963000000000000000;
        _levelPrices[5] = 5000000000000000000;
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
        address san = rebirth.SAN_ORIGIN_ADDRESS();
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
        rebirth.mintFromSanOrigin{value: price}(notBoundTokens, ITokenLevels.TokenLevel(1));

        emit log_uint(user.balance);

        // try again, this time with revert
        vm.expectRevert();
        rebirth.mintFromSanOrigin{value: price}(notBoundTokens, ITokenLevels.TokenLevel(1));
    }

    function testMintWithPartnerSingle() public {
        emit log_uint(user.balance);
        uint256 price = _levelPrices[1] - _levelPrices[0];

        emit log_address(mockERC721SingleAddress);

        _addContracttoValidList(mockERC721SingleAddress, 1, true);
        _approveAllTokens(notBoundTokensPartner);
        rebirth.mintFromPartner{value: price}(
            notBoundTokensPartner, ITokenLevels.TokenLevel(1), partnerTokensToCheckSingle, mockERC721SingleAddress
        );
        emit log_uint(user.balance);

        // try again, this time with revert
        vm.expectRevert();
        rebirth.mintFromPartner{value: price}(
            notBoundTokensPartner, ITokenLevels.TokenLevel(1), partnerTokensToCheckSingle, mockERC721SingleAddress
        );
    }

    function testMintWithPartnerMultiple() public {
        emit log_uint(user.balance);
        uint256 price = _levelPrices[1] - _levelPrices[0];

        _addContracttoValidList(mockERC721MultiAddress, 3, true);
        _approveAllTokens(notBoundTokensPartner);

        rebirth.mintFromPartner{value: price}(
            notBoundTokensPartner, ITokenLevels.TokenLevel(1), partnerTokensToCheckMulti, mockERC721MultiAddress
        );

        emit log_uint(user.balance);

        // try again, this time with revert
        vm.expectRevert();
        rebirth.mintFromPartner{value: price}(
            notBoundTokensPartner, ITokenLevels.TokenLevel(1), partnerTokensToCheckMulti, mockERC721MultiAddress
        );
    }

    function testUpgradeTokenLevel() public {
        testMintWithMultiSanOrigin();
        uint256 price = _levelPrices[2] - _levelPrices[1];
        rebirth.upgradeTokenLevel{value: price}(1, ITokenLevels.TokenLevel(2));
    }

    function testFailMintIsBound() public {
        rebirth.mintFromSanOrigin(isBoundTokens, ITokenLevels.TokenLevel(0));
    }

    function testFailMintNotOwned() public {
        vm.stopPrank(); // User becomes the owner of everything..
        vm.prank(address(1));
        rebirth.mintFromSanOrigin(isBoundTokens, ITokenLevels.TokenLevel(0));
    }
}
