



//  certoraRun ./test/formal-verification/Certora/conf/FVDugiToken.conf








// Formal Verification of DugiToken contract

// 1. DugiToken is a standard ERC20 token with the following properties:
//    - totalSupply is a non-negative integer
//    - balanceOf is a mapping from addresses to non-negative integers
//    - allowance is a mapping from (owner, spender) pairs to non-negative integers
//    - transfer, transferFrom, approve, and increaseAllowance are functions that modify the state
//    - Transfer and Approval events are emitted
//    - The contract is Ownable
//    - The contract is Pausable
//    - The contract is Burnable
//    - The contract is Mintable
 
// 2. The contract is initialized with the following properties:
//    - totalSupply is 0
//    - balanceOf is empty
//    - allowance is empty
//    - owner is the deployer
//    - paused is false
//    - mintingFinished is false

// 3. The contract has the following functions:

//    - mint(address to, uint256 amount) public onlyOwner whenNotPaused returns (bool)
//      - Increases totalSupply by amount
//      - Increases balanceOf[to] by amount
//      - Emits Transfer event

//    - burn(uint256 amount) public whenNotPaused returns (bool)
//      - Decreases totalSupply by amount
//      - Decreases balanceOf[msg.sender] by amount
//      - Emits Transfer event
