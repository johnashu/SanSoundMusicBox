//SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

/**
 * @title SanSound Sanctuary
 * @author Maffaz
 */

interface ISanctuary {

    event BatchTransfer(address indexed from, address indexed to, uint256 tokenIdFrom, uint tokenIdTo);

    function balanceOf(address owner) external view returns (uint256);
    function ownerOf(uint256 tokenId) external view returns (address);

    function tokensOwnedByAddress(address owner) external view returns (uint256[] memory);
}
