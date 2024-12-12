// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

import {Test} from "forge-std/Test.sol";
import {StdInvariant} from "forge-std/StdInvariant.sol";
//import {SymTest} from "forge-std/SymTest.sol";
import {DugiToken} from "../../src//DugiToken.sol";

contract HalmosTest is StdInvariant, Test {

      DugiToken public dugiToken;

    address public owner = address(0x1e364a3634289Bc315a6DFF4e5fD018B5C6B3ef6);
    address public donationAddress = address(0x4921B6a8Ce3eF0c443518F964f9D06763823601E);
    address public liquidityPairingAddress = address(0x2EB4c5f243BF7F74A57F983E1bD5CF67f469c0Df);
    address public charityTeamAddress = address(0x2fb656a60705d0D25de0A34f0b6ee0f110971A49);
    address public operationWalletAddress = address(0xB11CDf0236b8360c17D1886fEB12400E93b3E88A);
    address public uniswapAddress = address(0x7620B333a87102A053DBd483D57D826a3155710c);
    address public tokenBurnAdmin = address(0xa5570A1B859401D53FB66f4aa1e250867803a408);
    address public onlyCharityTeamVestingAdmin = address(0x50cfaA96bbb8dA3066adBeaBA4d239eEC4578CDF);

    address public userA = address(0x6);
    address public userB = address(0x7);
    address public newOwner = address(0x8);

    function setUp() public {
        dugiToken = new DugiToken(
            donationAddress, liquidityPairingAddress, charityTeamAddress, operationWalletAddress, uniswapAddress
        );
    }



function check_transfer(address sender, address receiver, uint256 amount) public {
    // specify input conditions
    vm.assume(receiver != address(0));
    vm.assume(dugiToken.balanceOf(sender) >= amount);

    // record the current balance of sender and receiver
    uint256 balanceOfSender = dugiToken.balanceOf(sender);
    uint256 balanceOfReceiver = dugiToken.balanceOf(receiver);

    // call target contract
    vm.prank(sender);
    dugiToken.transfer(receiver, amount);

    // check output state
    assert(dugiToken.balanceOf(sender) == balanceOfSender - amount);
    assert(dugiToken.balanceOf(receiver) == balanceOfReceiver + amount);
}





//     function  checktotalSupplyShouldNeverBeZero() public view {

//   // specify input conditions

//     // call target contracts


//     // check output states

//      //assert(true);
//    assert(dugiToken.totalSupply() != 0);
    

//     }




}


