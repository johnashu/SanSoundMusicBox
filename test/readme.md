# Run the tests:
forge test

# Open a test in the debugger:
forge test --debug testSomething

# Generate a gas report:
forge test --gas-report

# Only run tests in test/Contract.t.sol in the BigTest contract that start with testFail:

forge test --match-path test/Sanctuary/MintWithPartnerTokens.t.sol --match-contract TestMintWithPartnerTokens  --match-test "testFailMintNotOwnedOrigin*" -vvvvv

forge test --match-path test/Sanctuary/MintWithThreeUnboundedOrigin.t.sol --match-contract TestMintWithThreeUnBounded  --match-test "testSendNFTToSanctuaryAddress*" -vvvvv

forge test --match-path test/Sanctuary/MintWithBoundedOrigin.t.sol --match-contract TestMintWithSoulBound  --match-test "testUpgradeTokenLevelSoulBound*" -vvvvv

forge test --match-path test/Common.t.sol --match-contract TestCommon --match-test "testSendNFTToSanctuaryAddress*" -vvvvv

forge test --match-path test/ERC721/ERC721.t.sol --match-contract TestERC721  --match-test "testWalletOfOwner*" -vvvvv


# List tests in desired format
forge test --list
forge test --list --json
forge test --list --json --match-test "testFail*" | tail -n 1 | json_pp


```solidity
// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.18;

import {TestBase} from "test/TestBase.sol";
import {MockSanOrigin} from "test/mocks/mockSanOrigin.sol";
import {MockERC721} from "test/mocks/mockERC721.sol";

contract TestMainNet is TestBase {
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

```