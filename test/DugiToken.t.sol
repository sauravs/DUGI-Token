// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

import "forge-std/Test.sol";
import "../src/DugiToken.sol";

contract DugiTokenTest is Test {
    
    DugiToken public dugiToken;
    address public donationAddress = address(0x1);
    address public liquidityPairingAddress = address(0x2);
    address public charityTeamAddress = address(0x3);
    address public sushiwarpAddress = address(0x4);
    address public uniswapAddress = address(0x5);
    address public tokenBurnAdmin = address(0x6);

    function setUp() public {
        dugiToken = new DugiToken(
            donationAddress,
            liquidityPairingAddress,
            charityTeamAddress,
            sushiwarpAddress,
            uniswapAddress
        );
    }

    function testTokenName() public {
        string memory tokenName = dugiToken.name();
        assertEq(tokenName, "DUGI Token");
    }

    function testTokenSymbol() public {
        string memory tokenSymbol = dugiToken.symbol();
        assertEq(tokenSymbol, "DUGI");
    }

    function testInitialBalances() public {
        assertEq(dugiToken.balanceOf(donationAddress), (dugiToken.totalSupply() * 5) / 100);
        assertEq(dugiToken.balanceOf(liquidityPairingAddress), (dugiToken.totalSupply() * 5) / 100);
        assertEq(dugiToken.balanceOf(charityTeamAddress), (dugiToken.totalSupply() * 20) / 100);
        assertEq(dugiToken.balanceOf(sushiwarpAddress), (dugiToken.totalSupply() * 20) / 100);
        assertEq(dugiToken.balanceOf(uniswapAddress), (dugiToken.totalSupply() * 20) / 100);
        assertEq(dugiToken.balanceOf(address(dugiToken)), (dugiToken.totalSupply() * 30) / 100);
    }

    // function testBurnTokens() public {
    //     uint256 initialBurnReserve = dugiToken.balanceOf(address(dugiToken));
    //     uint256 burnAmount = (initialBurnReserve * 714) / 1_000_000;

    //     // Simulate the passage of 30 days
    //     vm.warp(block.timestamp + 30 days);

    //     dugiToken.burnTokens();

    //     uint256 newBurnReserve = dugiToken.balanceOf(address(dugiToken));
    //     assertEq(newBurnReserve, initialBurnReserve - burnAmount);
    // }

    // function testOnlyOwnerCanBurnTokens() public {
    //     address nonOwner = address(0x7);
    //     vm.prank(nonOwner);
    //     vm.expectRevert("Ownable: caller is not the owner");
    //     dugiToken.burnTokens();
    // }

    // function testBurnTokensMultipleTimes() public {
    //     uint256 initialBurnReserve = dugiToken.balanceOf(address(dugiToken));
    //     uint256 burnAmount = (initialBurnReserve * 714) / 1_000_000;

    //     for (uint256 i = 0; i < 12; i++) {
    //         // Simulate the passage of 30 days
    //         vm.warp(block.timestamp + 30 days);

    //         dugiToken.burnTokens();

    //         uint256 newBurnReserve = dugiToken.balanceOf(address(dugiToken));
    //         assertEq(newBurnReserve, initialBurnReserve - burnAmount * (i + 1));
    //     }
    // }

    // function testUpdateTokenBurnAdmin() public {
    //     address newAdmin = address(0x8);
    //     dugiToken.updateTokenBurnAdmin(newAdmin);
    //     assertEq(dugiToken.tokenBurnAdmin(), newAdmin);
    // }
}