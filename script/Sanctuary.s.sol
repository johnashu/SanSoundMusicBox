// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.18;

import {SanctuaryScriptBase} from "script/SanctuaryBase.s.sol";

contract SanctuaryScriptMainNet is SanctuaryScriptBase {
    address SAN_ORIGIN_ADDRESS;
    uint256[6] _levelPrices = [0, 0, 0, 0, 0, 0];

    function setUp() public {}

    function run() external {
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");
        vm.startBroadcast(deployerPrivateKey);
        createContract(SAN_ORIGIN_ADDRESS, _levelPrices);
        vm.stopBroadcast();
    }
}
