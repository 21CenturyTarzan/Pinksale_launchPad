// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.4;

import "@openzeppelin/contracts/proxy/Clones.sol";
import "./TokenFactoryBase.sol";
import "@openzeppelin/contracts/utils/Address.sol";
// import "../../interfaces/ILiquidityGeneratorToken.sol";
import "../../tokens/LiquidityGeneratorToken.sol";


contract LiquidityGeneratorTokenFactory is TokenFactoryBase {
  using Address for address payable;
  LiquidityGeneratorToken[] public liquidityTokens;

  constructor(address factoryManager_, address implementation_) TokenFactoryBase(factoryManager_, implementation_) {}

  function create(
    string memory name,
    string memory symbol,
    uint256 totalSupply,
    address router,
    address charity,
    uint16 taxFeeBps, 
    uint16 liquidityFeeBps,
    uint16 charityBps
  ) external payable enoughFee nonReentrant returns (address token) {
    refundExcessiveFee();
    payable(feeTo).sendValue(flatFee);
    token = Clones.clone(implementation);
    LiquidityGeneratorToken( payable(token) ).initialize(
      msg.sender,
      name,
      symbol,
      totalSupply,
      router,
      charity,
      taxFeeBps,
      liquidityFeeBps,
      charityBps
    );
    liquidityTokens.push(LiquidityGeneratorToken( payable(token) ));
    assignTokenToOwner(msg.sender, token, 1);
    emit TokenCreated(msg.sender, token, 1);
  }

  function getTokens() public view returns(LiquidityGeneratorToken[] memory) {
    return liquidityTokens;
  }
}