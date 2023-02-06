//SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

interface IMusicBox721 {
    error ExceedsMaxMintPerAddress();
    error MaxSupplyReached();
    error IncorrectPaymentAmount();
    error TokenDoesNotExist();
    error TokenNotOwned();
    error MintAmountTokensIncorrect();
    error FailedToWithdraw();
    error NothingToWithdraw();
    error ZeroAddress();
}
