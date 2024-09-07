
@Edoda_Yona 

Correct me if my understanding is wrong.

Dugi Primary Wallet:
0x1e364a3634289Bc315a6DFF4e5fD018B5C6B3ef6     (Christian HOLDING)  done

 This will be the owner of the contract .
 No funds will be in it.This wallet address will be the owner of the contract which will have the rights to update Dugi burn wallet and Vesting Wallet Admins.



Dugi burn wallet:
0xa5570A1B859401D53FB66f4aa1e250867803a408     (Dedicated for BURN Token Wallet)  done

This will be the wallet which will have authority to burn the token.



Dugi wallet 5:
0x50cfaA96bbb8dA3066adBeaBA4d239eEC4578CDF     (Vesting Wallet @hashTheBlocks)   done

This will be the wallet which will have the authority to release vested token.


Dugi wallet 1:
0x4921B6a8Ce3eF0c443518F964f9D06763823601E     (Donation Wallet)   done

This will be donation wallet where Donation Reserve is allocated which will be 5% of total supply (according to your requirement doc)


Dugi wallet 6: 
0x7620B333a87102A053DBd483D57D826a3155710c     (Liquidity wallet 2 USDT)   done 


This will be wallet where uniswap liquidity reserve will be sent which will be 20% of total supply (according to your requirement doc)


Dugi wallet 7:

0x5D3f8a0E1d2C47D186CDf63F68bC31A5e3777194     (Liquidity wallet 1 MATIC)     eliminated

This will be wallet where sushiswap liquidity reserve will be sent which will be 20% of total supply (according to your requirement doc)



Dugi wallet 4:
0xB11CDf0236b8360c17D1886fEB12400E93b3E88A     (Operation Wallet)   20% of total supply,earlier which was allocated for sushiswap,now will be operation wallet


------------------------------------------------------------------------------------------------------------------------------

Now for the following wallet segments I have confusion:



Dugi wallet 2:
0x2fb656a60705d0D25de0A34f0b6ee0f110971A49     (Marketing Wallet)   // this is now charityTeamAddress

Dugi wallet 3:
0x2EB4c5f243BF7F74A57F983E1bD5CF67f469c0Df     (Security & Audit)   // this is now  liquidityPairingAddress



According to your requirement doc , their is no mention of "Marketing Wallet" , "Security & Audit" and "Operation Wallet" segment/allocation.


Their is mention of  "Pairing Liquidity" and "Chairty/Team" allocation ,where "Pairing Liquidity" wallet got allocated 5% of total supply ,
and  "Chairty/Team" wallet got allocated 20% of total supply. Here "Chairty/Team" wallet is that wallet where tokens after vesting period is over being sent.

So, this is how current fund allocation is being setup according to requirement doc:

1) Donation Wallet: 5% of total supply
2) Pairing Liquidity Wallet: 5% of total supply
3) Chairty/Team Wallet: 20% of total supply
4) Sushiswap Liquidity Wallet: 20% of total supply
5) Uniswap Liquidity Wallet: 20% of total supply
6) Burn Reserve Inside the smart contract: 30% of total supply


Let me know about "Marketing Wallet" , "Security & Audit" and "Operation Wallet" segment/allocation.
Do you want to update the token allocation ?



///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
  
   DugiToken After Contract Deployment Token Allocation and Wallet Address Details:

1) Fund Reserve For Donation (donationReserve): 5% of total supply
   Hold by Wallet Address: donationAddress -> 0x4921B6a8Ce3eF0c443518F964f9D06763823601E

2) Fund Reserve For Providing Liquidity to Uniswap (uniswapReserve) : 20% of total supply
   Hold by Wallet Address: uniswapWalletAddress -> 0x7620B333a87102A053DBd483D57D826a3155710c


3) Fund Reserve For Operation Wallet (operationReserve) : 20% of total supply
   Hold by Wallet Address: operationWallet -> 0xB11CDf0236b8360c17D1886fEB12400E93b3E88A

4) Fund Reserve For Charity/Team (charityTeamReserve): 20% of total supply
   Hold by Wallet Address(after vesting cycle complete): charityTeamAddress -> 0x2fb656a60705d0D25de0A34f0b6ee0f110971A49

5) Fund Reserved to ensure sufficient liquidity for smooth trading (liquidityPairingReserve): 5% of total supply
   Hold by Wallet Address(after vesting cycle complete): liquidityPairingAddress  -> 0x2EB4c5f243BF7F74A57F983E1bD5CF67f469c0Df

6) Fund Reserved for Token Burning (burnReserve) : 30% of total supply
   Hold by : Dugi Token Contract

7) Dugi Token Contract Owner : 0x1e364a3634289Bc315a6DFF4e5fD018B5C6B3ef6
   
8) DugiTokenBurn Admin Wallet (tokenBurnAdmin) : 0xa5570A1B859401D53FB66f4aa1e250867803a408

9) DugiTokenVesting Admin Wallet(tokenCharityTeamVestingAdmin) : 0x50cfaA96bbb8dA3066adBeaBA4d239eEC4578CDF


