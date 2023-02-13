//SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

interface ISanOriginNFT {
    function tokenLevel(uint256) external view returns (uint256);
    function batchSafeTransferFrom(address _from, address _to, uint256[] calldata _tokenIDs, bytes calldata _data)
        external;
}
