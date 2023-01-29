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

    enum AccessLevel {
        Unbound,
        Citizen,
        Defiant,
        Hanzoku,
        The33
    }

    uint8 TOKENS_REQUIRED_TO_MINT = 3;
    uint16 currentTokenId;

    struct User {
        bool isBound;
        uint16[] SanOriginTokenIds;
        AccessLevel currentAccessLevel;
    }
    mapping(address => AccessLevel) public accessLevel;
    mapping(address => mapping(uint => bool)) public ownedTokens;

    constructor() {}

    function checkUserOwnsTokens(
        uint16[] memory tokenIds,
        address _address
    ) public view notZeroAddress(_address) returns (bool) {
        require(
            tokenIds.length == TOKENS_REQUIRED_TO_MINT,
            "SP: Must be 3 NFTs"
        );
        for (uint8 i = 0; i < TOKENS_REQUIRED_TO_MINT; i++) {
            require(
                ownedTokens[_address][tokenIds[i]] == false,
                "SP: Token already used"
            );
            require(
                sanOriginSoulBound.ownerOf(tokenIds[i]) == _address,
                "SP: !Owner"
            );
        }
        return true;
    }

    function checkOriginTokensBind(
        uint16[] memory tokenIds
    ) public view returns (bool) {
        require(
            tokenIds.length == TOKENS_REQUIRED_TO_MINT,
            "SP: Must be 3 NFTs"
        );
        for (uint8 i = 0; i < TOKENS_REQUIRED_TO_MINT; i++) {
            uint tokenLevel = sanOriginSoulBound.tokenLevel(tokenIds[i]);
            require(tokenLevel != 0, "SP: !Bound");
        }
        return true;
    }

    function checkAccessLevel(
        address _address
    ) public view returns (AccessLevel) {
        return accessLevel[_address];
    }

    function getTokenId() public view returns (uint) {
        return currentTokenId;
    }

    function mint(
        address _address,
        uint16[] memory tokenIds
    ) public notZeroAddress(_address) returns (bool) {
        checkUserOwnsTokens(tokenIds, _address);
        checkOriginTokensBind(tokenIds);
        require(
            checkAccessLevel(_address) == AccessLevel.Unbound,
            "SP: Address has access"
        );

        // Pass checks, map the id.
        for (uint i = 0; i < tokenIds.length; i++) {
            ownedTokens[_address][tokenIds[i]] = true;
        }

        accessLevel[_address] = AccessLevel.Citizen;

        _mint(_address, getTokenId(), 1, ""); // Check security..
        return true;
    }

    // function getAccessLevel(
    //     address _address
    // ) public pure returns (AccessLevel) {
    //     uint stateFromSanOrigin = uint(4);

    //     unchecked {
    //         for (uint8 i = 0; i < 5; i++) {
    //             if (AccessLevel(stateFromSanOrigin) == AccessLevel(i)) {
    //                 return AccessLevel(i);
    //             }
    //         }
    //     }

    //     return AccessLevel(0);
    // }

    // function getUserMintedOrigin(
    //     address _address
    // ) external view returns (uint) {
    //     uint stateFromSanOrigin = sanOriginSoulBound.userMinted(_address);
    //     return stateFromSanOrigin;
    // }

    // function getBalanceOfOrigin(address _address) external view returns (uint) {
    //     uint balance = sanOriginSoulBound.balanceOf(_address);
    //     return balance;
    // }

    // function getUserSoulbindCreditsOrigin(
    //     address _address
    // ) external view returns (uint) {
    //     uint balance = sanOriginSoulBound.userSoulbindCredits(_address);
    //     return balance;
    // }

    modifier notZeroAddress(address _address) {
        require(_address != address(0), "0x0 addr");
        _;
    }
}
