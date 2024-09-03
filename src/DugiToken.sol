// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/ERC20Burnable.sol";

/// @title DugiToken - ERC20 Token with specific reserves and locking mechanisms
/// @notice This contract implements an ERC20 token with specific reserves for donation, liquidity pairing, charity, sushiwarp, and uniswap. It also includes mechanisms for token burning and vesting.

contract DugiToken is ERC20, Ownable ,ERC20Burnable {
    
    uint256 private constant TOTAL_SUPPLY = 21_000_000_000_000 * 10 ** 18; //// @notice Total supply of the token (21 trillion with 18 decimals)
  
    
    address public donationAddress;               /// @notice Address for donation reserve
    address public liquidityPairingAddress;       /// @notice Address for liquidity pairing reserve
    address public charityTeamAddress;           /// @notice Address for charity team reserve
    address public sushiwarpAddress;             /// @notice Address for sushiwarp reserve
    address public uniswapAddress;               /// @notice Address for uniswap reserve
   

    uint256 public donationReserve = (TOTAL_SUPPLY * 5) / 100; /// @notice 5% of total supply reserved for donation
    uint256 public liquidityPairingReserve = (TOTAL_SUPPLY * 5) / 100;  /// @notice 5% of total supply reserved for liquidity pairing
    uint256 public charityTeamReserve = (TOTAL_SUPPLY * 20) / 100; /// @notice 20% of total supply reserved for charity/team
    uint256 public sushiwarpReserve = (TOTAL_SUPPLY * 20) / 100;    /// @notice 20% of total supply reserved for sushiwarp
    uint256 public uniswapReserve = (TOTAL_SUPPLY * 20) / 100;  /// @notice 20% of total supply reserved for uniswap
    uint256 public burnReserve = (TOTAL_SUPPLY * 30) / 100;  /// @notice 30% of total supply reserved for burning
    
    uint256 public burnCounter;  /// @notice Counter for the number of burns performed, every month it should get increased by 1
    

    uint256 public chairityTeamLockedReserve;   /// @notice Locked reserve for charity team
    uint256 public burnLockedReserve;     /// @notice Locked reserve for  token burning


    uint256 public totalburnSlot = 8;   /// @notice Number of slots/rounds for token burning
    bool public burnStarted;               /// @notice Indicates if burning has started
    bool public burnEnded;                 /// @notice Indicates if burning has ended
    
    bool public chairtyTeamTokenInitiallyLocked;        /// @notice Indicates if charity team tokens are initially locked
    bool public chairtyTeamTokenLockedForNextRelease;    /// @notice Indicates if charity team tokens are locked for the next release

    uint256 public lastBurnTimestamp;                     /// @notice Timestamp of the last burn

    address public tokenBurnAdmin = 0x3793f758a36c04B51a520a59520e4d845f94F9F2;     /// @notice Address of the token burn admin

    uint256 public initialLockingPeriod = 24 * 30 days;     /// @notice Initial locking period for charity team tokens (24 months)

    uint256 public vestingPeriod = 3 * 30 days;  /// @notice Vesting period for charity team tokens (3 months)
    uint256 public totalVestingSlots = 8;   /// @notice Number of vesting slots for charity team tokens (8 slots)
    uint256 public currentReleasedSlot;          /// @notice Number of released slots for charity team tokens
    uint256 public tokensPerSlot;              /// @notice Number of tokens per vesting slot
    uint256 public vestingShouldStartTimestamp;  /// @notice Timestamp when vesting should start
    uint256 public vestingSlotTimestamp;          /// @notice Timestamp for the next vesting slot
    uint256 public currentVestingSlotTimestamp ;  /// @notice Timestamp for the current vesting slot

    /// @notice Constructor to initialize the DugiToken contract
    /// @param _donationAddress Address for donation reserve
    /// @param _liquidityPairingAddress Address for liquidity pairing reserve
    /// @param _charityTeamAddress Address for charity team reserve
    /// @param _sushiwarpAddress Address for sushiwarp reserve
    /// @param _uniswapAddress Address for uniswap reserve

    constructor(
        address _donationAddress,
        address _liquidityPairingAddress,
        address _charityTeamAddress,
        address _sushiwarpAddress,
        address _uniswapAddress
    ) ERC20("DUGI Token", "DUGI") Ownable(0x7cC26960D2A47c659A8DBeCEb0937148b0026fD6) {
        donationAddress = _donationAddress;
        liquidityPairingAddress = _liquidityPairingAddress;
        charityTeamAddress = _charityTeamAddress;
        sushiwarpAddress = _sushiwarpAddress;
        uniswapAddress = _uniswapAddress;
        chairtyTeamTokenInitiallyLocked = true;
        chairtyTeamTokenLockedForNextRelease = true;

        _mint(donationAddress, donationReserve);
        _mint(liquidityPairingAddress, liquidityPairingReserve);
        _mint(address(this), charityTeamReserve);
        _mint(sushiwarpAddress, sushiwarpReserve);
        _mint(uniswapAddress, uniswapReserve);
        _mint(address(this), burnReserve);

        chairityTeamLockedReserve = charityTeamReserve;
        burnLockedReserve = burnReserve;
        lastBurnTimestamp = block.timestamp;
        vestingShouldStartTimestamp = block.timestamp + initialLockingPeriod;
        currentVestingSlotTimestamp = vestingShouldStartTimestamp;
    }

    /// @notice Modifier to restrict access to only the token burn admin
    modifier onlyTokenBurnAdmin() {
        require(msg.sender == tokenBurnAdmin, "Only tokenBurnAdmin can call this function");
        _;
    }

        /// @notice Modifier to check if tokens can be burned

    modifier canBurn() {
        require(burnLockedReserve >= 0, "Burn reserve is empty");
        require( burnCounter <= totalburnSlot, "All slots have been burned");
        require(block.timestamp >= lastBurnTimestamp + 30 days, "30 days have not passed since last burn");
        _;
    }

    /// @notice Modifier to unlock charity/team token reserve after the initial locking period over

    modifier unlockChairtyTeamToken() {
    
        require(block.timestamp >= vestingShouldStartTimestamp, "Initial locking period not over yet");

        _;
    }

    

    /// @notice Function to update the token burn admin
    /// @param _tokenBurnAdmin New address of the token burn admin

    function updateTokenBurnAdmin(address _tokenBurnAdmin) public onlyOwner {
        tokenBurnAdmin = _tokenBurnAdmin;
    }

     /// @notice Function to burn tokens at a rate of 0.0714% of total supply every 30 days until the burn reserve is empty

    function burnTokens() public onlyTokenBurnAdmin canBurn {
    uint256 burnAmount = (TOTAL_SUPPLY * 714) / 1_000_000;   
    _burn(address(this), burnAmount); 

    burnLockedReserve -= burnAmount;
    burnCounter++;
    lastBurnTimestamp = block.timestamp;

    if (burnCounter == 1) {
        burnStarted = true;
    } else if (burnCounter == totalburnSlot) {
        burnEnded = true;
    }
}

        /// @notice Function to release charity/team tokens after the initial locking period of 24 months over in total of 8 slots . Every 3 months , 12.5% of charityTeamReserve will be released and transferred to charityTeamAddress

    function releaseTokens() external onlyOwner unlockChairtyTeamToken {

        require(chairityTeamLockedReserve >= 0, "Charity team reserve is empty");
        require(currentReleasedSlot <= totalVestingSlots, "All slots have been released");
        require(block.timestamp >= currentVestingSlotTimestamp + vestingPeriod ,"current Vesting slot not over yet for next release");

         currentVestingSlotTimestamp = block.timestamp ;
        
       
        uint256 amountToRelease = (charityTeamReserve * 125) / 1000;     // 12.5% of  charityTeamReserve
        _transfer(address(this), charityTeamAddress, amountToRelease);

        chairityTeamLockedReserve -= amountToRelease;
        currentReleasedSlot += 1;

        if (chairtyTeamTokenInitiallyLocked == true) {
            chairtyTeamTokenInitiallyLocked = false;
        }
        //chairtyTeamTokenLockedForNextRelease = false;
    }
}
