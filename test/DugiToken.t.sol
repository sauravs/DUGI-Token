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


    function testTotalSupply() public {
        uint256 totalSupply = dugiToken.totalSupply();
        assertEq(totalSupply, 21_000_000_000_000 * 10**18);
    }

    function testInitialBalances() public {
        assertEq(dugiToken.balanceOf(donationAddress), (dugiToken.totalSupply() * 5) / 100);
        assertEq(dugiToken.balanceOf(liquidityPairingAddress), (dugiToken.totalSupply() * 5) / 100);
       assertEq(dugiToken.chairityTeamLockedReserve(), (dugiToken.totalSupply() * 20) / 100);
        assertEq(dugiToken.balanceOf(sushiwarpAddress), (dugiToken.totalSupply() * 20) / 100);
        assertEq(dugiToken.balanceOf(uniswapAddress), (dugiToken.totalSupply() * 20) / 100);
        assertEq(dugiToken.burnLockedReserve(), (dugiToken.totalSupply() * 30) / 100);
    }


    
    function testUpdateTokenBurnAdmin() public {
        address newAdmin = address(0x8);
        vm.prank(owner);
        dugiToken.updateTokenBurnAdmin(newAdmin);
        assertEq(dugiToken.tokenBurnAdmin(), newAdmin);
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
    }


        function testOnlyOwnerCanBurnTokens() public {
        // Simulate the passage of 30 days to meet the canBurn modifier condition
        vm.warp(block.timestamp + 30 days);

        // Ensure the burn reserve is not empty
        assert(dugiToken.burnLockedReserve() > 0);

        // Attempt to burn tokens from a non-owner address
        address nonOwner = address(0x7);
        vm.prank(nonOwner);
        vm.expectRevert("Only tokenBurnAdmin can call this function");
        dugiToken.burnTokens();
    }

    function testBurnTokensMultipleTimes() public {

        // as per calculation it should iterate for 420 times/420 months to burn all the tokens from burnReserve 
       
        uint256 initialBurnReserve = dugiToken.burnLockedReserve();
        uint256 burnAmount = (dugiToken.totalSupply() * 714) / 1_000_000;

        for (uint256 i = 0; i < 400; i++) {
            // Simulate the passage of 30 days
            vm.warp(block.timestamp + 30 days);
            
            vm.prank(tokenBurnAdmin);

            dugiToken.burnTokens();

            uint256 newBurnReserve = dugiToken.balanceOf(address(dugiToken)) - dugiToken.chairityTeamLockedReserve();
            assertEq(newBurnReserve, initialBurnReserve - burnAmount * (i + 1));
        }

 }

      function testInitialLockingPeriod() public {
         vm.prank(owner);
        
        vm.expectRevert("Initial locking period not over");
        dugiToken.releaseTokens();
    }

      function testVestingSchedule() public {
        // Simulate the passage of 24 months
        vm.warp(block.timestamp + 24 * 30 days + 3*30 days);

        

        // Release the first slot
        vm.prank(owner);
        dugiToken.releaseTokens();
        assertEq(dugiToken.balanceOf(charityTeamAddress), (dugiToken.charityTeamReserve() * 125) / 1000);

        // Simulate the passage of another 3 months
        vm.warp(block.timestamp + 3 * 30 days);

        // Release the second slot
        vm.prank(owner);
        dugiToken.releaseTokens();
        assertEq(dugiToken.balanceOf(charityTeamAddress), (dugiToken.charityTeamReserve() * 250) / 1000);

        // Simulate the passage of another 3 months

        vm.warp(block.timestamp + 3 * 30 days);

        // Release the third slot
        vm.prank(owner);
        dugiToken.releaseTokens();
        assertEq(dugiToken.balanceOf(charityTeamAddress), (dugiToken.charityTeamReserve() * 375) / 1000);


        // Simulate the passage of another 3 months

        vm.warp(block.timestamp + 3 * 30 days);

        // Release the fourth slot
        vm.prank(owner);
        dugiToken.releaseTokens();
        assertEq(dugiToken.balanceOf(charityTeamAddress), (dugiToken.charityTeamReserve() * 500) / 1000);

        // Simulate the passage of another 3 months

        vm.warp(block.timestamp + 3 * 30 days);

        // Release the fifth slot

        vm.prank(owner);
        dugiToken.releaseTokens();
        assertEq(dugiToken.balanceOf(charityTeamAddress), (dugiToken.charityTeamReserve() * 625) / 1000);


        // Simulate the passage of another 3 months

        vm.warp(block.timestamp + 3 * 30 days);

        // Release the sixth slot

        vm.prank(owner);
        dugiToken.releaseTokens();
        assertEq(dugiToken.balanceOf(charityTeamAddress), (dugiToken.charityTeamReserve() * 750) / 1000);


        // Simulate the passage of another 3 months

        vm.warp(block.timestamp + 3 * 30 days);

        // Release the seventh slot

        vm.prank(owner);
        dugiToken.releaseTokens();
        assertEq(dugiToken.balanceOf(charityTeamAddress), (dugiToken.charityTeamReserve() * 875) / 1000);


        // Simulate the passage of another 3 months

        vm.warp(block.timestamp + 3 * 30 days);

        // Release the eighth slot

        vm.prank(owner);
        dugiToken.releaseTokens();
        assertEq(dugiToken.balanceOf(charityTeamAddress), dugiToken.charityTeamReserve());

        // assert that token contract balance is chairtyTeamReserve 

        //assertEq(dugiToken.balanceOf(address(dugiToken)), dugiToken.charityTeamReserve());



    }

    // function testVestingCompletion() public {
    //     // Simulate the passage of 24 months + 24 months (48 months total)
    //     vm.warp(block.timestamp + 48 * 30 days);

    //     // Release all slots
    //     vm.prank(owner);
    //     dugiToken.releaseTokens();
    //     assertEq(dugiToken.balanceOf(charityTeamAddress), dugiToken.charityTeamReserve());
    // }




    function testTransfer() public {
        uint256 amount = 1000 * 10**18;

        vm.prank(donationAddress);
        dugiToken.transfer(userA, amount);
        assertEq(dugiToken.balanceOf(userA), amount);
    }

    function testTransferFrom() public {
        uint256 amount = 1000 * 10**18;
        
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

 

}