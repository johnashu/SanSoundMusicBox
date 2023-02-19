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
        _mintWithMultiSanOrigin(notBoundTokens, user);
        uint256 _cur = 1;
        uint256 _new = 2;
        uint256 token = notBoundTokens[0];
        ITokenLevels.TokenLevel level = ITokenLevels.TokenLevel(_new);
        sanctuary.upgradeTokenLevel{value: _getPrice(_new, _cur)}(token, level);
        _checkSanctuaryTokenLevel(level, token);
    }

    function testFailMintIsBound() public {
        sanctuary.mintWith3UnboundSanOrigin{value: _getPrice(1, 0)}(isBoundTokens, ITokenLevels.TokenLevel(1));
    }

    function testFailMintNotOwned() public {
        vm.stopPrank();
        vm.prank(address(1));
        sanctuary.mintWith3UnboundSanOrigin{value: _getPrice(1, 0)}(isBoundTokens, ITokenLevels.TokenLevel(1));
    }

    function testFailTransferWhenSoulBound() public {
        testUpgradeTokenLevelThreeUnbound();
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
