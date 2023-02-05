//SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

interface ISAN721 {
    error ExceedsMaxMintPerAddress();
    error ExceedsMaxRoyaltiesPercentage();
    error ExceedsMaxSupply();
    error ExceedsMintAllocation();
    error FailedToWithdraw();
    error IncorrectPaymentAmount();
    error InvalidSignature();
    error SaleStateNotActive();
    error TokenDoesNotExist();
    error TokenNotOwned();
}
