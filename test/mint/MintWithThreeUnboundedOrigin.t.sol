// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.18;

import {TestBase, ITokenLevels, IMusicBox, MusicBox} from "test/TestBase.sol";

contract TestMintWithThreeUnBounded is TestBase {
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
        _mintWithMultiSanOrigin(notBoundTokens);
    }

    function _mintWithMultiSanOrigin(uint256[] memory tokens) public payable {
        uint256 _cur = 0;
        uint256 _new = 1;
        ITokenLevels.TokenLevel level = ITokenLevels.TokenLevel(_new);

        _approveAllTokens(tokens);
        // Mint the Tokens
        sanctuary.mintFromSanOrigin{value: _getPrice(_new, _cur)}(tokens, level);
        _checkAfterMint(tokens, level, user);
        _checkMusicBoxTokenLevel(IMusicBox.MusicBoxLevel.Rare, 1, user);
    }

    function testUpgradeTokenLevelThreeUnbound() public {
        testMintWithMultiSanOrigin();
        uint256 _cur = 1;
        uint256 _new = 2;
        uint256 token = 1;
        ITokenLevels.TokenLevel level = ITokenLevels.TokenLevel(_new);
        sanctuary.upgradeTokenLevel{value: _getPrice(_new, _cur)}(token, level);
        _checkSanctuaryTokenLevel(level, token);
    }

    function testFailMintIsBound() public {
        sanctuary.mintFromSanOrigin{value: _getPrice(1, 0)}(isBoundTokens, ITokenLevels.TokenLevel(1));
    }

    function testFailMintNotOwned() public {
        vm.stopPrank();
        vm.prank(address(1));
        sanctuary.mintFromSanOrigin{value: _getPrice(1, 0)}(isBoundTokens, ITokenLevels.TokenLevel(1));
    }

    function testFailTransferWhenSoulBound() public {
        testUpgradeTokenLevelThreeUnbound();
        _failTransfer();
    }

    function testFailTooManyTokens() public {
        _mintWithMultiSanOrigin(tooManyNotBoundTokens);
    }

    function testFailTooFewTokens() public {
        _mintWithMultiSanOrigin(notBoundTokensPartner); // Only 1 token required with Partners.
    }

    function testFailNoTokens() public {
        _mintWithMultiSanOrigin(noTokens);
    }
}
