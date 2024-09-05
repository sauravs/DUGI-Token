// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/ERC20Burnable.sol";

/// @title DugiToken - ERC20 Token with specific token burning reserve and in built token vesting mechanism for charity/team reserve
/// @notice This contract implements an ERC20 token with specific reserves for donation, liquidity pairing, charity/tem, sushiwarp, and uniswap. It also includes mechanisms for token burning and vesting for team reserve.

contract DugiToken is ERC20, Ownable, ERC20Burnable {
    uint256 private constant TOTAL_SUPPLY = 21_000_000_000_000 * 10 ** 18; //// @notice Total supply of the token (21 trillion with 18 decimals)

    address public donationAddress;

    /// @notice Address for donation reserve
    address public liquidityPairingAddress;
    /// @notice Address for liquidity pairing reserve
    address public charityTeamAddress;
    /// @notice Address for charity team reserve
    address public sushiwarpAddress;
    /// @notice Address for sushiwarp reserve
    address public uniswapAddress;
    /// @notice Address for uniswap reserve

    uint256 public donationReserve = (TOTAL_SUPPLY * 5) / 100;

    /// @notice 5% of total supply reserved for donation
    uint256 public liquidityPairingReserve = (TOTAL_SUPPLY * 5) / 100;
    /// @notice 5% of total supply reserved for liquidity pairing
    uint256 public charityTeamReserve = (TOTAL_SUPPLY * 20) / 100;
    /// @notice 20% of total supply reserved for charity/team
    uint256 public sushiwarpReserve = (TOTAL_SUPPLY * 20) / 100;
    /// @notice 20% of total supply reserved for sushiwarp
    uint256 public uniswapReserve = (TOTAL_SUPPLY * 20) / 100;
    /// @notice 20% of total supply reserved for uniswap
    uint256 public burnReserve = (TOTAL_SUPPLY * 30) / 100;
    /// @notice 30% of total supply reserved for token burning

    uint256 public burnCounter;

    /// @notice Counter to track number of burn cycle performed, every month/burn it should get increased by 1

    uint256 public chairityTeamLockedReserve;

    /// @notice Locked reserve for charity team , helps tracking current charity team reserve
    uint256 public burnLockedReserve;
    /// @notice Locked reserve for  token burning, helps tracking current burn reserve

    uint256 public totalburnSlot = 421;

    /// @notice Total Number of slots/rounds for token burning (Number of months in 35 years)
    bool public burnStarted;
    /// @notice Indicates if burning has started
    bool public burnEnded;
    /// @notice Indicates if burning has ended

    bool public chairtyTeamTokenInitiallyLocked;

    /// @notice Indicates if charity team tokens are yet locked initially

    uint256 public lastBurnTimestamp;

    /// @notice Timestamp of the last token burn round

    address public tokenBurnAdmin = 0xcf04dA2562fcaC7A442AC828bAa1E75500534004;
    address public tokenCharityTeamVestingAdmin = 0x94ffc385b64E015EEb83F1f67E71F941ea9dd25B;

    /// @notice Address of the token burn admin

    uint256 public initialLockingPeriod = 24 * 30 days;

    /// @notice Initial locking period for charity team token reserve (24 months)

    uint256 public vestingPeriod = 3 * 30 days;

    /// @notice Vesting period for charity team tokens (Every 3 months after initial locking period is over)
    uint256 public totalVestingSlots = 8;
    /// @notice Number of vesting slots for charity team tokens (8 slots ,every three months ,will go on for 2 years)

    uint256 public currentReleasedSlot;

    /// @notice Current Slot number for charity team tokens
    uint256 public vestingShouldStartTimestamp;
    /// @notice Timestamp when vesting should start ,after intial locking period is over
    uint256 public currentVestingSlotTimestamp;
    /// @notice helps keeps Timestamp record  for the upcoming slot

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
    ) ERC20("DUGI Token", "DUGI") Ownable(0x3793f758a36c04B51a520a59520e4d845f94F9F2) {
        donationAddress = _donationAddress;
        liquidityPairingAddress = _liquidityPairingAddress;
        charityTeamAddress = _charityTeamAddress;
        sushiwarpAddress = _sushiwarpAddress;
        uniswapAddress = _uniswapAddress;

        _mint(donationAddress, donationReserve);
        _mint(liquidityPairingAddress, liquidityPairingReserve);
        _mint(address(this), charityTeamReserve);
        _mint(sushiwarpAddress, sushiwarpReserve);
        _mint(uniswapAddress, uniswapReserve);
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
        require(msg.sender == tokenCharityTeamVestingAdmin, "Only charityTeamVestingAdmin allowed");
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

    function updateTokenBurnAdmin(address _tokenBurnAdmin) public onlyOwner {
        tokenBurnAdmin = _tokenBurnAdmin;
    }


    /// @notice Function to update the charity/team token vesting admin
    /// @param _tokenCharityTeamVestingAdmin New address of the charity/team token vesting admin

    function updateTokenCharityTeamVestingAdmin(address _tokenCharityTeamVestingAdmin) public onlyOwner {
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
        require(
            block.timestamp >= currentVestingSlotTimestamp + vestingPeriod,
            "current Vesting slot not over yet for next release"
        );

        currentVestingSlotTimestamp = block.timestamp;

        uint256 amountToRelease = (charityTeamReserve * 125) / 1000; // 12.5% of  charityTeamReserve

        chairityTeamLockedReserve -= amountToRelease;
        currentReleasedSlot += 1;

        _transfer(address(this), charityTeamAddress, amountToRelease);

        if (chairtyTeamTokenInitiallyLocked == true) {
            chairtyTeamTokenInitiallyLocked = false;
        }
    }
}
