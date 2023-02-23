//SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

interface IMusicBox {
    enum MusicBoxLevel {
        NoLevel,
        Common,
        Rare,
        Legendary,
        Locked
    }

    function batchSafeTransferFrom(address _from, address _to, uint256[] calldata _tokenIds, bytes calldata _data)
        external;

    event BatchTransfer(address indexed from, address indexed to, uint256[] _tokenIds);

    function mintFromSantuary(address _to, MusicBoxLevel musicBoxLevel) external;

    error OnlySanctuaryAllowedToMint();
    error ExceedsMaxRoyaltiesPercentage();
    error nonERC721ReceiverImplementer();
    error LockupTimeZero();
    error TokenLocked();
    error WrongCallingAddress();
}
