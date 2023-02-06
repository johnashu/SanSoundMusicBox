//SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

interface IMusicBox721 {
    error ExceedsMaxMintPerAddress();
    error MaxSupplyReached();
    error FailedToWithdraw();
    error IncorrectPaymentAmount();
    error InvalidSignature();
    error TokenDoesNotExist();
    error TokenNotOwned();
    error MintAmountTokensIncorrect();
}
