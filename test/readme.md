# Run the tests:
forge test

# Open a test in the debugger:
forge test --debug testSomething

# Generate a gas report:
forge test --gas-report

# Only run tests in test/Contract.t.sol in the BigTest contract that start with testFail:
forge test --match-path test/mint/MintWithPartnerTokens.t.sol --match-contract TestMintWithPartnerTokens  --match-test "testMintWithPartnerSingle*" -vvvvv

# List tests in desired format
forge test --list
forge test --list --json
forge test --list --json --match-test "testFail*" | tail -n 1 | json_pp