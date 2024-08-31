// // SPDX-License-Identifier: MIT
// pragma solidity ^0.8.0;

// import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
// import "@openzeppelin/contracts/token/ERC20/extensions/ERC20Burnable.sol";
// import "@openzeppelin/contracts/access/Ownable.sol";
// import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
// import "@openzeppelin/contracts/utils/math/SafeMath.sol";
// import "@openzeppelin/contracts/access/AccessControl.sol";
// import "@openzeppelin/contracts/security/Pausable.sol";
// import "@openzeppelin/contracts/security/TimelockController.sol";

// contract DugiToken is ERC20, ERC20Burnable, Ownable, ReentrancyGuard, Pausable, AccessControl {
//     using SafeMath for uint256;

//     bytes32 public constant MULTISIG_ROLE = keccak256("MULTISIG_ROLE");

//     // Tax settings
//     uint256 public buyTax = 25;
//     uint256 public sellTax = 25;
//     uint256 public transferTax = 80;

//     uint256 public constant BUY_TAX_THRESHOLD = 35;
//     uint256 public constant SELL_TAX_THRESHOLD = 25;

//     mapping(address => uint256) private _buyCount;
//     mapping(address => uint256) private _sellCount;

//     // Anti-bot measures
//     mapping(address => bool) public botBlacklist;
//     uint256 public constant MAX_SELLS_PER_BLOCK = 3;
//     mapping(address => uint256) public sellsPerBlock;

//     // Governance
//     struct Checkpoint {
//         uint32 fromBlock;
//         uint256 votes;
//     }
//     mapping(address => Checkpoint[]) public checkpoints;

//     event BotBlacklisted(address indexed bot);
//     event TaxUpdated(uint256 buyTax, uint256 sellTax, uint256 transferTax);

//     constructor() ERC20("DugiToken", "DUGI") {
//         _mint(msg.sender, 21000000000000 * 10 ** decimals());

//         // Grant the multisig role to the deployer initially
//         _setupRole(MULTISIG_ROLE, msg.sender);

//         // Grant the default admin role to the deployer initially
//         _setupRole(DEFAULT_ADMIN_ROLE, msg.sender);
//     }

//     modifier onlyMultisig() {
//         require(hasRole(MULTISIG_ROLE, msg.sender), "Caller is not a multisig wallet");
//         _;
//     }

//     // Emergency stop (Circuit Breaker)
//     function pause() external onlyMultisig {
//         _pause();
//     }

//     function unpause() external onlyMultisig {
//         _unpause();
//     }

//     // Bot protection
//     function blacklistBot(address bot) external onlyMultisig {
//         botBlacklist[bot] = true;
//         emit BotBlacklisted(bot);
//     }

//     // Override transfer to implement taxes and anti-bot measures
//     function _transfer(
//         address sender,
//         address recipient,
//         uint256 amount
//     ) internal override nonReentrant whenNotPaused {
//         require(!botBlacklist[sender], "Sender is blacklisted");

//         // Check for sell limits
//         if (block.number == sellsPerBlock[sender]) {
//             require(_sellCount[sender] < MAX_SELLS_PER_BLOCK, "Exceeds max sells per block");
//             _sellCount[sender]++;
//         } else {
//             sellsPerBlock[sender] = block.number;
//             _sellCount[sender] = 1;
//         }

//         uint256 fee = 0;

//         // Apply buy tax
//         if (_buyCount[recipient] < BUY_TAX_THRESHOLD) {
//             fee = amount.mul(buyTax).div(100);
//             _buyCount[recipient]++;
//         }

//         // Apply sell tax
//         if (_sellCount[sender] < SELL_TAX_THRESHOLD) {
//             fee = amount.mul(sellTax).div(100);
//             _sellCount[sender]++;
//         }

//         // Apply transfer tax
//         if (fee == 0) {
//             fee = amount.mul(transferTax).div(100);
//         }

//         uint256 amountAfterFee = amount.sub(fee);
//         super._transfer(sender, recipient, amountAfterFee);

//         // Send fee to tax wallet
//         if (fee > 0) {
//             super._transfer(sender, address(this), fee);
//         }

//         // Update checkpoints for governance
//         _writeCheckpoint(sender);
//         _writeCheckpoint(recipient);
//     }

//     function _writeCheckpoint(address account) internal {
//         uint256 currentVotes = balanceOf(account);
//         uint32 nCheckpoints = uint32(checkpoints[account].length);

//         if (nCheckpoints > 0 && checkpoints[account][nCheckpoints - 1].fromBlock == block.number) {
//             checkpoints[account][nCheckpoints - 1].votes = currentVotes;
//         } else {
//             checkpoints[account].push(Checkpoint(block.number, currentVotes));
//         }
//     }

//     // Time-locked function to update taxes
//     function updateTaxes(uint256 _buyTax, uint256 _sellTax, uint256 _transferTax) external onlyMultisig {
//         buyTax = _buyTax;
//         sellTax = _sellTax;
//         transferTax = _transferTax;
//         emit TaxUpdated(buyTax, sellTax, transferTax);
//     }

//     // Manual swap function for revenue
//     function swapTokensForMATIC(uint256 tokenAmount) external onlyMultisig nonReentrant {
//         require(tokenAmount > 0, "Token amount must be greater than 0");
//         require(balanceOf(address(this)) >= tokenAmount, "Insufficient balance");

//         // Swap tokens for MATIC logic (this will require a router interface to be defined)
//         // Add your swapping logic here

//         // Transfer MATIC to the tax wallet
//         payable(owner()).transfer(address(this).balance);
//     }
// }
