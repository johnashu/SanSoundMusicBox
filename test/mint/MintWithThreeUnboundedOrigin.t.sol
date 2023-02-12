// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.18;

import {TestBase, ITokenLevels, IMusicBox, MusicBox} from "test/TestBase.sol";

contract TestMintWithThreeUnBounded is TestBase {
    function testMintWithMultiSanOrigin() public payable {
        ITokenLevels.TokenLevel level = ITokenLevels.TokenLevel(1);
        uint256 _cur = 0;
        uint256 _new = 1;

        _approveAllTokens(notBoundTokens);
        // Mint the Tokens
        sanctuary.mintFromSanOrigin{value: _getPrice(_new, _cur)}(notBoundTokens, level);
        _checkAfterMint(notBoundTokens, level);
        _checkMusicBoxTokenLevel(IMusicBox.MusicBoxLevel(1), 1);
    }

    function testUpgradeTokenLevelThreeUnbound() public {
        testMintWithMultiSanOrigin();

        uint256 token = 1;
        ITokenLevels.TokenLevel level = ITokenLevels.TokenLevel(2);
        uint256 _cur = 1;
        uint256 _new = 2;

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
        sanctuary.transferFrom(msg.sender, address(0x1), 1);
    }
}
