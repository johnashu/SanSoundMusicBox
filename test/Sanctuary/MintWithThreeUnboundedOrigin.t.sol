// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.18;

import {
    MintWithThreeUnboundedOrigin,
    ITokenLevels,
    IMusicBox,
    MusicBox
} from "test/Sanctuary/_MintWithThreeUnboundedOrigin.t.sol";

contract TestMintWithThreeUnboundedOrigin is MintWithThreeUnboundedOrigin {
    address user;
    address[] users;

    function setUp() public {
        user = makeAddr("ThreeUnboundedUser");
        users.push(user);
        _setUp(users);
        vm.stopPrank();
        vm.startPrank(user);
    }

    function testMintWithMultiSanOrigin() public payable {
        _mintWithMultiSanOrigin(notBoundTokens, user);
    }

    function testUpgradeTokenLevelThreeUnbound() public {
        testMintWithMultiSanOrigin();
        _upgradeTokenLevelSoulBound(expectedMultiple[0], 1, 2);
    }

    function testFailMintIsBound() public {
        sanctuary.mintWith3UnboundSanOrigin{value: _getPrice(1, 0)}(isBoundTokens, ITokenLevels.TokenLevel.Rebirthed);
    }

    function testFailMintNotOwned() public {
        vm.stopPrank();
        vm.prank(address(1));
        sanctuary.mintWith3UnboundSanOrigin{value: _getPrice(1, 0)}(isBoundTokens, ITokenLevels.TokenLevel.Rebirthed);
    }

    function testUnableToApproveOrTransfersWhenSoulBound() public {
        testMintWithMultiSanOrigin();
        _failTransfer();
        _upgradeTokenLevelSoulBound(expectedMultiple[0], 1, 2);
        _failTransfer();
    }

    function testFailTooManyTokens() public {
        _mintWithMultiSanOrigin(tooManyNotBoundTokens, user);
    }

    function testFailTooFewTokens() public {
        _mintWithMultiSanOrigin(notBoundTokensSingle, user); // Only 1 token required with Partners.
    }

    function testFailNoTokens() public {
        _mintWithMultiSanOrigin(noTokens, user);
    }
}
