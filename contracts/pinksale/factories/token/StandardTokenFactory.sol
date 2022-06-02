// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.4;

import "@openzeppelin/contracts/proxy/Clones.sol";
import "@openzeppelin/contracts/utils/Address.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "./TokenFactoryBase.sol";
// import "../../interfaces/IStandardERC20.sol";
import "../../tokens/StandardToken.sol";

contract StandardTokenFactory is TokenFactoryBase {
  using Address for address payable;
  using SafeMath for uint256;
  StandardToken[] public tokens;

  constructor(address factoryManager_, address implementation_) TokenFactoryBase(factoryManager_, implementation_) {}

  function create(
    string memory name, 
    string memory symbol, 
    uint8 decimals, 
    uint256 totalSupply
  ) external payable enoughFee nonReentrant returns (address token) {
    refundExcessiveFee();
    payable(feeTo).sendValue(flatFee);
    token = Clones.clone(implementation);
    StandardToken(token).initialize(msg.sender, name, symbol, decimals, totalSupply);
    tokens.push(StandardToken(token));
    assignTokenToOwner(msg.sender, token, 0);
    emit TokenCreated(msg.sender, token, 0);
  }

  function getTokens() external view returns(StandardToken[] memory){
    return tokens;
  }
}