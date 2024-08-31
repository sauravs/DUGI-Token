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
        assertEq(dugiToken.balanceOf(charityTeamAddress), 0); // Initially locked
        assertEq(dugiToken.balanceOf(sushiwarpAddress), (dugiToken.totalSupply() * 20) / 100);
        assertEq(dugiToken.balanceOf(uniswapAddress), (dugiToken.totalSupply() * 20) / 100);
        assertEq(dugiToken.balanceOf(address(dugiToken)), (dugiToken.totalSupply() * 50) / 100); // Burn + Charity reserves
    }

    function testBurnTokens() public {
        uint256 initialBurnReserve = dugiToken.burnLockedReserve();
        uint256 burnAmount = (dugiToken.totalSupply() * 714) / 1_000_000;

        // Simulate the passage of 30 days
        vm.warp(block.timestamp + 30 days);

        vm.prank(tokenBurnAdmin);
        dugiToken.burnTokens();

        uint256 newBurnReserve = dugiToken.burnLockedReserve();
        assertEq(newBurnReserve, initialBurnReserve - burnAmount);
    }

    function testOnlyTokenBurnAdminCanBurnTokens() public {
        // Simulate the passage of 30 days to meet the canBurn modifier condition
        vm.warp(block.timestamp + 30 days);

        // Ensure the burn reserve is not empty
        assert(dugiToken.burnLockedReserve() > 0);

        // Attempt to burn tokens from a non-admin address
        address nonAdmin = address(0x7);
        vm.prank(nonAdmin);
        vm.expectRevert("Only tokenBurnAdmin can call this function");
        dugiToken.burnTokens();
    }

    function testBurnTokensMultipleTimes() public {
        uint256 initialBurnReserve = dugiToken.burnLockedReserve();
        uint256 burnAmount = (dugiToken.totalSupply() * 714) / 1_000_000;

        for (uint256 i = 0; i < 12; i++) {
            // Simulate the passage of 30 days
            vm.warp(block.timestamp + 30 days);

            vm.prank(tokenBurnAdmin);
            dugiToken.burnTokens();

            uint256 newBurnReserve = dugiToken.burnLockedReserve();
            assertEq(newBurnReserve, initialBurnReserve - burnAmount * (i + 1));
        }
    }

    function testUpdateTokenBurnAdmin() public {
        address newAdmin = address(0x8);
        dugiToken.updateTokenBurnAdmin(newAdmin);
        assertEq(dugiToken.tokenBurnAdmin(), newAdmin);
    }

    function testInitialLockingPeriod() public {
        // Ensure tokens are locked initially
        vm.expectRevert("Initial locking period not over");
        dugiToken.releaseTokens();
    }

    function testVestingSchedule() public {
        // Simulate the passage of 24 months
        vm.warp(block.timestamp + 24 * 30 days);

        // Release the first slot
        dugiToken.releaseTokens();
        assertEq(dugiToken.balanceOf(charityTeamAddress), (dugiToken.charityTeamReserve() * 125) / 1000);

        // Simulate the passage of another 3 months
        vm.warp(block.timestamp + 3 * 30 days);

        // Release the second slot
        dugiToken.releaseTokens();
        assertEq(dugiToken.balanceOf(charityTeamAddress), (dugiToken.charityTeamReserve() * 250) / 1000);
    }

    function testVestingCompletion() public {
        // Simulate the passage of 24 months + 24 months (48 months total)
        vm.warp(block.timestamp + 48 * 30 days);

        // Release all slots
        dugiToken.releaseTokens();
        assertEq(dugiToken.balanceOf(charityTeamAddress), dugiToken.charityTeamReserve());
    }
}