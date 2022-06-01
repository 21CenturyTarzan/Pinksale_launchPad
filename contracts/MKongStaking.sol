// SPDX-License-Identifier: MIT

pragma solidity 0.8.4;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "@openzeppelin/contracts/utils/Address.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
// import "hardhat/console.sol";


contract MKongStaking is Ownable, ReentrancyGuard {
  using SafeMath for uint256;
  using SafeERC20 for IERC20;

  struct UserInfo {
    uint256 stakedAmount;     // How many MKONG tokens the user has provided.
    uint256 rewardDebt;       // number of reward token user will get got. it is cleared when user stake or unstake token.
    uint256 lastDepositTime;  // time when user deposited
    uint256 unstakeStartTime; // time when when user clicked unstake btn.
    uint256 pendingAmount;    // # of tokens that is pending of 14 days.
  }

  event TokenStaked(address user, uint256 amount);
  event TokenWithdraw(address user, uint256 amount);
  event ClaimToken(address user, uint256 receiveAmount);
  event RewardRateSet(uint256 value);
  event RewardReceived(address receiver, uint256 rewardAmount);

  address public mkongToken;
  mapping (address => UserInfo) public userInfos;

  uint256 public totalStakedAmount;
  uint256 public rewardRate;
  uint256 public UNSTAKE_TIMEOFF = 7 days;

  constructor(address _token) {
    require(_token != address(0), "Zero address: Token");
    mkongToken = _token;
    totalStakedAmount = 0;
    rewardRate = 18; // User will get 30% reward after lockup time.
  }
  
  function setRewardRate(uint256 _newRate) public onlyOwner {
    require(_newRate != 0, "rate should be over 1");
    rewardRate = _newRate;
    emit RewardRateSet(_newRate);
  }

  function stakeToken(uint256 _amount) external nonReentrant updateReward(msg.sender) {

    require(_amount > 0, "invalid deposit amount");

    userInfos[msg.sender].stakedAmount = userInfos[msg.sender].stakedAmount.add(_amount);
    userInfos[msg.sender].lastDepositTime = block.timestamp;
    IERC20(mkongToken).safeTransferFrom(msg.sender, address(this), _amount);
    totalStakedAmount = totalStakedAmount.add(_amount);
    emit TokenStaked(msg.sender, _amount);
  }

  /**
  7 days Timer will start
  **/
  function unstakeToken(uint256 _amount, bool isEmergency) external nonReentrant updateReward(msg.sender) {
    require(_amount > 0, "invalid deposit amount");
    require( userInfos[msg.sender].stakedAmount >= _amount, "unstake amount is bigger than you staked" );

    uint256 outAmount = _amount + userInfos[msg.sender].rewardDebt;
    
    if ( isEmergency == true) {
      outAmount = outAmount.mul(95).div(100);
    }
    
    userInfos[msg.sender].stakedAmount = userInfos[msg.sender].stakedAmount.sub(_amount);
    userInfos[msg.sender].rewardDebt = 0;
    userInfos[msg.sender].lastDepositTime = block.timestamp;

    if ( isEmergency == true) {
        // send token to msg.sender.
        IERC20(mkongToken).safeTransfer(msg.sender, outAmount);
        emit ClaimToken(msg.sender, outAmount);
        return;
    }

    userInfos[msg.sender].unstakeStartTime = block.timestamp;
    userInfos[msg.sender].pendingAmount = userInfos[msg.sender].pendingAmount + outAmount;

    emit TokenWithdraw(msg.sender, outAmount);
  }
  
  // this function will be called after 7 days. actual token transfer happens here.
  function claim() external nonReentrant {
        
    require((block.timestamp - userInfos[msg.sender].unstakeStartTime) >= UNSTAKE_TIMEOFF, "invalid time: must be greater than 14 days");
    uint256 receiveAmount = userInfos[msg.sender].pendingAmount;
    require( receiveAmount > 0, "no available amount" );
    require(IERC20(mkongToken).balanceOf(address(this)) >= receiveAmount, "staking contract has not enough mkong token");

    IERC20(mkongToken).safeTransfer(msg.sender, receiveAmount);
    totalStakedAmount = IERC20(mkongToken).balanceOf(address(this)).sub(receiveAmount);
    userInfos[msg.sender].pendingAmount = 0;
    userInfos[msg.sender].unstakeStartTime = block.timestamp;
    
    emit ClaimToken(msg.sender, receiveAmount);
  }

  function isClaimable(address user) external view returns (bool){
      if (userInfos[user].unstakeStartTime == 0)
        return false;
        
      return (block.timestamp - userInfos[user].unstakeStartTime  > UNSTAKE_TIMEOFF)? true : false;
  }

  function timeDiffForClaim(address user) external view returns (uint256) {
      return (userInfos[user].unstakeStartTime + UNSTAKE_TIMEOFF > block.timestamp) ? userInfos[user].unstakeStartTime + UNSTAKE_TIMEOFF - block.timestamp : 0 ;
  }

  function setUnstakeTimeoff(uint256 time_) external onlyOwner {
      UNSTAKE_TIMEOFF = time_;
  }

  function calcReward(address account) public view returns (uint256) {
    uint256 rewardVal = (block.timestamp - userInfos[account].lastDepositTime).mul(userInfos[account].stakedAmount).mul(rewardRate).div(365 days);
    return rewardVal.div(100).add(userInfos[account].rewardDebt);
  }

  modifier updateReward(address account) {
      if (account != address(0)) {
        if (userInfos[account].lastDepositTime == 0) {
          userInfos[account].lastDepositTime = block.timestamp;
          userInfos[account].rewardDebt = 0;
        }else {
          userInfos[account].rewardDebt = calcReward(account);  
        }
      }
      _;
  }
}