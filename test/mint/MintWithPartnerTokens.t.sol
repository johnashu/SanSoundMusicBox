// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.18;

import {TestBase, ITokenLevels, IMusicBox, MusicBox} from "test/TestBase.sol";

contract TestMintWithPartnerTokens is TestBase {
    function testMintWithPartnerSingle() public {
        _mintWithPartnerMultiple(1, partnerTokensToCheckSingle, mockERC721SingleAddress);
    }

    function testMintWithPartnerMultiple() public {
        _mintWithPartnerMultiple(3, partnerTokensToCheckMulti, mockERC721MultiAddress);
    }

    function _mintWithPartnerMultiple(uint256 n, uint256[] memory _toCheck, address _address) private {
        ITokenLevels.TokenLevel level = ITokenLevels.TokenLevel(1);
        uint256 _cur = 0;
        uint256 _new = 1;
        _addContracttoValidList(_address, 3, true);
        _approveAllTokens(notBoundTokensPartner);

        sanctuary.mintFromPartner{value: _getPrice(1, 0)}(
            notBoundTokensPartner, ITokenLevels.TokenLevel(1), _toCheck, _address
        );
        _checkAfterMint(notBoundTokensPartner, level);
        _checkMusicBoxTokenLevel(IMusicBox.MusicBoxLevel(0), 1);
    }

    function testUpgradeTokenLevelPartners() public {
        testMintWithPartnerMultiple();

        uint256 token = 1;
        ITokenLevels.TokenLevel level = ITokenLevels.TokenLevel(2);
        uint256 _cur = 1;
        uint256 _new = 2;

        sanctuary.upgradeTokenLevel{value: _getPrice(_new, _cur)}(token, level);
        _checkSanctuaryTokenLevel(level, token);
    }

    function testFailMintIsBound() public {
        sanctuary.mintFromPartner{value: _getPrice(1, 0)}(
            notBoundTokensPartner, ITokenLevels.TokenLevel(1), partnerTokensToCheckMulti, mockERC721MultiAddress
        );
    }

    function testFailMintNotOwnedOrigin() public {
        vm.stopPrank();
        vm.prank(address(1));
        sanctuary.mintFromPartner{value: _getPrice(1, 0)}(
            notBoundTokensPartner, ITokenLevels.TokenLevel(1), partnerTokensToCheckMulti, mockERC721MultiAddress
        );
    }

    function testFailTransferWhenSoulBound() public {
        testUpgradeTokenLevelPartners();
        sanctuary.transferFrom(msg.sender, address(0x1), 1);
    }
}
