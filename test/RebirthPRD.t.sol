// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.18;

import {TestBase} from "test/TestBase.sol";
import {MockSanOrigin} from "test/mocks/mockSanOrigin.sol";
import {MockERC721} from "test/mocks/mockERC721.sol";

contract TestRebirthMainNet is TestBase {
    uint256 constant FORK_BLOCK = 16507662;

    function setUp() public {
        vm.createSelectFork(vm.rpcUrl("mainnet"), FORK_BLOCK);
        user = 0x8D23fD671300c409372cFc9f209CDA59c612081a;
        initShared();
        sanOriginAddress = 0x33333333333371718A3C2bB63E5F3b94C9bC13bE;

        notBoundTokens = [452, 472, 6271];
        isBoundTokens = [452, 1055, 3829]; // middle will fail.

        notBoundTokensPartner = [452];
        isBoundTokensPartner = [1055];
        deployContracts();
    }
}
