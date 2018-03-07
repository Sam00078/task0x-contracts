pragma solidity ^0.4.4;

import 'zeppelin-solidity/contracts/token/ERC20/MintableToken.sol';
import 'zeppelin-solidity/contracts/token/ERC20/BurnableToken.sol';

//example token
contract Token is MintableToken, BurnableToken {
  string public name = "TX";
  string public symbol = "TX";
  uint256 public decimals = 18;
  uint256 public constant INITIAL_SUPPLY = 100000000e18;
  event TokenCreated(bool t);

  function Token() public {
       totalSupply_ = INITIAL_SUPPLY;
       balances[msg.sender] = INITIAL_SUPPLY;
       Transfer(0x0, msg.sender, INITIAL_SUPPLY);
       TokenCreated(true);
  }
}
