pragma solidity ^0.4.4;

import 'zeppelin-solidity/contracts/ownership/Ownable.sol';
import 'zeppelin-solidity/contracts/math/SafeMath.sol';
import 'zeppelin-solidity/contracts/token/ERC20/ERC20.sol';

contract Sale is Ownable {
  using SafeMath for uint256;
    uint rate = 1;
    uint mincap = 0;
    address tokenAddr;
    bool isActive = false;
    bool onlyWhitelist = false;

    mapping(address => uint) balance;
    mapping(address => uint) balanceWithdrawn;
    address[] investors;
    mapping(address => bool) whitelist;


    function Sale() public{
    }

    function() payable public{ 
      require(isActive);
      require(tokenAddr != address(0));
      require(msg.sender != address(0));
      require(msg.value >=  mincap );
      require(!onlyWhitelist || whitelist[msg.sender]);
      uint256 amt = msg.value.mul(rate);

      ERC20 token = ERC20(tokenAddr);
      require(token.balanceOf(this) >= amt);
      
      if(balance[msg.sender] == 0){
        investors.push(msg.sender);
      }
      balance[msg.sender] += amt;
    }
    function getRate() public view returns(uint){
        return rate;
    }
    function getCap() public view returns(uint){
        return mincap;
    }
    function getBalance() public view returns(uint256){
      ERC20 token = ERC20(tokenAddr);
      return token.balanceOf(this);
    }
    function changeRate(uint _rate) public onlyOwner{
      rate = _rate;
    }
    function changemincap(uint _mincap) public onlyOwner{
      mincap = _mincap;
    }
    function changeAddr(address _tokenAddr) public onlyOwner{
      tokenAddr = _tokenAddr;
    }
    function addWhitelist(address[] addr_list) public onlyOwner{
      for(uint i=0;i<addr_list.length;i++){
        whitelist[addr_list[i]] = true;
      }
    }
    function setActive() public onlyOwner{
        isActive = !isActive;
    }
    function setActiveWhitelist() public onlyOwner{
        onlyWhitelist = !onlyWhitelist;
    }
    function drainWei() public onlyOwner{
        owner.transfer(this.balance);
    }    
    function drainToken() public onlyOwner{
        uint cantWithdrawAmt = 0;
        for(uint i = 0;i<investors.length;i++){
          cantWithdrawAmt += balance[investors[i]];
        }      
        ERC20 token = ERC20(tokenAddr);
        token.transfer(msg.sender, (token.balanceOf(this)).sub(cantWithdrawAmt) );
    }
    function giveTokens(uint percent) public onlyOwner{
        ERC20 token = ERC20(tokenAddr);
        for(uint i = 0;i<investors.length;i++){
          uint bal = balance[investors[i]];
          uint canWithdrawAmt = (bal.div(100)).mul(percent);
          if(canWithdrawAmt > 0 && balanceWithdrawn[investors[i]] + canWithdrawAmt <= bal){
            balanceWithdrawn[investors[i]] += canWithdrawAmt;
            token.transfer(investors[i], canWithdrawAmt);
          }
        }      
    }        
}