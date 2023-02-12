// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.18;

import {MintWithPartnerTokens, ITokenLevels, IMusicBox, MusicBox} from "test/Sanctuary/_MintWithPartnerTokens.t.sol";

contract TestMintWithPartnerTokens is MintWithPartnerTokens {
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
