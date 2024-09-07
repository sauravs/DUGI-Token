// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

import {Script, console} from "forge-std/Script.sol";
import "../src/DugiToken.sol";

contract DeployDugiToken is Script {
    function run() external {
        // Define the wallet addresses for the reserves
        
        address donationAddress = 0x4921B6a8Ce3eF0c443518F964f9D06763823601E;       // christain
        address uniswapAddress = 0x7620B333a87102A053DBd483D57D826a3155710c;        // christain
        address operationWallet = 0xB11CDf0236b8360c17D1886fEB12400E93b3E88A;       // christain


        address liquidityPairingAddress = 0x2EB4c5f243BF7F74A57F983E1bD5CF67f469c0Df;  //christian
        address charityTeamAddress = 0x2fb656a60705d0D25de0A34f0b6ee0f110971A49;       // christian



        // address donationAddress = 0x1c4c2C56960411b6b59cA0b60d6EDD95FcBE1413;
        // address uniswapAddress = 0xe79930CEAe29F917bFd6a8bAe02C6418561d8dBc;
        // address operationWallet = 0x844ed6F4CAb22a5a769aaa0c36BB6A840fD91439; 


        // address liquidityPairingAddress = 0xeE79671a43BB522245a4d6B89005f770623D1E4F;
        // address charityTeamAddress = 0x52dEB5Dd857409d15960E162e5FD253F770e1773; 

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
