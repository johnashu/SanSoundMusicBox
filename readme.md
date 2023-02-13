  SanOrigin Contract Eth

  0x33333333333371718A3C2bB63E5F3b94C9bC13bE
  
// Once in a Soulbound state, the NFT acts as the holder’s token-gated login to the SAN Sound platform:

// Merged will not receive access to the SAN Sound platform.
// Citizen will receive one year of access to the SAN Sound platform. .33 ETH
// Defiant will receive LIFETIME access to the SAN Sound platform.    xxETH
// Hanzoku will receive LIFETIME access to the SAN Sound platform.  xxETH
// “The 33” will receive LIFETIME access to the SAN Sound platform. xxETH

// Fees can be changed

// Only Merged NFT's from orign are allowed - level 0 only
// 1. Soulbind 3 nfts that are at level 0 in the origin to create a new NFT MB (MusicBox) Token
// Soulbinding does not give access - state 0 = Merged.  3 NFT's
// 2. Can transfer when Merged but not after that level.
// 3. any level can be paid for can upgrade but cannot downgrade.abi

  
   // The maximum token supply.
    // 9,748 Unbound SanOrigin Tokens
    // divided by 3 = 3249(San Origin) + 84 (Partners)
    // MAX_SUPPLY = 3333 

NEW*********
// rebirth collection - clone of first but with the soulbound - unbound becomes bound - burn San origin, mint new rebirth.  

// basically musicbox will mint 3 x rebirth and 1c mb nft

// 0 state in new contract = SoulBound. 1-4 levels.

// MusicBox standalone - act of merging, takes 3 rebirth to mint musicbox nft, fully tradable.. standard NFT ,nothing special.
// Rebirth will own MusicBox and mint on demand.



// Partner NfTs


Takes approx 20 mins first time (use a block otherwise it will sync each time!)

forge test -f https://eth-mainnet.g.alchemy.com/v2/<API KEY> --chain-id 1 -vvvvv --fork-block-number 16507661

Test User PRD:

0x8D23fD671300c409372cFc9f209CDA59c612081a

Minted NFTs = 3

isBound = [789, 1055, 3829, 8313, 9166]

notBound = [452, 472, 1173, 1388, 1682, 1720, 1851, 2027, 2263, 2275, 2755, 3248, 3277, 3689, 3721, 3811, 4268, 4964, 4965, 4966, 5082, 5474, 5557, 5622, 5826, 5844, 5845, 5976, 6035, 6168, 6206, 6208, 6237, 6244, 6271, 6272, 6277, 6289, 6323, 6391, 6412, 6422, 6455, 6456, 7168, 7178, 8400, 8509]

forge create Sanctuary --constructor-args 0xbf8Bae200eBFF0B437AC57bEBcF474Bc0F7aE25B [0, 0, 3000, 4000, 5000, 6000]  --contracts src/Sanctuary.sol:Sanctuary --verify --private-key {TESTNET_PK} --rpc-url {GOERLI}

forge create MockSanOrigin --contracts test/Mocks/mockSanOrigin.t.sol:MockSanOrigin --verify --private-key  {TESTNET_PK} --rpc-url {GOERLI}

Mock San Origin Goerli:
Deployer: 0x0d530DCbACB4E0F9B5d70B8dD5a1f01D2dc5E1f9
Deployed to: 0xbf8Bae200eBFF0B437AC57bEBcF474Bc0F7aE25B
Transaction hash: 0x787cc973b6f9f38ba3effbe0981fa248ea04cb70ec48d25727c6ba9f9eb70563
