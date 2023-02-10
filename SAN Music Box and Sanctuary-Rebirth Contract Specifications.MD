SAN Music Box and Sanctuary/Rebirth Contract Specifications

Summary
On March 10th, SAN will launch a SAN Music Box NFT minter. 

The SAN Music Box NFT will act as a governance token and an identifier for claiming the SAN Character NFT on March 21st.

There will be three ways to get a music box: 

1) Soulbind an existing SAN Origin NFT to receive a Legendary SAN Music Box NFT

2) Send three SAN Origin NFTs to the Sanctuary receive a Rare SAN Music Box NFT

3) Send a Scout SAN Origin NFT to the Sanctuary, which requires one SAN Origin NFT and an accompanying partner NFT (0N1 Force, Mutant Apes, WoW, Etc), for a common SAN Music Box NFT.

Three methods for Minting a Music Box 

1. Those with soulbound SAN Origin NFTs (SBSON) will do nothing but claim. The SAN Music Box NFT minter will read for SBSON and deliver 1 SAN Music Box NFT for every 1 SBSON.


2. Select three SAN Origin NFTs to ‘send to the Sanctuary’.The contract will burn the three SAN Origin NFTs and rebirth them in the sanctuary collection. NFTs that are rebirthed in the sanctuary contract cannot be removed from the owner wallet in any way; however, they can be soulbound to levels 1-4, as per the specifications in the SAN Origin NFT contact. Upon sending three SAN Origin NFTs to the sanctuary, an additional token is minted to the owners wallet: a SAN Music Box NFT.


3. Sending a Scout to the sanctuary is the same as the second method but one partner NFT counts as two SAN Origin NFTs and the one partner NFT is not burnt, whereas the one SAN Origin NFT is burnt and rebirthed in the sanctuary. Upon sending one SAN Origin NFT to the sanctuary, an additional token is minted to the owners wallet: a SAN Music Box NFT.


Music Box Functions
Freeze function that can be triggered by minting
Burning Options

We cannot burn the original ones in the contract that will decrease the supply of the contract.  The function does not exist.


We cannot manually send them to the 0x0 address as that is blocked in the contract in the transfer functions.  As is standard.

We can transfer to another 'burn' address..  something like 0x000000000000000000000000000000000000dEaD,  also will not decrease the supply in the contract but it is the official NFT burn address that OpenSea etc should (in theory) recognise.


It could be a 'locked' contract by San Sound. This is just a contract that receives and logs the supply with nothing else it can do. 
 Advantage here is that this address is owned by San Sound and we can restrict what goes in.. 
This creates a 'Clean' and 'Unique' burn address that is not polluted by a million failed APE NFT's etc :P
You can give a name to - "transfer to the demonic  void contract" or something.

We could simply use the current contract as they are already marked..
If we are doing 1:1 mint:burn, we can use the same Ids so Id1 SO == Id1 Rebirth
Has the same advantages as creating another contract.  
Would be the same address as the new NFT 


