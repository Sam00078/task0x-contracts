pragma solidity ^0.4.18;

import "./Staking.sol";

contract TokenReturningStaking is Staking {

    ERC20 public returnToken;

    uint256 public rate;


    function TokenReturningStaking(ERC20 _token, ERC20 _returnToken, uint256 _rate) Staking(_token) public {
        require(address(_returnToken) != 0x0);
        require(_token != _returnToken);
        require(_rate > 0);

        returnToken = _returnToken;
        rate = _rate;
    }


    function stakeFor(address user, uint256 amount, bytes data) public {
        super.stakeFor(user, amount, data);
        require(returnToken.transfer(user, amount.mul(getRate())));
    }


    function unstake(uint256 amount, bytes data) public {
        super.unstake(amount, data);

        uint256 returnAmount = amount.div(getRate());
        require(returnAmount.mul(getRate()) == amount);

        require(returnToken.transferFrom(msg.sender, address(this), returnAmount));
    }

    function getRate() public view returns (uint256) {
        return rate;
    }
}
