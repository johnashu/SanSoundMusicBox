// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.18;

import {Test} from "lib/forge-std/src/Test.sol";
import {Rebirth} from "src/Rebirth.sol";
import {IRebirth} from "src/interfaces/Rebirth/IRebirth.sol";
import {MockERC721} from "test/mockERC721.sol";
import {MockSanOrigin} from "test/mockSanOrigin.sol";
import {IERC721} from "src/interfaces/ERC721/IERC721.sol";

contract TestRebirth is Test {
    uint256 constant FORK_BLOCK = 16507662;

    Rebirth rebirth;
    MockSanOrigin mockSanOrigin;
    MockERC721 mockERC721Single;
    MockERC721 mockERC721Multi;

    address sanOriginAddress;

    address user = makeAddr("Maffaz");

    uint256[] notBoundTokens = [1, 2, 3];
    uint256[] isBoundTokens = [4, 10, 11]; // middle will fail.

    uint256[] notBoundTokensPartner = [5];
    uint256[] isBoundTokensPartner = [12];

    uint256[6] _levelPrices;

    uint256[] partnerTokensToCheckSingle = [1];
    uint256[] partnerTokensToCheckMulti = [2, 3, 4];
    address partnerTokenAddress;

    function setUp() public {
        // vm.createSelectFork(vm.rpcUrl("mainnet"), FORK_BLOCK);
        vm.startPrank(user); // User becomes the owner of everything..
        vm.deal(user, 10 ether);
        _levelPrices[0] = 0;
        _levelPrices[1] = 333000000000000000;
        _levelPrices[2] = 633000000000000000;
        _levelPrices[3] = 963000000000000000;
        _levelPrices[4] = 5000000000000000000;
        _levelPrices[5] = 10000000000000000000;

        mockERC721Single = new MockERC721();
        mockERC721Multi = new MockERC721();
        mockSanOrigin = new MockSanOrigin();
        sanOriginAddress = address(mockSanOrigin);

        rebirth = new Rebirth(
            string("SanSoundRebirth"),
            string("SMB"),
            string("https://example.com/"),
            string(""),
            sanOriginAddress,
            _levelPrices
        );
    }

    function testCheckOriginAddressIsValid() public {
        address san = rebirth.sanOriginAddress();
        assertTrue(rebirth.isValidContract(san));
    }

    function testAddContractToValidListFuzzy(address _partnerAddress, uint8 _numTokensRequired, bool _isValid) public {
        vm.assume(_partnerAddress != address(0));
        vm.assume(_numTokensRequired != 0);
        _addContracttoValidList(_partnerAddress, _numTokensRequired, _isValid);
    }

    function _addContracttoValidList(address _partnerAddress, uint8 _numTokensRequired, bool _isValid) private {
        rebirth.updatePartnerAddress(_partnerAddress, _numTokensRequired, _isValid);
    }

    function testMintWithMultiSanOrigin() public payable {
        emit log_uint(user.balance);
        uint256 price = _levelPrices[1] - _levelPrices[0];
        bool success = rebirth.mintFromSanOrigin{value: price}(notBoundTokens, IRebirth.AccessLevel(1));

        assertTrue(success);
        emit log_uint(user.balance);

        // try again, this time with revert
        vm.expectRevert();
        rebirth.mintFromSanOrigin{value: price}(notBoundTokens, IRebirth.AccessLevel(1));
    }

    function testFailMintWithMultiSanOriginPrice(uint256 x) public payable {
        emit log_uint(user.balance);
        uint256 price = _levelPrices[1] - _levelPrices[0];
        bool success = rebirth.mintFromSanOrigin{value: x}(notBoundTokens, IRebirth.AccessLevel(1));
    }

    function testMintWithPartnerSingle(uint256 x) public {
        emit log_uint(user.balance);
        uint256 price = _levelPrices[1] - _levelPrices[0];

        _addContracttoValidList(address(mockERC721Single), 1, true);
        bool success = rebirth.mintFromPartner{value: price}(
            notBoundTokensPartner, IRebirth.AccessLevel(1), partnerTokensToCheckSingle, address(mockERC721Single)
        );
        assertTrue(success);
        emit log_uint(user.balance);

        // try again, this time with revert
        vm.expectRevert();
        rebirth.mintFromPartner{value: price}(
            notBoundTokensPartner, IRebirth.AccessLevel(1), partnerTokensToCheckSingle, address(mockERC721Single)
        );
    }

    function testMintWithPartnerMultiple() public {
        emit log_uint(user.balance);
        uint256 price = _levelPrices[1] - _levelPrices[0];

        _addContracttoValidList(address(mockERC721Multi), 3, true);
        bool success = rebirth.mintFromPartner{value: price}(
            notBoundTokensPartner, IRebirth.AccessLevel(1), partnerTokensToCheckMulti, address(mockERC721Multi)
        );
        assertTrue(success);
        emit log_uint(user.balance);

        // try again, this time with revert
        vm.expectRevert();
        rebirth.mintFromPartner{value: price}(
            notBoundTokensPartner, IRebirth.AccessLevel(1), partnerTokensToCheckMulti, address(mockERC721Multi)
        );
    }

    function testUpgradeAccessLevel() public {
        testMintWithMultiSanOrigin();
        uint256 price = _levelPrices[2] - _levelPrices[1];
        bool success = rebirth.upgradeAccessLevel{value: price}(1, IRebirth.AccessLevel(2));

        assertTrue(success);
    }

    function testFailMintIsBound() public {
        assertTrue(rebirth.mintFromSanOrigin(isBoundTokens, IRebirth.AccessLevel(0)));
    }

    function testFailMintNotOwned() public {
        vm.stopPrank(); // User becomes the owner of everything..
        vm.prank(address(1));
        assertTrue(rebirth.mintFromSanOrigin(isBoundTokens, IRebirth.AccessLevel(0)));
    }
}
