[https://book.getfoundry.sh/forge/tests](https://book.getfoundry.sh/forge/tests)

# Run the tests:

forge test

# Open a test in the debugger:

forge test --debug testSomething

# Generate a gas report:

forge test --gas-report

# Run tests..

```bash

forge test --match-path test/Sanctuary/MaxMintWithThreeUnboundedOrigin.t.sol --match-contract TestMaxMintWithThreeUnboundedOrigin  --match-test "testMAXMintWithMultiSanOrigin*" -vvvvv

forge test --match-path test/Sanctuary/MaxMintWithBoundedOrigin.t.sol --match-contract TestMaxMintWithBoundedOrigin  --match-test "testMAXMintWithBoundedOrigin*" -vvvvv

forge test --match-path test/Sanctuary/MaxMintWithPartnerTokens.t.sol --match-contract TestMaxMintWithPartnerTokens  --match-test "testMAXMintWithPartnerTokens*" -vvvvv

forge test --match-path test/Sanctuary/MintWithPartnerTokens.t.sol --match-contract TestMintWithPartnerTokens  --match-test "testUpgradeTokenLevelPartners*" -vvvvv

forge test --match-path test/Sanctuary/MintWithThreeUnboundedOrigin.t.sol --match-contract TestMintWithThreeUnboundedOrigin  --match-test "testMintWithMultiSanOrigin*" -vvvvv

forge test --match-path test/Sanctuary/MintWithBoundedOrigin.t.sol --match-contract TestMintWithBoundedOrigin  --match-test "testFailTransferWhenSoulBound*" -vvvvv

forge test --match-path test/MusicBox/MusicBox.t.sol --match-contract TestMusicBox  --match-test "testTransferFrom" -vvvvv


forge test --match-path test/ERC721/ERC721TestBase.t.sol --match-contract TestERC721Base  --match-test "*" -vvvvv

forge test --match-path test/Levels/TokenLevels.t.sol --match-contract TestLevels  --match-test "testFailUpgradeTokenLevelAlreadyReached*" -vvvvv

forge test --match-path test/ERC721/ERC721MusicBox.t.sol --match-contract TestERC721MusicBox  --match-test "testFailSendNftToErc721ContractWithNoERC721Receiver*" -vvvvv

forge test --match-path test/ERC721/ERC721Sanctuary.t.sol --match-contract TestERC721Sanctuary  --match-test "testFailIsOwnerOf_AmountExceedsSupply*" -vvvvv

forge test --match-path test/benches/Z-arrayCounter.t.sol --match-contract TestArrayCounter  --match-test "testAddOwnerByTokenArraySingle*" -vvvvv

```

# List tests in desired format:

forge test --list
forge test --list --json
forge test --list --json --match-test "testFail*" | tail -n 1 | json_pp

# Forking 

 > Takes approx 20 mins first time (specifiy a block number otherwise it will sync each time!)

`forge test -f https:*eth-mainnet.g.alchemy.com/v2/<API KEY> --chain-id 1 -vvvvv --fork-block-number 16507661`

# Test User PRD:

> 0x8D23fD671300c409372cFc9f209CDA59c612081a

* Minted NFTs = 3

* isBound = [789, 1055, 3829, 8313, 9166]

* notBound = [452, 472, 1173, 1388, 1682, 1720, 1851, 2027, 2263, 2275, 2755, 3248, 3277, 3689, 3721, 3811, 4268, 4964, 4965, 4966, 5082, 5474, 5557, 5622, 5826, 5844, 5845, 5976, 6035, 6168, 6206, 6208, 6237, 6244, 6271, 6272, 6277, 6289, 6323, 6391, 6412, 6422, 6455, 6456, 7168, 7178, 8400, 8509]


```javascript
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

    }
}

```