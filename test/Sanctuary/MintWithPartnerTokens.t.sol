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
        _mintWithPartner(mockERC721SingleAddress, partnerToken, notBoundSingleToken, user);
    }

    function testUpgradeTokenLevelPartners() public {
        _mintWithPartner(mockERC721SingleAddress, partnerToken, notBoundSingleToken, user);
        ITokenLevels.TokenLevel level = ITokenLevels.TokenLevel(2);
        uint256 _cur = 1;
        uint256 _new = 2;

        sanctuary.upgradeTokenLevel{value: _getPrice(_new, _cur)}(expectedSingle, level);
        _checkSanctuaryTokenLevel(level, expectedSingle);
    }

    function testFailMintIsBound() public {
        _mintWithPartner(mockERC721MultiAddress, partnerToken, isBoundSingleToken, user);
    }

    function testFailMintNotOwnedOrigin() public {
        _mintWithPartner(mockERC721MultiAddress, partnerToken, notBoundSingleToken, makeAddr("PartnerNoTokensOwned"));
    }

    function testFailTransferWhenSoulBound() public {
        testUpgradeTokenLevelPartners();
        _failTransfer();
    }
}
