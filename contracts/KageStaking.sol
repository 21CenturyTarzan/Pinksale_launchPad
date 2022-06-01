// SPDX-License-Identifier: MIT

pragma solidity 0.8.4;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "@openzeppelin/contracts/utils/Address.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";


contract KageStaking is Ownable, ReentrancyGuard {
  using SafeMath for uint256;
  using SafeERC20 for IERC20;

  struct UserInfo {
    uint256 amount;           // How many Kage tokens the user has provided.
    uint256 rewardDebt;       // number of reward token user got.
    uint256 timeLeft;         // left time until withdraw
    uint256 lastDepositTime;  // when user deposited
  }

  event TokenStaked(address user, uint256 amount);
  event TokenWithdraw(address user, uint256 amount);
  event ClaimToken(address user);
  event RewardRateSet(uint256 value);
  event FeeWalletSet(address newFeeWallet);

  address public kageToken;
  address private feeWallet;
  mapping (address => UserInfo) public userInfo;

  uint256 public rewardsDuration = 90 days;
  uint256 public totalSupply;
  uint256 public rewardRate;    // value of APY  static: 175%

  constructor(address _token, address _feeWallet, uint256 _rewardRate) {
    require(_token != address(0), "Zero address: Token");
    kageToken = _token;
    require(_feeWallet != address(0), "Zero address: feeWallet");
    feeWallet = _feeWallet;
    totalSupply = 0;
    rewardRate = _rewardRate;
  }
  
  function getFeeWallet() public view returns (address) {
    return feeWallet;
  }

  function setFeeWallet(address newFeeWallet) public onlyOwner {
    require(newFeeWallet != address(0), "feeWalletSet! invalid address");
    feeWallet = newFeeWallet;
    emit FeeWalletSet(newFeeWallet);
  }

  function setRewardRate(uint256 _newRate) public onlyOwner {
    require(_newRate != 0, "rate should be over 1");
    rewardRate = _newRate;
    emit RewardRateSet(_newRate);
  }

  function deposit(uint256 _amount) external nonReentrant updateReward(msg.sender) {

    require(_amount > 0, "invalid deposit amount");

    userInfo[msg.sender].amount = userInfo[msg.sender].amount.add(_amount);
    userInfo[msg.sender].lastDepositTime = block.timestamp;
    totalSupply = totalSupply.add(_amount);
    IERC20(kageToken).safeTransferFrom(msg.sender, address(this), _amount);
    emit TokenStaked(msg.sender, _amount);
  }

  /**
  lockup 30days :       7% penalty
  lockup 31 - 60days :  5% penalty
  lockup 61 - 90days :  no penalty

  static APY an early withdraw fee
  175% APY
  **/
  function withDraw(uint256 _amount) external nonReentrant updateReward(msg.sender) {
    require(_amount > 0, "invalid deposit amount");
    require( userInfo[msg.sender].amount >= _amount, "withdraw amount is bigger than you staked" );

    uint256 availableAmount = _amount + userInfo[msg.sender].rewardDebt;
    
    uint256 feeAmount = 0;
    uint256 timeDiff = block.timestamp.sub(userInfo[msg.sender].lastDepositTime);
    if(timeDiff < 30 days){
      feeAmount = availableAmount.mul(7).div(100);
    }
    else if (timeDiff < 60 days){
      feeAmount = availableAmount.mul(5).div(100);
    }

    availableAmount = availableAmount.sub(feeAmount);
    IERC20(kageToken).safeTransfer(feeWallet, feeAmount);
    IERC20(kageToken).safeTransfer(msg.sender, availableAmount);

    userInfo[msg.sender].amount = userInfo[msg.sender].amount.sub(_amount);
    totalSupply = totalSupply.sub(_amount);

    userInfo[msg.sender].rewardDebt = 0;
    userInfo[msg.sender].lastDepositTime = block.timestamp;

    emit TokenWithdraw(msg.sender, _amount);
  }

  function claimReward() external nonReentrant updateReward(msg.sender) {
        
    require((block.timestamp - userInfo[msg.sender].lastDepositTime) > 90 days, "invalid time: must be greater than 90 days");
    uint256 availableAmount = userInfo[msg.sender].amount + userInfo[msg.sender].rewardDebt;
    require( availableAmount > 0, "claim amount is bigger than you staked" );

    IERC20(kageToken).safeTransfer(msg.sender, availableAmount);
    totalSupply = totalSupply.sub(userInfo[msg.sender].amount);
    userInfo[msg.sender].amount = 0;
    userInfo[msg.sender].rewardDebt = 0;
    userInfo[msg.sender].lastDepositTime = block.timestamp;
    
    emit ClaimToken(msg.sender);
  }

  function earned(address account) public view returns (uint256) {
    uint256 rewardVal = (block.timestamp - userInfo[account].lastDepositTime).mul(userInfo[account].amount).mul(rewardRate).div(365 days);
    return rewardVal.div(100).add(userInfo[account].rewardDebt);
  }

  modifier updateReward(address account) {
      if (account != address(0)) {
        if (userInfo[msg.sender].lastDepositTime == 0) {
            userInfo[msg.sender].lastDepositTime = block.timestamp;
        }
        
        userInfo[account].rewardDebt = earned(account);
      }
      _;
  }

}