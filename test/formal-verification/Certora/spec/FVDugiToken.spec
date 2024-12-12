


//  lets do formal verfication for:
   
 //  after contract is deployed, totalSupply should never be zero in any global scenarios

    
    //Rule: do x,y and z and prove -> a (totalSupply != 0)
    //Invariant: totalSupply != 0



methods {
  function totalSupply(uint128) external returns uint256 envfree;
}



    rule totalSupplyShouldNeverBeZero {

       // code -> math

       assert(true);

    }


// rule hellFuncMustNeverRevert(uint128 number) {
//   require(currentContract.numbr == 10);
//   require(currentContract.namber == 3);
//   require(currentContract.nunber == 5);
//   require(currentContract.mumber == 7);
//   require(currentContract.numbor == 2);
//   require(currentContract.numbir == 10);
//   // env e;
//   // require(e.msg.value == 0);

//   hellFunc@withrevert(number);
//   assert(lastReverted == false);
// }








        

      

