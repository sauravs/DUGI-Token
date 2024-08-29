
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

        _mint(donationAddress, (TOTAL_SUPPLY * 5) / 100); // 5% for Donation
        _mint(liquidityPairingAddress, (TOTAL_SUPPLY * 5) / 100); // 5% for Pairing Liquidity
        _mint(charityTeamAddress, (TOTAL_SUPPLY * 20) / 100); // 20% for Charity/Team
        _mint(sushiwarpAddress, (TOTAL_SUPPLY * 20) / 100); // 20% for Sushiwarp
        _mint(uniswapAddress, (TOTAL_SUPPLY * 20) / 100); // 20% for Uniswap
        _mint(address(this), (TOTAL_SUPPLY * 30) / 100); // 30% for Burn Reserve held by the contract itself
    }


    // Function to initiate burning process of tokens from the burn reserve by the owner 
    // where burning rate is 0.0714% monthly and it should auto burn once owner initiate 
    //the process

    function initiateTokenBurning() public onlyOwner {
        uint256 burnAmount = (balanceOf(address(this)) * 714) / 1_000_000;
        _burn(address(this), burnAmount);
    }






}































