pragma solidity ^0.4.18;

import "zeppelin-solidity/contracts/ownership/Ownable.sol";
import "zeppelin-solidity/contracts/token/ERC20/ERC20.sol";
import "zeppelin-solidity/contracts/math/SafeMath.sol";
import "./StakingInterface.sol";
import "./Lockable.sol";

contract Staking is StakingInterface, Lockable {

    using SafeMath for uint256;

    struct Checkpoint {
        uint256 at;
        uint256 amount;
    }

    ERC20 public token;

    Checkpoint[] public stakeHistory;

    mapping (address => Checkpoint[]) public stakesFor;

    function Staking(ERC20 _token) public {
        require(address(_token) != 0x0);
        token = _token;
    }

    function stake(uint256 amount, bytes data) public {
        stakeFor(msg.sender, amount, data);
    }

    function stakeFor(address user, uint256 amount, bytes data) public onlyWhenUnlocked {
        updateCheckpointAtNow(stakesFor[user], amount, false);
        updateCheckpointAtNow(stakeHistory, amount, false);

        require(token.transferFrom(msg.sender, address(this), amount));

        Staked(user, amount, totalStakedFor(user), data);
    }

    function unstake(uint256 amount, bytes data) public {
        require(totalStakedFor(msg.sender) >= amount);

        updateCheckpointAtNow(stakesFor[msg.sender], amount, true);
        updateCheckpointAtNow(stakeHistory, amount, true);

        require(token.transfer(msg.sender, amount));
        Unstaked(msg.sender, amount, totalStakedFor(msg.sender), data);
    }

    function totalStakedFor(address addr) public view returns (uint256) {
        Checkpoint[] storage stakes = stakesFor[addr];

        if (stakes.length == 0) {
            return 0;
        }

        return stakes[stakes.length-1].amount;
    }

    function totalStaked() public view returns (uint256) {
        return totalStakedAt(block.number);
    }

    function supportsHistory() public pure returns (bool) {
        return true;
    }
    
    function token() public view returns (address) {
        return token;
    }

    function lastStakedFor(address addr) public view returns (uint256) {
        Checkpoint[] storage stakes = stakesFor[addr];

        if (stakes.length == 0) {
            return 0;
        }

        return stakes[stakes.length-1].at;
    }

    function totalStakedForAt(address addr, uint256 blockNumber) public view returns (uint256) {
        return stakedAt(stakesFor[addr], blockNumber);
    }

    function totalStakedAt(uint256 blockNumber) public view returns (uint256) {
        return stakedAt(stakeHistory, blockNumber);
    }

    function updateCheckpointAtNow(Checkpoint[] storage history, uint256 amount, bool isUnstake) internal {

        uint256 length = history.length;
        if (length == 0) {
            history.push(Checkpoint({at: block.number, amount: amount}));
            return;
        }

        if (history[length-1].at < block.number) {
            history.push(Checkpoint({at: block.number, amount: history[length-1].amount}));
        }

        Checkpoint storage checkpoint = history[length];

        if (isUnstake) {
            checkpoint.amount = checkpoint.amount.sub(amount);
        } else {
            checkpoint.amount = checkpoint.amount.add(amount);
        }
    }

    function stakedAt(Checkpoint[] storage history, uint256 blockNumber) internal view returns (uint256) {
        uint256 length = history.length;

        if (length == 0 || blockNumber < history[0].at) {
            return 0;
        }

        if (blockNumber >= history[length-1].at) {
            return history[length-1].amount;
        }

        uint min = 0;
        uint max = length-1;
        while (max > min) {
            uint mid = (max + min + 1) / 2;
            if (history[mid].at <= blockNumber) {
                min = mid;
            } else {
                max = mid-1;
            }
        }

        return history[min].amount;
    }
}
