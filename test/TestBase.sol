// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.18;

import {Test} from "lib/forge-std/src/Test.sol";
import {Sanctuary} from "src/Sanctuary.sol";
import {ITokenLevels} from "src/interfaces/Levels/ITokenLevels.sol";
import {IMusicBox} from "src/interfaces/MusicBox/IMusicBox.sol";

import {MusicBox} from "src/MusicBox.sol";
import {MockERC721} from "test/mocks/mockERC721.sol";
import {IERC721} from "src/interfaces/ERC721/IERC721.sol";
import {MockSanOrigin} from "test/mocks/mockSanOrigin.sol";

abstract contract TestBase is Test {
    Sanctuary sanctuary;
    MusicBox musicBox;
    MockERC721 mockERC721Single;
    MockERC721 mockERC721Multi;
    MockSanOrigin mockSanOrigin;

    address mockERC721SingleAddress;
    address mockERC721MultiAddress;

    address SAN_ORIGIN_ADDRESS;
    address musicBoxAddress;

    address SANCTUARY_ADDRESS;

    address OWNER = makeAddr("Owner");

    uint256[6] _levelPrices;

    uint256[] partnerTokensToCheckSingle = [15];
    uint256[] partnerTokensToCheckMulti = [4, 17, 6];

    uint256[] notBoundTokens;
    uint256[] isBoundTokens; // middle will fail.

    uint256[] notBoundTokensSingle;
    uint256[] isBoundTokensSingle;

    uint256[] notBoundTokensPartner;
    uint256[] isBoundTokensPartner;

    uint256[] tooManyNotBoundTokens;
    uint256[] tooManyIsBoundTokens;
    uint256[] noTokens;

    function _setUp(address[] memory users) internal {
        _initOWNERs();
        _initUsers(users);
        _initShared();
        _deployContracts();
        _transferTokens(users);
    }

    function _initOWNERs() internal {
        vm.startPrank(OWNER); // OWNER becomes the owner of everything..
        vm.deal(OWNER, 10 ether);
    }

    function _initUsers(address[] memory users) internal {
        for (uint256 i = 0; i < users.length; i++) {
            address user = users[i];
            vm.deal(user, 10 ether);
        }
    }

    function _initShared() internal {
        _levelPrices[0] = 0;
        _levelPrices[1] = 0;
        _levelPrices[2] = 333000000000000000;
        _levelPrices[3] = 633000000000000000;
        _levelPrices[3] = 963000000000000000;
        _levelPrices[5] = 5000000000000000000;
        notBoundTokens = [4, 5, 16];
        isBoundTokens = [21, 22, 23]; // middle will fail.
        tooManyNotBoundTokens = [1, 2, 13, 14];
        tooManyIsBoundTokens = [21, 22, 323, 34];

        notBoundTokensPartner = [15];
        isBoundTokensPartner = [28];

        notBoundTokensSingle = [13];
        isBoundTokensSingle = [38];
    }

    function _deployContracts() internal {
        mockSanOrigin = new MockSanOrigin();
        SAN_ORIGIN_ADDRESS = address(mockSanOrigin);

        mockERC721Single = new MockERC721();
        mockERC721SingleAddress = address(mockERC721Single);
        mockERC721Multi = new MockERC721();
        mockERC721MultiAddress = address(mockERC721Multi);
        sanctuary = new Sanctuary(
            string("SanSoundSanctuary"),
            string("SRB"),
            string("https://example.com/"),
            string(""),
            SAN_ORIGIN_ADDRESS,
            _levelPrices
        );

        SANCTUARY_ADDRESS = address(sanctuary);
        musicBoxAddress = address(sanctuary.MUSIC_BOX_ADDRESS());
        musicBox = MusicBox(musicBoxAddress);
    }

    function _transferTokens(address[] memory users) internal {
        uint256 userLen = users.length;
        uint256 split = 40 / userLen;
        for (uint256 i = 0; i < userLen; ++i) {
            address user = users[i];
            uint256 start = (i * split) + 1;
            uint256 end = split * (i + 1);

            mockERC721Single.transferAll(user, start, end);
            mockERC721Multi.transferAll(user, start, end);

            uint256 offset = 0;
            if (userLen == 1) {
                offset = 1;
            }
            uint256 calc = split / (userLen + offset);
            mockSanOrigin.TransferUnbound(user, start, start + calc - 1);
            mockSanOrigin.TransferBound(user, start + calc, end);
        }
    }

    function _approveAllTokens(uint256[] memory tokenIds) internal {
        for (uint256 i = 0; i < tokenIds.length; i++) {
            emit log_address(IERC721(SAN_ORIGIN_ADDRESS).ownerOf(tokenIds[i]));
            emit log_uint(tokenIds[i]);
            IERC721(SAN_ORIGIN_ADDRESS).approve(SANCTUARY_ADDRESS, tokenIds[i]);
        }
    }

    function _addContracttoValidList(address _partnerAddress, uint8 _numTokensRequired, bool _isValid) internal {
        vm.stopPrank();
        vm.prank(OWNER);
        sanctuary.updatePartnerAddress(_partnerAddress, _numTokensRequired, _isValid);
    }

    function _getPrice(uint256 _new, uint256 _cur) internal returns (uint256) {
        return _levelPrices[_new] - _levelPrices[_cur];
    }

    function _checkSanctuaryTokenLevel(ITokenLevels.TokenLevel level, uint256 token) internal {
        ITokenLevels.TokenLevel currentLevel = sanctuary.currentTokenLevel(token);
        if (currentLevel != level) revert();
    }

    function _checkMusicBoxTokenLevel(IMusicBox.MusicBoxLevel level, uint256 token, address user) internal {
        // Check MusicBox Token is minted and Level.
        IMusicBox.MusicBoxLevel currentLevel = musicBox.tokenLevel(token);
        assertEq(musicBox.ownerOf(token), user);
        if (currentLevel != level) revert();
    }

    function _checkAfterMint(uint256[] memory tokenIds, ITokenLevels.TokenLevel level, address user) internal {
        // Check they are existing and are at the correct level requested.
        for (uint256 i = 0; i < tokenIds.length; i++) {
            uint256 token = tokenIds[i];
            assertTrue(sanctuary.usedTokens(SAN_ORIGIN_ADDRESS, token));
            assertEq(sanctuary.ownerOf(token), user);
            _checkSanctuaryTokenLevel(level, token);
        }
    }

    function _failTransfer() internal {
        sanctuary.transferFrom(msg.sender, address(0x1), 1);
        sanctuary.transferFrom(msg.sender, address(0x0), 1);
    }
}
