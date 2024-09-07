// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

import {Script, console} from "forge-std/Script.sol";
import "../src/DugiToken.sol";

contract DeployDugiToken is Script {
    function run() external {
        // Define the addresses for the reserves
        address donationAddress = 0x4921B6a8Ce3eF0c443518F964f9D06763823601E;
        address uniswapAddress = 0x7620B333a87102A053DBd483D57D826a3155710c;
        address operationWallet = 0xB11CDf0236b8360c17D1886fEB12400E93b3E88A; // operationWallet address

        address liquidityPairingAddress = 0x2fb656a60705d0D25de0A34f0b6ee0f110971A49;

        address charityTeamAddress = 0x3456789012345678901234567890123456789012; // yet to be updated

        uint256 pvtKey = vm.envUint("DEPLOYER_PVT_KEY");
        address account = vm.addr(pvtKey);
        console.log("deployer address on polygon_mainnet = ", account);

        vm.startBroadcast(pvtKey);

        // Deploy the DugiToken contract
        DugiToken dugiToken =
            new DugiToken(donationAddress, liquidityPairingAddress, charityTeamAddress, operationWallet, uniswapAddress);

        // Stop broadcasting transactions
        vm.stopBroadcast();
    }
}
