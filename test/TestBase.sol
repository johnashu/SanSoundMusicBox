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

    address sanOriginAddress;
    address musicBoxAddress;

    address sanctuaryAddress;

    address user;

    uint256[6] _levelPrices;

    uint256[] partnerTokensToCheckSingle = [1];
    uint256[] partnerTokensToCheckMulti = [2, 3, 4];
    address partnerTokenAddress;

    uint256[] notBoundTokens;
    uint256[] isBoundTokens; // middle will fail.

    uint256[] notBoundTokensSingle;
    uint256[] isBoundTokensSingle;

    uint256[] notBoundTokensPartner;
    uint256[] isBoundTokensPartner;

    function setUp() public virtual {
        initUsers();
        initShared();
        deployContracts();
    }

    function initUsers() public {
        user = makeAddr("Maffaz");
        vm.startPrank(user); // User becomes the owner of everything..
        vm.deal(user, 10 ether);
    }

    function initShared() public {
        _levelPrices[0] = 0;
        _levelPrices[1] = 0;
        _levelPrices[2] = 333000000000000000;
        _levelPrices[3] = 633000000000000000;
        _levelPrices[3] = 963000000000000000;
        _levelPrices[5] = 5000000000000000000;
        notBoundTokens = [1, 2, 3];
        isBoundTokens = [11, 12, 13]; // middle will fail.

        notBoundTokensPartner = [1];
        isBoundTokensPartner = [12];

        notBoundTokensSingle = [1];
        isBoundTokensSingle = [15];
    }

    function deployContracts() public {
        mockSanOrigin = new MockSanOrigin();
        sanOriginAddress = address(mockSanOrigin);

        mockERC721Single = new MockERC721();
        mockERC721SingleAddress = address(mockERC721Single);
        mockERC721Multi = new MockERC721();
        mockERC721MultiAddress = address(mockERC721Multi);
        sanctuary = new Sanctuary(
            string("SanSoundSanctuary"),
            string("SRB"),
            string("https://example.com/"),
            string(""),
            sanOriginAddress,
            _levelPrices
        );

        sanctuaryAddress = address(sanctuary);
        musicBoxAddress = address(sanctuary.MUSIC_BOX_ADDRESS());
        musicBox = MusicBox(musicBoxAddress);
    }

    function _approveAllTokens(uint256[] memory tokenIds) internal {
        for (uint256 i = 0; i < tokenIds.length; i++) {
            IERC721(sanOriginAddress).approve(sanctuaryAddress, tokenIds[i]);
        }
    }

    function _addContracttoValidList(address _partnerAddress, uint8 _numTokensRequired, bool _isValid) internal {
        sanctuary.updatePartnerAddress(_partnerAddress, _numTokensRequired, _isValid);
    }

    function _getPrice(uint256 _new, uint256 _cur) internal returns (uint256) {
        return _levelPrices[_new] - _levelPrices[_cur];
    }

    function _checkSanctuaryTokenLevel(ITokenLevels.TokenLevel level, uint256 token) internal {
        ITokenLevels.TokenLevel currentLevel = sanctuary.currentTokenLevel(token);
        if (currentLevel != level) revert();
    }

    function _checkMusicBoxTokenLevel(IMusicBox.MusicBoxLevel level, uint256 token) internal {
        // Check MusicBox Token is minted and Level.
        IMusicBox.MusicBoxLevel currentLevel = musicBox.tokenLevel(token);
        assertEq(musicBox.ownerOf(token), user);
        if (currentLevel != level) revert();
    }

    function _checkAfterMint(uint256[] memory tokenIds, ITokenLevels.TokenLevel level) internal {
        // Check they are existing and are at the correct level requested.
        for (uint256 i = 0; i < tokenIds.length; i++) {
            uint256 token = tokenIds[i];
            assertTrue(sanctuary.usedTokens(sanOriginAddress, token));
            assertEq(sanctuary.ownerOf(token), user);
            _checkSanctuaryTokenLevel(level, token);
        }
    }
}
