//SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

/**
 * @title SanSound Rebirth
 * @author Maffaz
 */
import {ITokenLevels} from "src/interfaces/Levels/ITokenLevels.sol";

interface IRebirth {
    function mintFromSanOrigin(uint256[] calldata tokenIds, ITokenLevels.TokenLevel _newLevel) external payable;

    function mintFromPartner(
        uint256[] calldata originTokenIds,
        ITokenLevels.TokenLevel _newLevel,
        uint256[] calldata partnerTokenIds,
        address _contractAddress
    ) external payable;
}
