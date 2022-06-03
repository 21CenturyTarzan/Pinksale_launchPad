// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.4;

import "@openzeppelin/contracts/proxy/Clones.sol";
import "./TokenFactoryBase.sol";
import "@openzeppelin/contracts/utils/Address.sol";
// import "../../interfaces/IBuybackBabyToken.sol";
import "../../tokens/BuybackBabyToken.sol";


contract BuybackBabyTokenFactory is TokenFactoryBase {
  using Address for address payable;
  BuybackBabyToken[] public buybackBabyToken;

  constructor(address factoryManager_, address implementation_) TokenFactoryBase(factoryManager_, implementation_) {}

  function create(
    string memory name,
    string memory symbol,
    uint256 totalSupply,
    address rewardToken,
    address router,
    uint256[5] memory feeVals
  ) external payable enoughFee nonReentrant returns (address token) {
    refundExcessiveFee();
    payable(feeTo).sendValue(flatFee);
    token = Clones.clone(implementation);
    BuybackBabyToken(payable(token)).initialize(
      msg.sender,
      name,
      symbol,
      totalSupply,
      rewardToken,
      router,
      feeVals
    );
    buybackBabyToken.push(BuybackBabyToken(payable(token)));
    assignTokenToOwner(msg.sender, token, 1);
    emit TokenCreated(msg.sender, token, 1);
  }

  function getTokens() public view returns(BuybackBabyToken[] memory) {
    return buybackBabyToken;
  }
}