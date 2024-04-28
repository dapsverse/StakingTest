// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {IERC20} from "@openzeppelin/contracts/interfaces/IERC20.sol";
import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";

contract Staking is Ownable {
    uint256 public rewardLimit = 10_000_000 ether;
    uint256 public claimedToken;
    IERC20 public activeToken;
    uint256 public rewardPerDay = 1000 ether;
    mapping(address => uint256) public userStaked;
    mapping(address => uint256) public userCurentStakeTime;
    mapping(address => uint256) public userRewards;

    constructor() Ownable(msg.sender) {}

    event Staked(address staker, uint256 amount);
    event Unstaked(address staker, uint256 remainingToken);

    function setupActiveToken(address tokenAddress) public onlyOwner {
        require(activeToken == IERC20(address(0)), "already set active token");
        activeToken = IERC20(tokenAddress);
        activeToken.transferFrom(msg.sender, address(this), rewardLimit);
    }

    function rewardAmountRemaining() public view returns (uint256) {
        return rewardLimit - claimedToken;
    }

    function rewardPerSecond() private view returns (uint256) {
        return rewardPerDay / 1 days;
    }

    function totalRewards(uint256 stakeTime) private view returns (uint256) {
        return (block.timestamp - stakeTime) * rewardPerSecond();
    }

    function rewards() public view returns (uint256) {
        uint256 tempReward = userRewards[msg.sender];
        uint256 currentStakeTime = userCurentStakeTime[msg.sender];
        return
            tempReward +
            ((currentStakeTime > 0) ? totalRewards(currentStakeTime) : 0);
    }

    function staking(uint256 amount) public {
        require(activeToken != IERC20(address(0)), "token not set");
        require(amount > 0, "Amount = 0");
        activeToken.transferFrom(msg.sender, address(this), amount);

        uint256 currentStake = userStaked[msg.sender];
        userStaked[msg.sender] = currentStake + amount;
        userRewards[msg.sender] += rewards();
        userCurentStakeTime[msg.sender] = block.timestamp;

        emit Staked(msg.sender, amount);
    }

    function claim() public {
        require(activeToken != IERC20(address(0)), "token not set");
        require(rewards() > 0, "rewards = 0");
        require(claimedToken + rewards() <= rewardLimit, "exceed limit");

        activeToken.transfer(msg.sender, rewards());

        claimedToken += rewards();
        userCurentStakeTime[msg.sender] = block.timestamp;
        userRewards[msg.sender] = 0;
    }

    function unstaking(uint256 amount) public {
        require(activeToken != IERC20(address(0)), "token not set");
        require(amount > 0, "Amount = 0");
        require(userStaked[msg.sender] >= amount, "exceed staked amount");

        activeToken.transfer(msg.sender, amount);
        userRewards[msg.sender] += rewards();
        userStaked[msg.sender] = userStaked[msg.sender] - amount;
        userCurentStakeTime[msg.sender] = userStaked[msg.sender] > 0
            ? block.timestamp
            : 0;

        emit Unstaked(msg.sender, userStaked[msg.sender]);
    }
}
