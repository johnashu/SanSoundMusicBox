// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.17;

// Once in a Soulbound state, the NFT acts as the holder’s token-gated login to the SAN Sound platform:

// Unbound will not receive access to the SAN Sound platform.
// Citizen will receive one year of access to the SAN Sound platform.
// Defiant will receive LIFETIME access to the SAN Sound platform.
// Hanzoku will receive LIFETIME access to the SAN Sound platform.
// “The 33” will receive LIFETIME access to the SAN Sound platform.

import "@openzeppelin/contracts/token/ERC1155.sol";
import "@openzeppelin/contracts/utils/Address.sol";

contract SanSoundPremiumNFT is ERC1155 {
    using Address for address;

    address public sanSoundSoulBoundAddress;
    SanSoundSoulBound public sanSoundSoulBound;

    enum SoulboundState {
        Unbound,
        Citizen,
        Defiant,
        Hanzoku,
        The33
    }

    mapping(address => SoulboundState) public soulboundState;
    mapping(address => mapping(uint => bool)) public ownedTokens;

    constructor(address _sanSoundSoulBoundAddress) public {
        sanSoundSoulBoundAddress = _sanSoundSoulBoundAddress;
        sanSoundSoulBound = SanSoundSoulBound(_sanSoundSoulBoundAddress);
    }

    function grantAccess(address _address, SoulboundState _state) public {
        require(_address.isValid(), "Invalid address provided.");
        require(
            hasValidNFTs(_address),
            "Address does not have the required NFTs to mint this token."
        );
        soulboundState[_address] = _state;
    }

    function checkAccess(
        address _address
    ) public view returns (SoulboundState) {
        return soulboundState[_address];
    }

    function mint(
        address _address,
        uint _tokenId,
        SoulboundState _state
    ) public {
        require(_address.isValid(), "Invalid address provided.");
        require(
            hasValidNFTs(_address),
            "Address does not have the required NFTs to mint this token."
        );
        require(
            ownedTokens[_address][_tokenId] == false,
            "This address already owns this token."
        );
        ownedTokens[_address][_tokenId] = true;
        soulboundState[_address] = _state;
        _mint(_address, _tokenId);
    }

    function hasValidNFTs(address _address) private view returns (bool) {
        uint count = 0;
        for (uint i = 1; i <= 3; i++) {
            if (sanSoundSoulBound.balanceOf(_address, i) > 0) {
                count++;
            }
        }
        return count >= 3;
    }
}
