// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.18;

import {SanctuaryScriptBase} from "script/SanctuaryBase.s.sol";

contract SanctuaryScriptMainNet is SanctuaryScriptBase {
    function setUp() public {}

    function run() external {
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");
        vm.startBroadcast(deployerPrivateKey);
        createContract();
        vm.stopBroadcast();
    }
}
