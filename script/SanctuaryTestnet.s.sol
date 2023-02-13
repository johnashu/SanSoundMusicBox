// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.17;

import "lib/forge-std/src/Script.sol";
import {Sanctuary} from "src/Sanctuary.sol";

contract SanctuaryScript is Script {
    address SAN_ORIGIN_ADDRESS = 0xd1feACdfbE57727aea02FCd81e57c3a2802C8A64;
    uint256[6] _levelPrices = [0, 0, 1000, 2000, 3000, 4000];

    function setUp() public {}

    function run() external {
        uint256 deployerPrivateKey = vm.envUint("TEST_PRIVATE_KEY");
        vm.startBroadcast(deployerPrivateKey);

        new Sanctuary(
            string("SanSoundMusicBox"),
            string("SMB"),
            string("https://example.com/"),
            string(""),
            SAN_ORIGIN_ADDRESS,
            _levelPrices
            );

        vm.stopBroadcast();
    }
}

// # To load the variables in the .env file
// source .env

// # To deploy and verify our contract
// forge script script/SanctuaryTestnet.s.sol:SanctuaryScript --broadcast --verify -vvvv --rpc-url https://goerli.infura.io/v3/ea2a8615e8464b408c31f455df41edd7

// https://book.getfoundry.sh/forge/deploying
