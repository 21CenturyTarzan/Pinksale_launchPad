// SPDX-License-Identifier: MIT

pragma solidity 0.8.4;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "@openzeppelin/contracts/utils/Address.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
// import "hardhat/console.sol";


interface IXShape {

    function totalSupply() external view returns (uint256);
    function balanceOf(address account) external view returns (uint256);
    function transfer(address to, uint256 amount) external returns (bool);
    function allowance(address owner, address spender) external view returns (uint256);
    function approve(address spender, uint256 amount) external returns (bool);
    function transferFrom( address from, address to, uint256 amount ) external returns (bool);
    function mint(address _to, uint256 _amount) external returns(bool);
    function burn(address _from, uint _amount) external returns(bool);

    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
}


contract ShapeDeposit is Ownable, ReentrancyGuard {
  using SafeMath for uint256;
  using SafeERC20 for IXShape;
  using SafeERC20 for IERC20;

  struct UserInfo {
    uint256 depositAmount;
    uint256 depositTime;
  }

  event DepositShape(address user, uint256 amount);
  event TokenWithdraw(address user, uint256 amount);
  event SwapBackFeeSet(uint256 value);

  address public shapeToken;
  address public xShapeToken;
  mapping (address => UserInfo) public userInfos;

  uint256 public totalDeposit;
  uint256 public SWAPBACK_TIMEDIV = 7 days;

  constructor(address _shape, address _xShape) {
    require(_shape != address(0), "Zero address: shape");
    require(_xShape != address(0), "Zero address: xShape");
    shapeToken = _shape;
    xShapeToken = _xShape;
    totalDeposit = 0;
  }
  
  function depositToken(uint256 _amount) external nonReentrant {

    require(_amount > 0, "invalid deposit amount");

    IERC20(shapeToken).safeTransferFrom(msg.sender, address(this), _amount);
    userInfos[msg.sender].depositAmount = userInfos[msg.sender].depositAmount.add(_amount);
    userInfos[msg.sender].depositTime = block.timestamp;
    totalDeposit = totalDeposit.add(_amount);
    IXShape(xShapeToken).mint(msg.sender, _amount);
    emit DepositShape(msg.sender, _amount);
  }
  
  function swapBack2Shape(uint256 _amount) external nonReentrant {
    require(_amount > 0, "invalid swap back amount");
    require( userInfos[msg.sender].depositAmount >= _amount, "swap amount is bigger than you deposited" );

    uint256 timeDiff = block.timestamp.sub(userInfos[msg.sender].depositTime);
    timeDiff = timeDiff.div(SWAPBACK_TIMEDIV);
    
    IXShape(xShapeToken).burn(msg.sender, _amount);

    if (timeDiff == 0){
        _amount = _amount.mul(92).div(100);
    }else if (timeDiff == 1){
        _amount = _amount.mul(94).div(100);
    }
    else if (timeDiff == 2){
        _amount = _amount.mul(96).div(100);
    }
    else if (timeDiff == 3){
        _amount = _amount.mul(98).div(100);
    }

    IERC20(shapeToken).safeTransfer(msg.sender, _amount);
    userInfos[msg.sender].depositAmount = userInfos[msg.sender].depositAmount.sub(_amount);

    emit TokenWithdraw(msg.sender, _amount);
  }
  
  function setUnstakeTimeoff(uint256 time_) external onlyOwner {
      SWAPBACK_TIMEDIV = time_;
  }
}