//SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

interface ISanOriginNFT {
    function tokenLevel(uint256) external view returns (uint256);

    function tokenOfOwnerByIndex(address owner, uint256 index) external view returns (uint256);
}
