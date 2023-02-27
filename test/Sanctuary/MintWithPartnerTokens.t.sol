// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.18;

import {MintWithPartnerTokens, ITokenLevels, IMusicBox, MusicBox} from "test/Sanctuary/_MintWithPartnerTokens.t.sol";

contract TestMintWithPartnerTokens is MintWithPartnerTokens {
    address user;
    address[] users;

    function setUp() public {
        user = makeAddr("PartnerTokensUser");
        users.push(user);
        _setUp(users, true);
        vm.stopPrank();
        vm.startPrank(user);
    }

    function testMintWithPartnerSingle() public {
        _mintWithPartner(mockERC721SingleAddress, partnerToken, notBoundSingleToken, user);
    }

    function testUpgradeTokenLevelPartners() public {
        testMintWithPartnerSingle();
        _upgradeTokenLevelSoulBound(expectedSingle, 1, 2);
    }

    function testFailMintIsBound() public {
        _mintWithPartner(mockERC721SingleAddress, partnerToken, isBoundSingleToken, user);
    }

    function testFailMintNotOwnedOrigin() public {
        _mintWithPartner(mockERC721SingleAddress, partnerToken, notBoundSingleToken, makeAddr("PartnerNoTokensOwned"));
    }

    function testUnableToApproveOrTransfersWhenSoulBound() public {
        testMintWithPartnerSingle();
        _failTransfer();
        _upgradeTokenLevelSoulBound(expectedSingle, 1, 2);
        _failTransfer();
    }
}
