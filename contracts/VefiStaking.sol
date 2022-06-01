// SPDX-License-Identifier: MIT

pragma solidity 0.8.4;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "@openzeppelin/contracts/utils/Address.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";


contract VefiStaking is Ownable, ReentrancyGuard {
  using SafeMath for uint256;
  using SafeERC20 for IERC20;

  struct UserInfo {
    uint256 stakedAmount;     // How many Vefi tokens the user has provided.
    uint256 rewardDebt;       // number of reward token user will get got. it is cleared when user stake or unstake token.
    uint256 timeLeft;         // left time until lockup finish
    uint256 lastDepositTime;  // when user deposited
    uint256 unstakeStartTime; // when user clicked unstake btn.
    uint256 pendingAmount;    // # of tokens that is pending of 14 days.
  }

  event TokenStaked(address user, uint256 amount);
  event TokenWithdraw(address user, uint256 amount);
  event ClaimToken(address user, uint256 receiveAmount);
  event RewardRateSet(uint256 value);
  event RewardReceived(address receiver, uint256 rewardAmount);

  address public vefiToken;
  mapping (address => UserInfo) public userInfos;

  uint256 public lockupTime = 180 days;
  uint256 public totalSupply;
  uint256 public rewardRate;

  constructor(address _token) {
    require(_token != address(0), "Zero address: Token");
    vefiToken = _token;
    totalSupply = 0;
    rewardRate = 30; // User will get 30% reward after lockup time.
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
    IERC20(vefiToken).safeTransferFrom(msg.sender, address(this), _amount);
    totalSupply = totalSupply.add(_amount);
    emit TokenStaked(msg.sender, _amount);
  }

  /**
  14 days Timer will start
  **/
  function unstakeToken(uint256 _amount) external nonReentrant updateReward(msg.sender) {
    require(_amount > 0, "invalid deposit amount");
    require( userInfos[msg.sender].stakedAmount >= _amount, "unstake amount is bigger than you staked" );

    uint256 availableAmount = _amount + userInfos[msg.sender].rewardDebt;
    
    uint256 timeDiff = block.timestamp.sub(userInfos[msg.sender].lastDepositTime);
    if(timeDiff < 180 days){
      availableAmount = availableAmount.mul(70).div(100);
    }
    
    userInfos[msg.sender].stakedAmount = userInfos[msg.sender].stakedAmount.sub(_amount);
    userInfos[msg.sender].rewardDebt = 0;
    userInfos[msg.sender].lastDepositTime = block.timestamp;

    userInfos[msg.sender].unstakeStartTime = block.timestamp;
    userInfos[msg.sender].pendingAmount = userInfos[msg.sender].pendingAmount + availableAmount;

    emit TokenWithdraw(msg.sender, _amount);
  }
  
  // this function will be called after 14 days. actual token transfer happens here.
  function claim() external nonReentrant {
        
    require((block.timestamp - userInfos[msg.sender].unstakeStartTime) >= 14 days, "invalid time: must be greater than 14 days");
    uint256 receiveAmount = userInfos[msg.sender].pendingAmount;
    require( receiveAmount > 0, "no available amount" );
    require(IERC20(vefiToken).balanceOf(address(this)) >= receiveAmount, "staking contract has not enough vefi token");

    IERC20(vefiToken).safeTransfer(msg.sender, receiveAmount);
    totalSupply = totalSupply.sub(receiveAmount);
    userInfos[msg.sender].pendingAmount = 0;
    userInfos[msg.sender].unstakeStartTime = 0;
    
    emit ClaimToken(msg.sender, receiveAmount);
  }


  // function getReward(address user) internal {

  //   require(user != address(0), "invalid caller");
  //   uint256 rewardAmount = userInfos[msg.sender].rewardDebt;
  //   require(IERC20(vefiToken).balanceOf(address(this)) >= rewardAmount, "staking contract has not enough vefi token");
  //   if (rewardAmount != 0) {
  //     IERC20(vefiToken).transfer(msg.sender, rewardAmount);
  //     totalSupply = totalSupply.sub(rewardAmount);
  //     emit RewardReceived(msg.sender, rewardAmount);
  //   }
  // }

  function calcReward(address account) public view returns (uint256) {
    uint256 rewardVal = (block.timestamp - userInfos[account].lastDepositTime).mul(userInfos[account].stakedAmount).mul(rewardRate).div(180 days);
    return rewardVal.div(100).add(userInfos[account].rewardDebt);
  }

  modifier updateReward(address account) {
      if (account != address(0)) {
        if (userInfos[account].lastDepositTime == 0) {
            userInfos[account].lastDepositTime = block.timestamp;
        }
        
        userInfos[account].rewardDebt = calcReward(account);
      }
      _;
  }
}