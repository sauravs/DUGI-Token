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