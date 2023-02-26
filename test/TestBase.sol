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

    string startBaseURI = "https://base-uri.com/";
    string newBaseURI = "https://NEW-BASE-URI.com/";
    string startContractURI = "https://contract-uri.com/";
    string newContractURI = "https://NEW-CONTRACT-URI.com/";

    address mockERC721SingleAddress;
    address mockERC721MultiAddress;

    address SAN_ORIGIN_ADDRESS;
    address payable musicBoxAddress;

    address SANCTUARY_ADDRESS;

    address OWNER = makeAddr("Owner");
    address noTokensUser = makeAddr("NoTokensUser");

    uint256[6] _levelPrices;

    uint256[] notBoundTokens = [3330, 3331, 3332];
    uint256[] isBoundTokens = [21, 22, 23]; // middle will fail.

    uint256[] tooManyNotBoundTokens = [1, 2, 13, 14];
    uint256[] tooManyIsBoundTokens = [21, 22, 323, 34];

    uint256[] notBoundTokensSingle = [3300];
    uint256[] isBoundTokensSingle = [38];

    uint256[] isBoundTokensMismatched = [38, 39, 40];

    uint256[] noTokens;

    uint256[][] multipleNotBoundTokens = [
        [3330, 3331, 3332],
        [3130, 3231, 3032],
        [3300, 3311, 3322],
        [4330, 4331, 4332],
        [4130, 4231, 4032],
        [4300, 4311, 4322]
    ];

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
            string(startBaseURI),
            string(startContractURI),
           
            string("TestMusicBox"),
            string("TSSMB"),
            string(startBaseURI),
            string(startContractURI),
          
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
            uint256 split = 10000 / userLen;
            emit log_uint(split);
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

    function _checkSanctuaryTokenLevel(ITokenLevels.TokenLevel level, uint256 token) internal {
        ITokenLevels.TokenLevel currentLevel = sanctuary.tokenLevel(token);
        assertTrue(uint256(currentLevel) == uint256(level));
        assertTrue(currentLevel == level);
    }

    function _checkMusicBoxTokenLevel(IMusicBox.MusicBoxLevel level, uint256 token, address user) internal {
        // Check MusicBox Token is minted and Level.
        IMusicBox.MusicBoxLevel currentLevel = musicBox.tokenLevel(token);
        assertEq(musicBox.ownerOf(token), user);
        assertTrue(uint256(currentLevel) == uint256(level));
        assertTrue(currentLevel == level);
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
        vm.expectRevert();
        sanctuary.approve(msg.sender, 1);
        vm.expectRevert();
        sanctuary.setApprovalForAll(msg.sender, true);
        vm.expectRevert();
        sanctuary.transferFrom(msg.sender, address(0x1), 1);
        vm.expectRevert();
        sanctuary.safeTransferFrom(msg.sender, address(0x1), 1);
        vm.expectRevert();
        sanctuary.safeTransferFrom(msg.sender, address(0x1), 1, "");
    }

    function _upgradeTokenLevelSoulBound(uint256 token, uint256 _cur, uint256 _new) public {
        ITokenLevels.TokenLevel level = ITokenLevels.TokenLevel(_new);
        sanctuary.upgradeTokenLevel{value: _getPrice(_new, _cur)}(token, level);
        _checkSanctuaryTokenLevel(level, token);
    }
}
