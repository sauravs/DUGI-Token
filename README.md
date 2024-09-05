## DugiToken : An ERC20 Compliant Token

**DugiToken - ERC20 Token with specific token burning reserve and in built token vesting mechanism for charity/team reserve**

Important Details about this token:

-   **Total Maximum Supply**:  21 Trillion
-   **Token Name**: Dugi Token
-   **Token Symbol**: DUGI
-   **Token Decimals**: 18
-   **Burning Mechanism**: YES
-   **Vesting Mechanism**: YES


## Burning Details

- Every 30 days approximately 0.0714% of total token supply (15 billion token per month) will be auto burn from BurnToken Reserve for next 35 years till BurnToken reserve reaches to zero or near zero




## Vesting Details

- **Chairity/ Team Allocation Fund** : 20% of Total Maximum Supply (21 Trillion)
- **Initial Locking Period** : 24 Months (Time for which token is locked)
- **Token Releasing Slots**: 8 (Total Number of rounds in which tokens will be released to Team/Charity Wallet)
- **Token Slot Amount** : 12.5% of (Chairity/ Team Allocation Fund)
-  **Slot Period** : 3 Months (Every vesting round needs to be cooling period of 3 months)



### To run Tests

```shell
$ clone the repo
$ install foundry
$ forge build
$ forge test
```


### Deploy

```shell
$ forge script script/DeployDugiToken.s.sol:DeployDugiToken --rpc-url $POLYGON_AMOY_RPC_URL
$ forge script script/DeployDugiToken.s.sol:DeployDugiToken --rpc-url $POLYGON_AMOY_RPC_URL --broadcast --verify -vvvv
```

  ### To verify deployed contract:
     ```
	  $ forge verify-contract <contract_address> <contract_name> --chain-id <80002> --etherscan-api-key $<AMOY_POLYGONSCAN_KEY> --constructor-args <ABI_ENCODED_CONSTRUCTOR_ARGS> --watch
    ```
