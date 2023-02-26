// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.18;

import {TestBase, ITokenLevels, IERC721} from "test/TestBase.sol";
import {Strings, Base721} from "src/token/ERC721/Base721.sol";
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

    function _runAllScenarios() public {
        _mintWithMultiSanOrigin(notBoundTokens, user);
        _mintWithPartner(mockERC721SingleAddress, partnerToken, notBoundSingleToken, user);
        _mintWithSanSoundBound(isBoundSingleToken, user);
    }

    function testFailSendNftToErc721ContractWithNoERC721Receiver() public {
        IERC721(mockERC721SingleAddress).approve(erc721ContractAddress, 1);
        IERC721(mockERC721SingleAddress).safeTransferFrom(user, erc721ContractAddress, 1);
    }

    function testSetBaseURI() public {
        assertEq(erc721Contract.baseURI(), startBaseURI);

        vm.stopPrank();
        vm.prank(OWNER);
        erc721Contract.setBaseURI(newBaseURI);
        assertEq(erc721Contract.baseURI(), newBaseURI);
    }

    function testSetContractURI() public {
        assertEq(erc721Contract.contractURI(), startContractURI);

        vm.stopPrank();
        vm.prank(OWNER);
        erc721Contract.setContractURI(newContractURI);
        assertEq(erc721Contract.contractURI(), newContractURI);
    }

    function testTokenOfOwnerByIndex() public {
        _mintWithMultiSanOrigin(notBoundTokens, user);
        uint256 tokenId = erc721Contract.tokenOfOwnerByIndex(user, 0);
        uint256 expected = 1;
        // emit log_uint(musicBo)
        assertEq(tokenId, expected);
    }

    function testFailTokenOfOwnerByIndex_IndexGreaterThanBalance() public {
        _mintWithMultiSanOrigin(notBoundTokens, user);
        erc721Contract.tokenOfOwnerByIndex(user, 100);
    }

    function testFailTokenOfOwnerByIndex_OwnerIndexOutOfBounds() public {
        _mintWithMultiSanOrigin(notBoundTokens, user);
        erc721Contract.tokenOfOwnerByIndex(noTokensUser, 100);
    }

    function testIsOwnerOf() public virtual {
        _mintWithSanSoundBound(isBoundSingleToken, user);
        assertTrue(erc721Contract.isOwnerOf(user, expected));
    }

    function testFailIsOwnerOf() public virtual {
        _mintWithSanSoundBound(isBoundSingleToken, user);
        assertTrue(erc721Contract.isOwnerOf(user, notExpected));
    }

    function testFailIsOwnerOf_AmountExceedsSupply() public virtual {
        _mintWithSanSoundBound(isBoundSingleToken, user);
        assertTrue(erc721Contract.isOwnerOf(user, tooManyIsBoundTokens));
    }

    function testWalletOfOwner() public virtual {
        _mintWithSanSoundBound(isBoundSingleToken, user);
        uint256[] memory tokenIds = erc721Contract.walletOfOwner(user);
        assertEq(tokenIds, expected);
    }

    function testWalletOfOwnerZeroOwned() public virtual {
        _mintWithSanSoundBound(isBoundSingleToken, user);
        uint256[] memory tokenIds = erc721Contract.walletOfOwner(noTokensUser);
        assertEq(tokenIds, noTokens);
    }

    function testFailWalletOfOwner() public virtual {
        _mintWithSanSoundBound(isBoundSingleToken, user);
        uint256[] memory tokenIds = erc721Contract.walletOfOwner(address(0));
        assertEq(tokenIds, expected);
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

    function _getBaseURI(uint256 tokenId, uint256 tokenIdStr, uint256 tokenLevel) internal {
        string memory _expectedURI = string(
            abi.encodePacked(startBaseURI, Strings.toString(tokenLevel), "/", Strings.toString(tokenIdStr), ".json")
        );

        string memory _receivedUri = erc721Contract.tokenURI(tokenId);

        emit log_string(_expectedURI);
        emit log_string(_receivedUri);
        assertEq(_receivedUri, _expectedURI);
    }
}
