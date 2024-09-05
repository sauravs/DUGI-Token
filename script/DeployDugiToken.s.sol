// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

import {Script, console} from "forge-std/Script.sol";
import "../src/DugiToken.sol";

contract DeployDugiToken is Script {
    function run() external {
        // Define the addresses for the reserves
        address donationAddress = 0x1234567890123456789012345678901234567890;
        address liquidityPairingAddress = 0x2345678901234567890123456789012345678901;
        address charityTeamAddress = 0x3456789012345678901234567890123456789012;
        address sushiwarpAddress = 0x4567890123456789012345678901234567890123;
        address uniswapAddress = 0x5678901234567890123456789012345678901234;

       uint pvtKey = vm.envUint("DEPLOYER_PVT_KEY");
       address account = vm.addr(pvtKey);
       console.log("deployer address on amoy = ", account);

        vm.startBroadcast(pvtKey);

       // Deploy the DugiToken contract
        DugiToken dugiToken = new DugiToken(
            donationAddress, liquidityPairingAddress, charityTeamAddress, sushiwarpAddress, uniswapAddress
        );

        // Stop broadcasting transactions
        vm.stopBroadcast();
    }
}

