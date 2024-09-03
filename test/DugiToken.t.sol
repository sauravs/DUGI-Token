// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

import "forge-std/Test.sol";
import "../src/DugiToken.sol";

contract DugiTokenTest is Test {
    DugiToken public dugiToken;

    address public owner = address(0x7cC26960D2A47c659A8DBeCEb0937148b0026fD6);
    address public donationAddress = address(0x1);
    address public liquidityPairingAddress = address(0x2);
    address public charityTeamAddress = address(0x3);
    address public sushiwarpAddress = address(0x4);
    address public uniswapAddress = address(0x5);
    address public tokenBurnAdmin = address(0x3793f758a36c04B51a520a59520e4d845f94F9F2);

    address public userA = address(0x6);
    address public userB = address(0x7);
    address public newOwner = address(0x8);

    function setUp() public {
        dugiToken = new DugiToken(
            donationAddress, liquidityPairingAddress, charityTeamAddress, sushiwarpAddress, uniswapAddress
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

    function testTotalSupply() public {
        uint256 totalSupply = dugiToken.totalSupply();
        assertEq(totalSupply, 21_000_000_000_000 * 10 ** 18);
    }

    function testDecimals() public {
        uint8 decimals = dugiToken.decimals();
        assertEq(decimals, 18);
    }

    function testInitialBalances() public {
        assertEq(dugiToken.balanceOf(donationAddress), (dugiToken.totalSupply() * 5) / 100);
        assertEq(dugiToken.balanceOf(liquidityPairingAddress), (dugiToken.totalSupply() * 5) / 100);
        assertEq(dugiToken.chairityTeamLockedReserve(), (dugiToken.totalSupply() * 20) / 100);
        assertEq(dugiToken.balanceOf(sushiwarpAddress), (dugiToken.totalSupply() * 20) / 100);
        assertEq(dugiToken.balanceOf(uniswapAddress), (dugiToken.totalSupply() * 20) / 100);
        assertEq(dugiToken.burnLockedReserve(), (dugiToken.totalSupply() * 30) / 100);
        assertEq(dugiToken.tokenBurnAdmin(), tokenBurnAdmin);
    }

    function testTransfer() public {
        uint256 amount = 1000 * 10 ** 18;

        vm.prank(donationAddress);
        dugiToken.transfer(userA, amount);
        assertEq(dugiToken.balanceOf(userA), amount);
    }

    function testTransferFrom() public {
        uint256 amount = 1000 * 10 ** 18;

        vm.prank(donationAddress);
        dugiToken.approve(userB, amount);

        vm.prank(userB);
        dugiToken.transferFrom(donationAddress, userA, amount);
        assertEq(dugiToken.balanceOf(userA), amount);
    }

    function testOwnership() public {
        assertEq(dugiToken.owner(), owner);
    }

    function testTransferOwnership() public {
        vm.prank(owner);
        dugiToken.transferOwnership(newOwner);
        assertEq(dugiToken.owner(), newOwner);
    }

    function testRenounceOwnership() public {
        vm.prank(owner);
        dugiToken.renounceOwnership();
        assertEq(dugiToken.owner(), address(0));
    }

    function testUpdateTokenBurnAdmin() public {
        address newAdmin = address(0x8);
        vm.prank(owner);
        dugiToken.updateTokenBurnAdmin(newAdmin);
        assertEq(dugiToken.tokenBurnAdmin(), newAdmin);
    }

     function testOnlyOwnerCanBurnTokens() public {
        // Simulate the passage of 30 days to meet the canBurn modifier condition
        vm.warp(block.timestamp + 30 days);

        // Ensure the burn reserve is not empty
        assert(dugiToken.burnLockedReserve() > 0);

        // Attempt to burn tokens from a non-owner address
        address nonOwner = address(0x7);
        vm.prank(nonOwner);
        vm.expectRevert("Only tokenBurnAdmin allowed");
        dugiToken.burnTokens();
    }

    
    function testBurnTokens() public {
        uint256 initialBurnReserve = dugiToken.burnLockedReserve();

        // calculate the burn amount where burn rate is 0.0714% of total supply which is 21 trillion

        uint256 burnAmount = (dugiToken.totalSupply() * 714) / 1_000_000;

        // Simulate the passage of 30 days
        vm.warp(block.timestamp + 30 days);

        vm.prank(tokenBurnAdmin);
        dugiToken.burnTokens();

        uint256 newBurnReserve = dugiToken.balanceOf(address(dugiToken)) - dugiToken.chairityTeamLockedReserve();

        assertEq(newBurnReserve, initialBurnReserve - burnAmount);

        // assert that burnCounter is increased by 1
        assertEq(dugiToken.burnCounter(), 1);
        assertEq(dugiToken.burnStarted(), true);
        assertEq(dugiToken.burnEnded(), false);
    }


    
      function testBurnTokensMultipleTimes() public {
        // as per calculation it should iterate for 420 times/420 months to burn all the tokens from burnReserve

        uint256 initialBurnReserve = dugiToken.burnLockedReserve();
        uint256 burnAmount = (dugiToken.totalSupply() * 714) / 1_000_000;

        for (uint256 i = 0; i < 420; i++) {
            // Simulate the passage of 30 days
            vm.warp(block.timestamp + 30 days);

            vm.prank(tokenBurnAdmin);

            dugiToken.burnTokens();

            uint256 newBurnReserve = dugiToken.balanceOf(address(dugiToken)) - dugiToken.chairityTeamLockedReserve();
            assertEq(newBurnReserve, initialBurnReserve - burnAmount * (i + 1));
            assertEq(dugiToken.burnCounter(), i + 1);
            assertEq(dugiToken.burnStarted(), true);
        }     

        // assert that burnCounter is equal to totalburnSlot

        assertEq(dugiToken.burnCounter(), dugiToken.totalburnSlot());
        assertEq(dugiToken.burnEnded(), true);
       // console.log(dugiToken.burnLockedReserve()); // 2520000000    000 000 000 000 000 000
    }




    
    // function testTokenBurnFailIfburnLockedReserveEmpty() public {
    //     // Simulate the passage of 30 days to meet the canBurn modifier condition
    //     vm.warp(block.timestamp + 30 days);

    //     // Ensure the burn reserve is empty
    //     uint256 currentBurnReserve = dugiToken.burnLockedReserve();
    //     currentBurnReserve = 0;

    //     // Attempt to burn tokens
    //     vm.prank(tokenBurnAdmin);
    //     vm.expectRevert("Burn reserve is empty");
    //     dugiToken.burnTokens();
    // }


  

    function testInitialLockingPeriod() public {
        vm.prank(owner);
        vm.expectRevert("Initial locking period not over yet");
        dugiToken.releaseTokens();
    }

     
     function testReleaseTokens() public {

        uint256 initialLockingPeriod = dugiToken.initialLockingPeriod();
       
        uint256 vestingTimeSlot = dugiToken.vestingPeriod();

        vm.warp(block.timestamp + initialLockingPeriod + vestingTimeSlot);
        vm.prank(owner);
        dugiToken.releaseTokens();
        assertEq(dugiToken.currentReleasedSlot(), 1);

        // assert that charityTeamAddress receives 12.5% of charityTeamReserve

        assertEq(dugiToken.balanceOf(charityTeamAddress), (dugiToken.charityTeamReserve() * 125) / 1000);

        // assert that chairityTeamLockedReserve is updated to 87.5% of charityTeamReserve

        assertEq(dugiToken.chairityTeamLockedReserve(), (dugiToken.charityTeamReserve() * 875) / 1000);

        // assert that currentVestingSlotTimestamp is updated to current block.timestamp

        assertEq(dugiToken.currentVestingSlotTimestamp(), block.timestamp);

        // assert that currentReleasedSlot is updated to 1

        assertEq(dugiToken.currentReleasedSlot(), 1);

        // test for next release

        vm.warp(block.timestamp + vestingTimeSlot);
        vm.prank(owner);
        dugiToken.releaseTokens();

        // assert that charityTeamAddress receives another 12.5% (total of 25%) of charityTeamReserve

        assertEq(dugiToken.balanceOf(charityTeamAddress), (dugiToken.charityTeamReserve() * 250) / 1000);

        // assert that chairityTeamLockedReserve is updated to 75% of charityTeamReserve

        assertEq(dugiToken.chairityTeamLockedReserve(), (dugiToken.charityTeamReserve() * 750) / 1000);

        // assert that currentVestingSlotTimestamp is updated to current block.timestamp

        assertEq(dugiToken.currentVestingSlotTimestamp(), block.timestamp);

        // assert that currentReleasedSlot is updated to 2

        assertEq(dugiToken.currentReleasedSlot(), 2);

        // test for next release

        vm.warp(block.timestamp + vestingTimeSlot);
        vm.prank(owner);
        dugiToken.releaseTokens();

        // assert that charityTeamAddress receives another 12.5% (total of 37.5%) of charityTeamReserve

        assertEq(dugiToken.balanceOf(charityTeamAddress), (dugiToken.charityTeamReserve() * 375) / 1000);

        // assert that chairityTeamLockedReserve is updated to 62.5% of charityTeamReserve

        assertEq(dugiToken.chairityTeamLockedReserve(), (dugiToken.charityTeamReserve() * 625) / 1000);

        // assert that currentVestingSlotTimestamp is updated to current block.timestamp

        assertEq(dugiToken.currentVestingSlotTimestamp(), block.timestamp);

        // assert that currentReleasedSlot is updated to 3

        assertEq(dugiToken.currentReleasedSlot(), 3);
        
        // test for next release

        vm.warp(block.timestamp + vestingTimeSlot);
        vm.prank(owner);
        dugiToken.releaseTokens();

        // assert that charityTeamAddress receives another 12.5% (total of 50%) of charityTeamReserve
        
        assertEq(dugiToken.balanceOf(charityTeamAddress), (dugiToken.charityTeamReserve() * 500) / 1000);

        // assert that chairityTeamLockedReserve is updated to 50% of charityTeamReserve

        assertEq(dugiToken.chairityTeamLockedReserve(), (dugiToken.charityTeamReserve() * 500) / 1000);

        // assert that currentVestingSlotTimestamp is updated to current block.timestamp

        assertEq(dugiToken.currentVestingSlotTimestamp(), block.timestamp);

        // assert that currentReleasedSlot is updated to 4

        assertEq(dugiToken.currentReleasedSlot(), 4);

        // test for next release

        vm.warp(block.timestamp + vestingTimeSlot);

        vm.prank(owner);

        dugiToken.releaseTokens();

        // assert that charityTeamAddress receives another 12.5% (total of 62.5%) of charityTeamReserve

        assertEq(dugiToken.balanceOf(charityTeamAddress), (dugiToken.charityTeamReserve() * 625) / 1000);

        // assert that chairityTeamLockedReserve is updated to 37.5% of charityTeamReserve

        assertEq(dugiToken.chairityTeamLockedReserve(), (dugiToken.charityTeamReserve() * 375) / 1000);

        // assert that currentVestingSlotTimestamp is updated to current block.timestamp

        assertEq(dugiToken.currentVestingSlotTimestamp(), block.timestamp);

        // assert that currentReleasedSlot is updated to 5

        assertEq(dugiToken.currentReleasedSlot(), 5);

        // test for next release

        vm.warp(block.timestamp + vestingTimeSlot);

        vm.prank(owner);

        dugiToken.releaseTokens();

        // assert that charityTeamAddress receives another 12.5% (total of 75%) of charityTeamReserve

        assertEq(dugiToken.balanceOf(charityTeamAddress), (dugiToken.charityTeamReserve() * 750) / 1000);

        // assert that chairityTeamLockedReserve is updated to 25% of charityTeamReserve

        assertEq(dugiToken.chairityTeamLockedReserve(), (dugiToken.charityTeamReserve() * 250) / 1000);

        // assert that currentVestingSlotTimestamp is updated to current block.timestamp

        assertEq(dugiToken.currentVestingSlotTimestamp(), block.timestamp);

        // assert that currentReleasedSlot is updated to 6

        assertEq(dugiToken.currentReleasedSlot(), 6);

        // test for next release

        vm.warp(block.timestamp + vestingTimeSlot);

        vm.prank(owner);
        
        dugiToken.releaseTokens();

        // assert that charityTeamAddress receives another 12.5% (total of 87.5%) of charityTeamReserve

        assertEq(dugiToken.balanceOf(charityTeamAddress), (dugiToken.charityTeamReserve() * 875) / 1000);

        // assert that chairityTeamLockedReserve is updated to 12.5% of charityTeamReserve

        assertEq(dugiToken.chairityTeamLockedReserve(), (dugiToken.charityTeamReserve() * 125) / 1000);

        // assert that currentVestingSlotTimestamp is updated to current block.timestamp

        assertEq(dugiToken.currentVestingSlotTimestamp(), block.timestamp);

        // assert that currentReleasedSlot is updated to 7

        assertEq(dugiToken.currentReleasedSlot(), 7);

        // test for next release

        vm.warp(block.timestamp + vestingTimeSlot);

        vm.prank(owner);

        dugiToken.releaseTokens();

        // assert that charityTeamAddress receives another 12.5% (total of 100%) of charityTeamReserve

        assertEq(dugiToken.balanceOf(charityTeamAddress), dugiToken.charityTeamReserve());

        // assert that chairityTeamLockedReserve is updated to 0

        assertEq(dugiToken.chairityTeamLockedReserve(), 0);

        // assert that currentVestingSlotTimestamp is updated to current block.timestamp

        assertEq(dugiToken.currentVestingSlotTimestamp(), block.timestamp);

        // assert that currentReleasedSlot is updated to 8

        assertEq(dugiToken.currentReleasedSlot(), 8);
    
        // assert that currentReleasedSlot is equal to totalVestingSlots

        assertEq(dugiToken.currentReleasedSlot(), dugiToken.totalVestingSlots());



    }

    
}
