// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.17;

import "lib/forge-std/src/Script.sol";
import {Sanctuary} from "src/Sanctuary.sol";

contract SanctuaryScriptBase is Script {
    function createContract(address SAN_ORIGIN_ADDRESS, uint256[6] memory _levelPrices) public {
        new Sanctuary(
            string("SanSoundSanctuary"),
            string("SSS"),
            string("https://example.com/"),
            string(""),
            string("SanSoundMusicBox"),
            string("SSMB"),
            string("https://example.com/"),
            string(""),
            SAN_ORIGIN_ADDRESS,
            _levelPrices
            );
    }
}

// # To load the variables in the .env file
// source .env

// # To deploy and verify our contract
// forge script script/SanctuaryTestnet.s.sol:SanctuaryScript --broadcast --verify -vvvv --rpc-url https://goerli.infura.io/v3/ea2a8615e8464b408c31f455df41edd7

// https://book.getfoundry.sh/forge/deploying
