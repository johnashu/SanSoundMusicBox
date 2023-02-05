//SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

interface ISanOriginNFT {
    enum SoulboundLevel {
        Unbound,
        One,
        Two,
        Three,
        Four
    }

    function tokenLevel(uint256) external view returns (uint256);

    function ownerOf(uint256 _tokenId) external view returns (address);

    function balanceOf(address) external view returns (uint256);

    function tokenOfOwnerByIndex(address owner, uint256 index) external view returns (uint256);
}
