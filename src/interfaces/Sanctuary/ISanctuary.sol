//SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

/**
 * @title SanSound Sanctuary
 * @author Maffaz
 */

interface ISanctuary {

function balanceOf(address owner) view  external returns(uint);
function ownerOf(uint tokenId) view external returns(address);
function tokensOwnedByAddress(address owner) view external returns(uint[]);


}
