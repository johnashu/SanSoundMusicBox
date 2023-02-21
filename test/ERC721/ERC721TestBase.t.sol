// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.18;

import {TestBase, ITokenLevels, IERC721} from "test/TestBase.sol";
import {Base721} from "src/token/ERC721/Base721.sol";
import {MintWithBoundedOrigin} from "test/Sanctuary/_MintWithBoundedOrigin.t.sol";
import {MintWithThreeUnboundedOrigin} from "test/Sanctuary/_MintWithThreeUnboundedOrigin.t.sol";
import {MintWithPartnerTokens} from "test/Sanctuary/_MintWithPartnerTokens.t.sol";

abstract contract TestERC721Base is
    TestBase,
    MintWithBoundedOrigin,
    MintWithThreeUnboundedOrigin,
    MintWithPartnerTokens
{
    Base721 erc721Contract;
    address erc721ContractAddress;

    address public user;
    address[] public users;

    uint256[] public expected = [1];
    uint256[] public notExpected = [10009];

    function testFailSendNftToErc721ContractWithNoERC721Receiver() public {
        IERC721(mockERC721SingleAddress).approve(erc721ContractAddress, 1);
        IERC721(mockERC721SingleAddress).safeTransferFrom(user, erc721ContractAddress, 1);
    }

    function testSetRoyalties() public {
        vm.expectRevert();
        erc721Contract.setRoyalties(user, 900);
        vm.stopPrank();
        vm.prank(OWNER);
        erc721Contract.setRoyalties(user, 900);
    }

    function testWithdraw() public payable {
        uint256 deposit = 50 ether;
        uint256 withdraw = 10 ether;
        uint256 ownerBalance = OWNER.balance + withdraw;
        (bool sent,) = payable(erc721ContractAddress).call{value: deposit}("");
        require(sent, "Failed to send Ether");
        vm.expectRevert();
        erc721Contract.withdraw(withdraw);
        vm.stopPrank();
        vm.prank(OWNER);
        erc721Contract.withdraw(withdraw);
        assertEq(ownerBalance, OWNER.balance);
    }

    function testSafeWithdrawAll() public payable {
        uint256 deposit = 50 ether;
        uint256 ownerBalance = OWNER.balance + deposit;

        (bool sent,) = payable(erc721ContractAddress).call{value: deposit}("");
        require(sent, "Failed to send Ether");

        vm.expectRevert();
        erc721Contract.safeWithdrawAll();

        vm.stopPrank();
        vm.prank(OWNER);

        erc721Contract.safeWithdrawAll();
        assertEq(ownerBalance, OWNER.balance);
    }

    function testSetBaseURI() public {
        string memory _newURI = "Test String";
        vm.stopPrank();
        vm.prank(OWNER);
        erc721Contract.setBaseURI(_newURI);
        assertEq(erc721Contract.baseURI(), _newURI);
    }

    function testSetBaseURI() public {
        string memory _newURI = "Test String";
        vm.stopPrank();
        vm.prank(OWNER);
        erc721Contract.setBaseURI(_newURI);
        assertEq(erc721Contract.baseURI(), _newURI);
    }

    function _runAllScenarios() public {
        _mintWithMultiSanOrigin(notBoundTokens, user);
        _mintWithPartner(mockERC721SingleAddress, partnerToken, notBoundSingleToken, user);
        _mintWithSanSoundBound(isBoundSingleToken, user);
    }

    function testWalletOfOwner() public virtual {
        _mintWithSanSoundBound(isBoundSingleToken, user);
        uint256[] memory tokenIds = erc721Contract.walletOfOwner(user);
        assertEq(tokenIds, expected);
    }

    function testFailWalletOfOwner() public virtual {
        _mintWithSanSoundBound(isBoundSingleToken, user);
        uint256[] memory tokenIds = erc721Contract.walletOfOwner(address(0));
        assertEq(tokenIds, expected);
    }

    function testIsOwnerOf() public virtual {
        _mintWithSanSoundBound(isBoundSingleToken, user);
        assertTrue(erc721Contract.isOwnerOf(user, expected));
    }

    function testFailIsOwnerOf() public virtual {
        _mintWithSanSoundBound(isBoundSingleToken, user);
        assertTrue(erc721Contract.isOwnerOf(user, notExpected));
    }
}
