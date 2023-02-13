[https://book.getfoundry.sh/forge/deploying](https://book.getfoundry.sh/forge/deploying)

```bash
forge create Sanctuary --constructor-args 0xbf8Bae200eBFF0B437AC57bEBcF474Bc0F7aE25B [0, 0, 3000, 4000, 5000, 6000]  --contracts src/Sanctuary.sol:Sanctuary --verify --private-key {TESTNET_PK} --rpc-url {GOERLI}

forge create MockSanOrigin --contracts test/Mocks/mockSanOrigin.t.sol:MockSanOrigin --verify --private-key  {TESTNET_PK} --rpc-url {GOERLI}

```

# Mock San Origin Goerli:

Deployer: 0x0d530DCbACB4E0F9B5d70B8dD5a1f01D2dc5E1f9
Deployed to: 0xbf8Bae200eBFF0B437AC57bEBcF474Bc0F7aE25B
Transaction hash: 0x787cc973b6f9f38ba3effbe0981fa248ea04cb70ec48d25727c6ba9f9eb70563