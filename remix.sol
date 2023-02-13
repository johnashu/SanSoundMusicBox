//SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

interface ISanctuary {
    enum TokenLevel {
        Unbound,
        Merged,
        Citizen,
        Defiant,
        Hanzoku,
        The33
    }

    function mintFromSanOrigin(uint256[] calldata tokenIds, TokenLevel _newLevel) external payable;

    function mintFromPartner(
        uint256[] calldata originTokenIds,
        TokenLevel _newLevel,
        uint256[] calldata partnerTokenIds,
        address _contractAddress
    ) external payable;
}

contract Mint {
    address sanctuaryAddress = 0x046Ed22Fa63E7595628b4DaF573dc66E2FeDa50D;

    function mintFromSanOrigin(uint256[] calldata tokenIds, ISanctuary.TokenLevel _newLevel) external payable {
        ISanctuary(sanctuaryAddress).mintFromSanOrigin(tokenIds, _newLevel);
    }
}
