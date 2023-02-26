//SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

interface IBase721 {
    error AmountExceedsSupply();
    error IncorrectPaymentAmount();
    error TokenDoesNotExist();
    error TokenNotOwned();
    error MintAmountTokensIncorrect();
    error FailedToWithdraw();
    error NothingToWithdraw();
}
