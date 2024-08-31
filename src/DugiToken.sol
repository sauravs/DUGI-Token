
// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract DugiToken is ERC20, Ownable {
    
    uint256 private constant TOTAL_SUPPLY = 21_000_000_000_000 * 10**18; // 21 trillion tokens with 18 decimals

    address public donationAddress;
    address public liquidityPairingAddress;
    address public charityTeamAddress;
    address public sushiwarpAddress;
    address public uniswapAddress;


    uint256 public donationReserve = (TOTAL_SUPPLY * 5) / 100; // 5% for Donation

    uint256 public liquidityPairingReserve = (TOTAL_SUPPLY * 5) / 100; // 5% for Pairing Liquidity

    uint256 public charityTeamReserve = (TOTAL_SUPPLY * 20) / 100; // 20% for Charity/Team

    uint256 public sushiwarpReserve = (TOTAL_SUPPLY * 20) / 100; // 20% for Sushiwarp

    uint256 public uniswapReserve = (TOTAL_SUPPLY * 20) / 100; // 20% for Uniswap

    uint256 public burnReserve = (TOTAL_SUPPLY * 30) / 100; // 30% for Burn Reserve
   
    uint256 burnCounter ;   // for every month it should get increased by 1 ,should increase upto 420 for 35 years


    // uint256 public burnRate = 714; // 0.0714% monthly

    // uint256 public lastBurnTimestamp;

    uint256 public burnSlot = 24;  // for two years one month one slot
    bool burnStarted ;
    bool burnStoped;
    bool burnEnded;

      uint256 public lastBurnTimestamp;

    address public tokenBurnAdmin  = 0x3793f758a36c04B51a520a59520e4d845f94F9F2 ;

  
    constructor(
        address _donationAddress,
        address _liquidityPairingAddress,
        address _charityTeamAddress,
        address _sushiwarpAddress,
        address _uniswapAddress
    ) ERC20("DUGI Token", "DUGI") Ownable(msg.sender) {
        donationAddress = _donationAddress;
        liquidityPairingAddress = _liquidityPairingAddress;
        charityTeamAddress = _charityTeamAddress;
        sushiwarpAddress = _sushiwarpAddress;
        uniswapAddress = _uniswapAddress;

        _mint(donationAddress, donationReserve); 
        _mint(liquidityPairingAddress, liquidityPairingReserve); 
        _mint(charityTeamAddress, charityTeamReserve); 
        _mint(sushiwarpAddress,sushiwarpReserve); 
        _mint(uniswapAddress, uniswapReserve); 
        _mint(address(this), burnReserve); 

        
        lastBurnTimestamp = block.timestamp;
    }


    // modifer for only tokenBurnAdmin  
    modifier onlyTokenBurnAdmin() {
        require(msg.sender == tokenBurnAdmin, "Only tokenBurnAdmin can call this function");
        _;
    }

     modifier canBurn() {
        require(balanceOf(address(this)) > 0, "Burn reserve is empty");
        require(block.timestamp >= lastBurnTimestamp + 30 days, "30 days have not passed since last burn");
        _;
    }


    function updateTokenBurnAdmin(address _tokenBurnAdmin) public onlyOwner {
        tokenBurnAdmin = _tokenBurnAdmin;
    }





    // function for initiate  token burning at  rate of 0.0714% of totalsupply after every 30 days till burnReserve is 0 by the owner , the tokens should be burnt from burnReserve till burn Reserve is 0


    function burnTokens() public onlyTokenBurnAdmin canBurn {

        uint256 burnAmount = (TOTAL_SUPPLY * 714) / 1_000_000;
        _burn(address(this), burnAmount);
       
        burnCounter++;
    }


    


 




}































