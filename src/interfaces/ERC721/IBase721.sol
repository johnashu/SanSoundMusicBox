//SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

interface IBase721 {
    function batchSafeTransferFrom(address _from, address _to, uint256[] calldata _tokenIds, bytes calldata _data)
        external;

    error ExceedsMaxMintPerAddress();
    error MaxSupplyReached();
    error IncorrectPaymentAmount();
    error TokenDoesNotExist();
    error TokenNotOwned();
    error MintAmountTokensIncorrect();
    error FailedToWithdraw();
    error NothingToWithdraw();
    error ZeroAddress();
    error ExceedsMaxRoyaltiesPercentage();
    error MaximumBulkMintExceeded();
    error TokenAlreadyMinted(uint256 tokenId);
    error nonERC721ReceiverImplementer();
}
