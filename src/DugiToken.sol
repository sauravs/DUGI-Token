// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/ERC20Burnable.sol";

/// @title DugiToken - ERC20 Token with specific token burning reserve and in built token vesting mechanism for charity/team reserve
/// @notice This contract implements an ERC20 token with specific reserves for donation, liquidity pairing, charity/tem, sushiwarp, and uniswap. It also includes mechanisms for token burning and vesting for team reserve.

/**
 *
 *
 *    DugiToken After Contract Deployment Token Allocation and Wallet Address Details:
 *
 * 1) Fund Reserve For Donation (donationReserve): 5% of total supply
 *    Hold by Wallet Address: donationAddress -> 0x4921B6a8Ce3eF0c443518F964f9D06763823601E
 *
 * 2) Fund Reserve For Providing Liquidity to Uniswap (uniswapReserve) : 20% of total supply
 *    Hold by Wallet Address: uniswapWalletAddress -> 0x7620B333a87102A053DBd483D57D826a3155710c
 *
 *
 * 3) Fund Reserve For Operation Wallet (operationReserve) : 20% of total supply
 *    Hold by Wallet Address: operationWallet -> 0xB11CDf0236b8360c17D1886fEB12400E93b3E88A
 *
 * 4) Fund Reserve For Charity/Team (charityTeamReserve): 20% of total supply
 *    Hold by Wallet Address(after vesting cycle complete): charityTeamAddress -> 0x2fb656a60705d0D25de0A34f0b6ee0f110971A49
 *
 * 5) Fund Reserved to ensure sufficient liquidity for smooth trading (liquidityPairingReserve): 5% of total supply
 *    Hold by Wallet Address(after vesting cycle complete): liquidityPairingAddress  -> 0x2EB4c5f243BF7F74A57F983E1bD5CF67f469c0Df
 *
 * 6) Fund Reserved for Token Burning (burnReserve) : 30% of total supply
 *    Hold by : Dugi Token Contract
 *
 * 7) Dugi Token Contract Owner : 0x1e364a3634289Bc315a6DFF4e5fD018B5C6B3ef6
 *
 * 8) DugiTokenBurn Admin Wallet (tokenBurnAdmin) : 0xa5570A1B859401D53FB66f4aa1e250867803a408
 *
 * 9) DugiTokenVesting Admin Wallet(tokenCharityTeamVestingAdmin) : 0x50cfaA96bbb8dA3066adBeaBA4d239eEC4578CDF
 *
 *
 *
 */
contract DugiToken is ERC20, Ownable, ERC20Burnable {

    //// @notice Total supply of the token (21 trillion with 18 decimals)
    uint256 private constant TOTAL_SUPPLY = 21_000_000_000_000 * 10 ** 18; 
    
    /// @notice Address for donation reserve
    address public donationAddress;                
   
    /// @notice Wallet address reserved reserved to ensure sufficient liquidity for smooth trading
    address public liquidityPairingAddress;      
    
    /// @notice Wallet Address for charity/team reserve
    address public charityTeamAddress;           
    
     /// @notice Wallet Address for operation reserve
    address public operationWallet;             
    
    /// @notice Wallet Address for uniswap reserve
    address public uniswapWalletAddress;        
   
    
    /// @notice 5% of total supply reserved for donation
    uint256 private donationReserve = (TOTAL_SUPPLY * 5) / 100;

    /// @notice 5% of total supply reserved to ensure sufficient liquidity for smooth trading

    uint256 private liquidityPairingReserve = (TOTAL_SUPPLY * 5) / 100;
   

     /// @notice 20% of total supply reserved for charity/team
    uint256 public charityTeamReserve = (TOTAL_SUPPLY * 20) / 100;
  

    /// @notice 20% of total supply reserved for operationReserve
    uint256 private operationReserve = (TOTAL_SUPPLY * 20) / 100;
  
     /// @notice 20% of total supply reserved for providing liquidity to uniswap
    uint256 private uniswapReserve = (TOTAL_SUPPLY * 20) / 100;
   
     /// @notice 30% of total supply reserved for token burning
    uint256 private burnReserve = (TOTAL_SUPPLY * 30) / 100;
  

     /// @notice Locked reserve for charity team , helps tracking current charity/team reserve

    uint256 public chairityTeamLockedReserve;

    /// @notice Locked reserve for token burning, helps tracking current burn reserve
    uint256 public burnLockedReserve;
    
    /// @notice Indicates if burning  cyclehas started
    bool public burnStarted;
    
    /// @notice Indicates if burning cycle has ended
    bool public burnEnded;

    /// @notice Indicates if charity team tokens are yet locked initially

    bool public chairtyTeamTokenInitiallyLocked;

    /// @notice Timestamp of the last token burn round

    uint256 public lastBurnTimestamp;

    /// @notice Address of the token burn admin who can burn tokens
    address public tokenBurnAdmin = 0xa5570A1B859401D53FB66f4aa1e250867803a408;

    /// @notice Address of the charity/team token vesting admin who can release charity/team tokens
    address public tokenCharityTeamVestingAdmin = 0x50cfaA96bbb8dA3066adBeaBA4d239eEC4578CDF;

    
    /// @notice Initial locking period  before tokenVesting starts (24 months)
    uint32 public constant initialLockingPeriod = 24 * 30 days;

        /// @notice Total Number of slots/rounds for token burning (Number of months in 35 years + 1 month to burn residue tokens)

    uint32 public totalburnSlot = 421;

    /// @notice Counter to keep track of the number of token burn rounds
    uint32 public burnCounter;

    /// @notice Number of vesting slots for charity team tokens (8 slots ,every three months ,will go on for 2 years)
    uint8 public constant totalVestingSlots = 8;
 
    /// @notice Counter to keep track of current released slot for charity team tokens
    uint8 public currentReleasedSlot;

    /// @notice Vesting period for charity team tokens after intial locking period over (3 months)
    uint32 public constant vestingPeriod = 3 * 30 days;

    /// @notice Timestamp when vesting should start ,after intial locking period is over
    uint256 public vestingShouldStartTimestamp;

    /// @notice helps keeps Timestamp record  for the upcoming slot
    uint256 public currentVestingSlotTimestamp;

    /// @notice Constructor to initialize the DugiToken contract
    /// @param _donationAddress Address for donation reserve Wallet
    /// @param _liquidityPairingAddress Address for liquidity pairing reserve Wallet
    /// @param _charityTeamAddress Address for charity team reserve Wallet
    /// @param _operationWallet Address for operation reserve Wallet
    /// @param _uniswapWalletAddress Address for uniswap reserve Wallet

    constructor(
        address _donationAddress,
        address _liquidityPairingAddress,
        address _charityTeamAddress,
        address _operationWallet,
        address _uniswapWalletAddress
    ) ERC20("DUGI Token", "DUGI") Ownable(0x1e364a3634289Bc315a6DFF4e5fD018B5C6B3ef6) {
        donationAddress = _donationAddress;
        liquidityPairingAddress = _liquidityPairingAddress;
        charityTeamAddress = _charityTeamAddress;
        operationWallet = _operationWallet;
        uniswapWalletAddress = _uniswapWalletAddress;

        _mint(donationAddress, donationReserve);
        _mint(liquidityPairingAddress, liquidityPairingReserve);
        _mint(address(this), charityTeamReserve);
        _mint(operationWallet, operationReserve);
        _mint(uniswapWalletAddress, uniswapReserve);
        _mint(address(this), burnReserve);

        chairityTeamLockedReserve = charityTeamReserve;
        burnLockedReserve = burnReserve;

        chairtyTeamTokenInitiallyLocked = true;

        lastBurnTimestamp = block.timestamp;
        vestingShouldStartTimestamp = block.timestamp + initialLockingPeriod;
        currentVestingSlotTimestamp = vestingShouldStartTimestamp;
    }

    /// @notice Modifier to restrict access to only the token burn admin
    modifier onlyTokenBurnAdmin() {
        require(msg.sender == tokenBurnAdmin, "Only tokenBurnAdmin allowed");
        _;
    }

    /// @notice Modifier to restrict access to only the charity/team token vesting admin

    modifier onlyCharityTeamVestingAdmin() {
        require(msg.sender == tokenCharityTeamVestingAdmin, "Only teamVestingAdmin allowed");
        _;
    }

    /// @notice Modifier to check if tokens can be burned

    modifier canBurn() {
        require(burnLockedReserve >= 0, "Burn reserve is empty");
        require(burnCounter <= totalburnSlot, "All slots have been burned");
        require(block.timestamp >= lastBurnTimestamp + 30 days, "30 days not passed yet");
        _;
    }

    /// @notice Modifier to unlock charity/team token reserve after the initial locking period over

    modifier unlockChairtyTeamToken() {
        require(block.timestamp >= vestingShouldStartTimestamp, "Initial locking period not over yet");

        _;
    }

    /// @notice Function to update the token burn admin
    /// @param _tokenBurnAdmin New address of the token burn admin

    function updateTokenBurnAdmin(address _tokenBurnAdmin) external onlyOwner {
        require(_tokenBurnAdmin != address(0), "zero addr not allowed");
        tokenBurnAdmin = _tokenBurnAdmin;
    }

    /// @notice Function to update the charity/team token vesting admin
    /// @param _tokenCharityTeamVestingAdmin New address of the charity/team token vesting admin

    function updateTokenCharityTeamVestingAdmin(address _tokenCharityTeamVestingAdmin) external onlyOwner {
        require(_tokenCharityTeamVestingAdmin != address(0), "zero addr not allowed");
        tokenCharityTeamVestingAdmin = _tokenCharityTeamVestingAdmin;
    }

    /// @notice Function to burn tokens at a rate of 0.0714% of total supply every 30 days until the burn reserve is empty

    function burnTokens() public onlyTokenBurnAdmin canBurn {
        uint256 burnAmount = (TOTAL_SUPPLY * 714) / 1_000_000;

        if (burnAmount < burnLockedReserve) {
            burnLockedReserve -= burnAmount;
            burnCounter++;
            _burn(address(this), burnAmount);
        } else {
            burnAmount = burnLockedReserve;
            burnLockedReserve = 0;
            burnCounter++;
            _burn(address(this), burnAmount);
        }

        lastBurnTimestamp = block.timestamp;

        if (burnCounter == 1) {
            burnStarted = true;
        } else if (burnCounter == totalburnSlot) {
            burnEnded = true;
        }
    }

    /// @notice Function to release charity/team tokens after the initial locking period of 24 months over in total of 8 slots . Every 3 months , 12.5% of charityTeamReserve will be released and transferred to charityTeamAddress

    function releaseTeamTokens() external onlyCharityTeamVestingAdmin unlockChairtyTeamToken {
        require(chairityTeamLockedReserve >= 0, "Charity team reserve is empty");
        require(currentReleasedSlot <= totalVestingSlots, "All slots have been released");
        require(block.timestamp >= currentVestingSlotTimestamp + vestingPeriod, "current cooling period not over");

        currentVestingSlotTimestamp = block.timestamp;

        uint256 amountToRelease = (charityTeamReserve * 125) / 1000; // 12.5% of  charityTeamReserve

        chairityTeamLockedReserve -= amountToRelease;
        currentReleasedSlot += 1;

        _transfer(address(this), charityTeamAddress, amountToRelease);

        if (chairtyTeamTokenInitiallyLocked) {
            chairtyTeamTokenInitiallyLocked = false;
        }
    }
}
