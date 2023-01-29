//SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

interface ISanOrigin {
    function tokenLevel(uint) external view returns (uint);

    function ownerOf(uint256 _tokenId) external view returns (address);

    // function userMinted(address) external view returns (uint256);

    // function userSoulbindCredits(address) external view returns (uint256);

    function balanceOf(address) external view returns (uint256);

    function tokenOfOwnerByIndex(
        address owner,
        uint256 index
    ) external view returns (uint256);
}
