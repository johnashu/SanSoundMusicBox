// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.17;

// Once in a Soulbound state, the NFT acts as the holder’s token-gated login to the SAN Sound platform:

// Unbound will not receive access to the SAN Sound platform.
// Citizen will receive one year of access to the SAN Sound platform.
// Defiant will receive LIFETIME access to the SAN Sound platform.
// Hanzoku will receive LIFETIME access to the SAN Sound platform.
// “The 33” will receive LIFETIME access to the SAN Sound platform.

import "lib/openzeppelin-contracts/contracts/token/ERC1155/ERC1155.sol";
import "lib/openzeppelin-contracts/contracts/utils/Address.sol";
import "lib/openzeppelin-contracts/contracts/access/Ownable.sol";
import "src/interfaces/ISanOriginSoulbound.sol";

contract SanSoundPremiumNFT is Ownable, ERC1155("") {
    using Address for address;

    ISanOrigin public sanOriginSoulBound =
        ISanOrigin(address(0x33333333333371718A3C2bB63E5F3b94C9bC13bE));

    enum SoulboundState {
        Unbound,
        Citizen,
        Defiant,
        Hanzoku,
        The33
    }

    struct User {
        bool isBound;
        uint16[] SanOriginTokenIds;
        SoulboundState currentAccessLevel;
    }
    mapping(address => SoulboundState) public soulboundState;
    mapping(address => mapping(uint => bool)) public ownedTokens;

    constructor() {}

    function checkAccess(
        address _address
    ) public view returns (SoulboundState) {
        return soulboundState[_address];
    }

    function mint(address _address, uint _tokenId) public {
        require(
            ownedTokens[_address][_tokenId] == false,
            "This address already owns this token."
        );
        SoulboundState _state = getSoulBoundState(_address);
        ownedTokens[_address][_tokenId] = true;
        soulboundState[_address] = _state;
        _mint(_address, _tokenId, 1, "");
    }

    function getSoulBoundState(
        address _address
    ) public pure returns (SoulboundState) {
        uint stateFromSanOrigin = uint(1);

        unchecked {
            for (uint8 i = 0; i < 5; i++) {
                if (SoulboundState(stateFromSanOrigin) == SoulboundState(i)) {
                    return SoulboundState(i);
                }
            }
        }

        return SoulboundState(0);
    }

    function getUserMintedOrigin(
        address _address
    ) external view returns (uint) {
        uint stateFromSanOrigin = sanOriginSoulBound.userMinted(_address);
        return stateFromSanOrigin;
    }

    function getBalanceOfOrigin(address _address) external view returns (uint) {
        uint balance = sanOriginSoulBound.balanceOf(_address);
        return balance;
    }

    function getUserSoulbindCreditsOrigin(
        address _address
    ) external view returns (uint) {
        uint balance = sanOriginSoulBound.userSoulbindCredits(_address);
        return balance;
    }

    modifier isValid(address _address) {
        require(_address != address(0), "0x0 addr");
        _;
    }
}
