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
    uint128 constant MOCK_MAX_SUPPLY = 5;
    Sanctuary sanctuary;
    MusicBox musicBox;
    MockERC721 mockERC721Single;
    MockERC721 mockERC721Multi;
    MockSanOrigin mockSanOrigin;

    address mockERC721SingleAddress;
    address mockERC721MultiAddress;

    address SAN_ORIGIN_ADDRESS;
    address payable musicBoxAddress;

    address SANCTUARY_ADDRESS;

    address OWNER = makeAddr("Owner");

    uint256[6] _levelPrices;

    uint256[] notBoundTokens = [4, 5, 16];
    uint256[] isBoundTokens = [21, 22, 23]; // middle will fail.

    uint256[] tooManyNotBoundTokens = [1, 2, 13, 14];
    uint256[] tooManyIsBoundTokens = [21, 22, 323, 34];

    uint256[] notBoundTokensSingle = [13];
    uint256[] isBoundTokensSingle = [38];

    uint256[] isBoundTokensMismatched = [38, 39, 40];

    uint256[] noTokens;

    uint256[][] multipleNotBoundTokens = [[14, 15, 16], [7, 8, 9], [4, 5, 6], [1, 2, 3]];

    uint256 isBoundSingleToken = 21;
    uint256 notBoundSingleToken = 15;
    uint256 partnerToken = 28;

    uint256[] expectedMultiple = [1, 2, 3];
    uint256 expectedSingle = 1;

    function _setUp(address[] memory users) internal {
        _initOWNERs();
        _initUsers(users);
        _initShared();
        _deployContracts();
        _transferTokens(users);
    }

    function _initOWNERs() internal {
        vm.startPrank(OWNER); // OWNER becomes the owner of everything..
        vm.deal(OWNER, 100 ether);
    }

    function _initUsers(address[] memory users) internal {
        for (uint256 i; i < users.length; i++) {
            address user = users[i];
            vm.deal(user, 100 ether);
        }
    }

    function _initShared() internal {
        _levelPrices[0] = 0;
        _levelPrices[1] = 0;
        _levelPrices[2] = 333000000000000000;
        _levelPrices[3] = 633000000000000000;
        _levelPrices[3] = 963000000000000000;
        _levelPrices[5] = 5000000000000000000;
    }

    function _deployContracts() internal {
        mockSanOrigin = new MockSanOrigin();
        SAN_ORIGIN_ADDRESS = address(mockSanOrigin);

        mockERC721Single = new MockERC721();
        mockERC721SingleAddress = address(mockERC721Single);
        mockERC721Multi = new MockERC721();
        mockERC721MultiAddress = address(mockERC721Multi);
        sanctuary = new Sanctuary(
            string("TestSanctuary"),
            string("TSSS"),
            string("https://example.com/"),
           
            string("TestMusicBox"),
            string("TSSMB"),
            string("https://example.com/"),
          
              SAN_ORIGIN_ADDRESS,
            _levelPrices
        );

        SANCTUARY_ADDRESS = address(sanctuary);
        musicBoxAddress = payable(address(sanctuary.MUSIC_BOX_ADDRESS()));
        musicBox = MusicBox(musicBoxAddress);
    }

    function _transferTokens(address[] memory users) internal {
        uint256 userLen = users.length;
        uint256 split = 40 / userLen;
        for (uint256 i; i < userLen; ++i) {
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
        for (uint256 i; i < tokenIds.length; i++) {
            _approveToken(tokenIds[i]);
        }
    }

    function _approveToken(uint256 tokenId) internal {
        IERC721(SAN_ORIGIN_ADDRESS).approve(SANCTUARY_ADDRESS, tokenId);
    }

    function _addContracttoValidList(address _partnerAddress, bool _isValid) internal {
        vm.stopPrank();
        vm.prank(OWNER);
        sanctuary.updatePartnerAddress(_partnerAddress, _isValid);
    }

    function _getPrice(uint256 _new, uint256 _cur) internal view returns (uint256) {
        return _levelPrices[_new] - _levelPrices[_cur];
    }

    function _checkSanctuaryTokenLevel(ITokenLevels.TokenLevel level, uint256 token) internal view {
        ITokenLevels.TokenLevel currentLevel = sanctuary.tokenLevel(token);
        if (currentLevel != level) revert ITokenLevels.TokenLevelMismatch();
    }

    function _checkMusicBoxTokenLevel(IMusicBox.MusicBoxLevel level, uint256 token, address user) internal {
        // Check MusicBox Token is minted and Level.
        IMusicBox.MusicBoxLevel currentLevel = musicBox.tokenLevel(token);
        assertEq(musicBox.ownerOf(token), user);
        if (currentLevel != level) revert ITokenLevels.TokenLevelMismatch();
    }

    function _checkAfterMint(
        uint256[] memory originTokenIds,
        uint256[] memory sanctuaryTokenIds,
        ITokenLevels.TokenLevel level,
        address user
    ) internal {
        // Check they are existing and are at the correct level requested.
        for (uint256 i; i < originTokenIds.length; i++) {
            __checkAfterMint(originTokenIds[i], sanctuaryTokenIds[i], level, user);
        }
    }

    function __checkAfterMint(
        uint256 originTokenId,
        uint256 sanctuaryTokenId,
        ITokenLevels.TokenLevel level,
        address user
    ) internal {
        // Check they are existing and are at the correct level requested.
        assertTrue(sanctuary.usedTokens(SAN_ORIGIN_ADDRESS, originTokenId));
        assertEq(sanctuary.ownerOf(sanctuaryTokenId), user);
        _checkSanctuaryTokenLevel(level, sanctuaryTokenId);
    }

    function _failTransfer() internal {
        sanctuary.transferFrom(msg.sender, address(0x1), 1);
        sanctuary.transferFrom(msg.sender, address(0), 1);
    }
}
