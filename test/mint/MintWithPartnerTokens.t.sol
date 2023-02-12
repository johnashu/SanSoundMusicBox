// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.18;

import {TestBase, ITokenLevels, IMusicBox, MusicBox} from "test/TestBase.sol";

contract TestMintWithPartnerTokens is TestBase {
    address user;
    address[] users;

    function setUp() public {
        user = makeAddr("PartnerTokensUser");
        users.push(user);
        _setUp(users);
        vm.stopPrank();
        vm.startPrank(user);
    }

    function testMintWithPartnerSingle() public {
        _mintWithPartnerMultiple(1, mockERC721SingleAddress, partnerTokensToCheckSingle, notBoundTokensPartner, user);
    }

    function testMintWithPartnerMultiple() public {
        _mintWithPartnerMultiple(3, mockERC721MultiAddress, partnerTokensToCheckMulti, notBoundTokensPartner, user);
    }

    function _mintWithPartnerMultiple(
        uint8 numTokensRequired,
        address _address,
        uint256[] memory _toCheckPartner,
        uint256[] memory _toCheckOrigin,
        address user
    ) private {
        uint256 _cur = 0;
        uint256 _new = 1;
        ITokenLevels.TokenLevel level = ITokenLevels.TokenLevel(_new);
        _addContracttoValidList(_address, numTokensRequired, true);

        vm.startPrank(user);
        _approveAllTokens(_toCheckOrigin);

        sanctuary.mintFromPartner{value: _getPrice(_new, _cur)}(_toCheckOrigin, level, _toCheckPartner, _address);
        _checkAfterMint(_toCheckOrigin, level, user);
        _checkMusicBoxTokenLevel(IMusicBox.MusicBoxLevel.Common, 1, user);
    }

    function testUpgradeTokenLevelPartners() public {
        _mintWithPartnerMultiple(1, mockERC721SingleAddress, partnerTokensToCheckSingle, notBoundTokensPartner, user);

        uint256 token = partnerTokensToCheckSingle[0];
        ITokenLevels.TokenLevel level = ITokenLevels.TokenLevel(2);
        uint256 _cur = 1;
        uint256 _new = 2;

        sanctuary.upgradeTokenLevel{value: _getPrice(_new, _cur)}(token, level);
        _checkSanctuaryTokenLevel(level, token);
    }

    function testFailMintIsBound() public {
        _mintWithPartnerMultiple(3, mockERC721MultiAddress, partnerTokensToCheckMulti, isBoundTokensPartner, user);
    }

    function testFailMintNotOwnedOrigin() public {
        _mintWithPartnerMultiple(
            3,
            mockERC721MultiAddress,
            partnerTokensToCheckMulti,
            notBoundTokensPartner,
            makeAddr("PartnerNoTokensOwned")
        );
    }

    function testFailTransferWhenSoulBound() public {
        testUpgradeTokenLevelPartners();
        _failTransfer();
    }

    function testFailTooManyOriginTokens() public {
        _mintWithPartnerMultiple(3, mockERC721MultiAddress, partnerTokensToCheckMulti, notBoundTokens, user);
    }

    function testFailTooManyPartnerTokens() public {
        _mintWithPartnerMultiple(2, mockERC721MultiAddress, partnerTokensToCheckMulti, notBoundTokensPartner, user);
    }

    function testFailTooFewPartnerTokens() public {
        _mintWithPartnerMultiple(3, mockERC721MultiAddress, partnerTokensToCheckSingle, notBoundTokensPartner, user);
    }

    function testFailNoTokensPartner() public {
        _mintWithPartnerMultiple(3, mockERC721MultiAddress, noTokens, notBoundTokensPartner, user);
    }

    function testFailNoTokensOrigin() public {
        _mintWithPartnerMultiple(3, mockERC721MultiAddress, partnerTokensToCheckMulti, noTokens, user);
    }
}
