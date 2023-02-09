// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.18;

import {TestBase} from "test/TestBase.sol";
import {MockSanOrigin} from "test/mocks/mockSanOrigin.sol";
import {MockERC721} from "test/mocks/mockERC721.sol";

contract TestRebirthTestNet is TestBase {
    MockSanOrigin mockSanOrigin;

    function setUp() public {
        user = makeAddr("Maffaz");
        initShared();
        mockSanOrigin = new MockSanOrigin();
        sanOriginAddress = address(mockSanOrigin);
        notBoundTokens = [1, 2, 3];
        isBoundTokens = [4, 10, 11]; // middle will fail.

        notBoundTokensPartner = [5];
        isBoundTokensPartner = [12];
        deployContracts();
    }
}
