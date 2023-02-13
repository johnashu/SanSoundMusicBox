// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.18;

import {SanctuaryScriptBase} from "script/SanctuaryBase.s.sol";

contract SanctuaryScriptTestNet is SanctuaryScriptBase {
    address SAN_ORIGIN_ADDRESS = 0xd1feACdfbE57727aea02FCd81e57c3a2802C8A64;
    uint256[6] _levelPrices = [0, 0, 1000, 2000, 3000, 4000];

    function setUp() public {}

    function run() external {
        uint256 deployerPrivateKey = vm.envUint("TEST_PRIVATE_KEY");
        vm.startBroadcast(deployerPrivateKey);
        createContract(SAN_ORIGIN_ADDRESS, _levelPrices);
        vm.stopBroadcast();
    }
}
