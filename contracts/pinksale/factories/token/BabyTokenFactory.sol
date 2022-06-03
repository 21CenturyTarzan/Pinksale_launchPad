// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.4;

import "@openzeppelin/contracts/proxy/Clones.sol";
import "./TokenFactoryBase.sol";
import "@openzeppelin/contracts/utils/Address.sol";
import "../../tokens/BabyToken.sol";


contract BabyTokenFactory is TokenFactoryBase {
  using Address for address payable;
  BabyToken[] public babyTokens;

  constructor(address factoryManager_, address implementation_) TokenFactoryBase(factoryManager_, implementation_) {}

  function create(
    string memory name,
    string memory symbol,
    uint256 totalSupply,
    address[4] memory addrs,
    uint256[3] memory feeSettings,
    uint256 minimumTokenBalanceForDividends_
  ) external payable enoughFee nonReentrant {
    refundExcessiveFee();
    payable(feeTo).sendValue(flatFee);
    // token = Clones.clone(implementation);
    BabyToken baby = new BabyToken(
      msg.sender,
      name,
      symbol,
      totalSupply,
      addrs,
      feeSettings,
      minimumTokenBalanceForDividends_
    );
    babyTokens.push( baby );
    assignTokenToOwner(msg.sender, address(baby), 1);
    emit TokenCreated(msg.sender, address(baby), 1);
  }

  function getTokens() public view returns(BabyToken[] memory) {
    return babyTokens;
  }
}