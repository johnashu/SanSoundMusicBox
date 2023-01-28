//SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

interface ISanOrigin {
    function userMinted(address) external view returns (uint256);

    function userSoulbindCredits(address) external view returns (uint256);

    function balanceOf(address) external view returns (uint256);
}
