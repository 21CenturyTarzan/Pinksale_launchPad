const { expect } = require('chai')
const { ethers, network } = require('hardhat')

const ZERO_ADDRESS = ethers.utils.getAddress(
  '0x0000000000000000000000000000000000000000',
)

describe('spozzStaking=======', function () {
  let kageStaking
  let kageToken
  let owner
  let addr1
  let addr2
  let addr3
  let addrs
  let initialSupply
  
  beforeEach('This is spozzStaking contract test..', async () => {
    [owner, addr1, addr2, addr3, ...addrs] = await ethers.getSigners();

    console.log(owner.address)
    initialSupply = ethers.utils.parseUnits('1000000000', "gwei");

    const tokenContract = await ethers.getContractFactory('Spozz')
    kageToken = await tokenContract.deploy()
    await kageToken.deployed()

    await kageToken.transfer(addr1.address, ethers.utils.parseUnits("100000", "gwei"));
    await kageToken.transfer(addr2.address, ethers.utils.parseUnits("100000", "gwei"));
  
    const kageStakingContract = await ethers.getContractFactory('SpozzStaking');
    kageStaking = await kageStakingContract.deploy(kageToken.address);
    await kageStaking.deployed()
  });

  describe('mkongToken setup', async () => {
    it("should be named 'spozz Trade Token", async () => {
      const name = await kageToken.name();
      expect(name).to.equal('Spozz Trade Token');
    });
    it('should have correct supply', async () => {
      const supply = await kageToken.totalSupply();
      expect(supply).to.equal(initialSupply)
    });    
  });

  describe('staking contract setup', async () => {
    it('Test inital month idx ', async function () {
      const initialMonthIdx = await kageStaking.curMonthIdx();
      console.log('Tarzan: staking address===>', kageStaking.address);
      console.log('Tarzan: rewardRate=====>', initialMonthIdx);
      expect(initialMonthIdx).to.equal(0);
    });
  });

  describe('owner transfer token to alice', async () =>{
    it('transfer kage token to alice ', async function () {
      
      let aliceBalance = await kageToken.balanceOf(addr1.address);
      expect(aliceBalance).to.equal(100000000000000);

      let bobBalance = await kageToken.balanceOf(addr2.address);
      expect(bobBalance).to.equal(100000000000000);

      await kageToken.approve(kageStaking.address, ethers.utils.parseUnits("100000000", "gwei"));
      await kageToken.connect(addr1).approve(kageStaking.address, ethers.utils.parseUnits("100000000", "gwei"));

      // owner stake 1000 token
      const stakeAmount1 = ethers.utils.parseUnits("1000", "gwei");
      await kageStaking.stakeToken(stakeAmount1);

      // 3 days pass
      await network.provider.send("evm_increaseTime", [3 * 24 * 60 * 60]);
      await network.provider.send("evm_mine");

      // addr1 stake 1500 token
      const stakeAmount2_1 = ethers.utils.parseUnits("1500", "gwei");
      await kageStaking.connect(addr1).stakeToken(stakeAmount2_1);

      // 5 days pass
      await network.provider.send("evm_increaseTime", [5 * 24 * 60 * 60]);
      await network.provider.send("evm_mine");

      // owner stake 2000 token again.
      const stakeAmount2 = ethers.utils.parseUnits("2000", "gwei");
      await kageStaking.stakeToken(stakeAmount2);

      let userInfo = await kageStaking.userInfos(owner.address);
      expect(userInfo.stakedAmount).to.equal(3000000000000);

      let sharedata = await kageStaking.getUserMonthShare(0);
      expect(sharedata).to.equal(8000000000000);  // 8000

      // 15 days passed
      await network.provider.send("evm_increaseTime", [15 * 24 * 60 * 60]);
      await network.provider.send("evm_mine");

      // set month profit as 1000000 ==================================================================
      let profit0 = ethers.utils.parseUnits("1000000", "gwei");
      kageStaking.setMonthProfit(profit0);
      kageToken.transfer(kageStaking.address, profit0);
      let monthData = await kageStaking.getMonthData(0);
      console.log("[tz]:month 0 total share============== ", ethers.utils.formatUnits(monthData.totalShare, "gwei"));
      console.log("[tz]:month 0 accPerShare============== ", ethers.utils.formatUnits(monthData.accPerShare, "gwei"));

      // 30 days passed
      await network.provider.send("evm_increaseTime", [30 * 24 * 60 * 60]);
      await network.provider.send("evm_mine");

      // set next month profit ==============================================================================
      let profit1 = ethers.utils.parseUnits("1000000", "gwei");
      kageStaking.setMonthProfit(profit1);
      kageToken.transfer(kageStaking.address, profit1);

      // 1 days passed
      await network.provider.send("evm_increaseTime", [1 * 24 * 60 * 60]);
      await network.provider.send("evm_mine");

      let monthData1 = await kageStaking.getMonthData(1);
      console.log("[tz]:month 1 total share============== ", ethers.utils.formatUnits(monthData1.totalShare, "gwei"));
      console.log("[tz]:month 1 accPerShare============== ", ethers.utils.formatUnits(monthData1.accPerShare, "gwei"));
      
      await kageStaking.stakeToken("0");
      let sharedata0 = await kageStaking.getUserMonthShare(0);
      let sharedata1 = await kageStaking.getUserMonthShare(1);
      console.log("[tz]:final sharedata0", ethers.utils.formatUnits(sharedata0, "gwei"));
      console.log("[tz]:final sharedata1", ethers.utils.formatUnits(sharedata1, "gwei"));
      //let user = await kageStaking.userInfos(owner.address);
      let pending = await kageStaking.pendingSpozz();
      console.log("[tz]:admin amount pending", ethers.utils.formatUnits(pending, "gwei"));
      let pending2 = await kageStaking.connect(addr1).pendingSpozz();
      console.log("[tz]:addr1 amount pending", ethers.utils.formatUnits(pending2, "gwei"));

      // stake token 2000
      await kageStaking.stakeToken(stakeAmount2);
      let oreward = await kageStaking.userInfos(owner.address);
      console.log("[tz]:owner reward amount ", ethers.utils.formatUnits(oreward.rewardDebt, "gwei"));

      await network.provider.send("evm_increaseTime", [1 * 24 * 60 * 60]);
      await network.provider.send("evm_mine");

      let balance = await kageToken.balanceOf(kageStaking.address);
      console.log("[tz]:balance of staking contract", ethers.utils.formatUnits(balance, "gwei"));

      // unstake token 2000
      await kageStaking.unstakeToken(stakeAmount2);
      let user = await kageStaking.userInfos(owner.address);
      console.log("[tz]:owner staked amount after unstake", ethers.utils.formatUnits(user.stakedAmount, "gwei"));
    });

    it('owner transfer token to alice, alice to bob', async () =>{

    });
  });

  // describe('staking mKong token', async () =>{
  //   it('stake token to mkong staking contract >>>', async function () {
  //     let balance1 = await kageToken.balanceOf(addr1.address);
  //     console.log("[tz]: balance of person1", ethers.utils.formatEther(balance1.toString()));

  //     await kageToken.approve(kageStaking.address, ethers.utils.parseEther("1000000"));
  //     await kageToken.connect(addr1).approve(kageStaking.address, ethers.utils.parseEther("1000000"));

  //     await kageStaking.stakeToken(ethers.utils.parseEther("100"));

  //     await kageStaking.stakeToken(ethers.utils.parseEther("500"));

  //     await kageStaking.connect(addr1).stakeToken(ethers.utils.parseEther("700"));

  //     // expect(balance1).to.expect();

  //     let num = ethers.utils.formatEther(await kageStaking.totalStakedAmount());

  //     console.log("total supply of staking", num);

  //     await network.provider.send("evm_increaseTime", [18144000]);
  //     await network.provider.send("evm_mine");

  //     await kageStaking.unstakeToken(ethers.utils.parseEther("500"), false);

  //     let userInfo = await kageStaking.userInfos(owner.address);
  //     console.log("owner staked amount",  ethers.utils.formatEther(userInfo.stakedAmount));
  //     console.log("owner pending amount",  ethers.utils.formatEther(userInfo.pendingAmount));
  //   });
    
  // });

  // describe('emergency withdraw test', async () =>{
  //   it('stake token to mkong staking contract >>>', async function () {
  //     let balance1 = await kageToken.balanceOf(addr1.address);
  //     console.log("[tz]: balance of person1", ethers.utils.formatEther(balance1.toString()));

  //     await kageToken.approve(kageStaking.address, ethers.utils.parseEther("1000000"));
  //     await kageToken.connect(addr1).approve(kageStaking.address, ethers.utils.parseEther("1000000"));

  //     await kageStaking.stakeToken(ethers.utils.parseEther("100"));

  //     await kageStaking.stakeToken(ethers.utils.parseEther("500"));

  //     await kageStaking.connect(addr1).stakeToken(ethers.utils.parseEther("700"));

  //     // expect(balance1).to.expect();

  //     let num = ethers.utils.formatEther(await kageStaking.totalStakedAmount());

  //     console.log("total supply of staking", num);

  //     await network.provider.send("evm_increaseTime", [18144000]);
  //     await network.provider.send("evm_mine");

  //     await kageStaking.connect(addr1).unstakeToken(ethers.utils.parseEther("500"), true);
  //     let addr1Info = await kageStaking.userInfos(addr1.address);
  //     console.log("addr1 staked amount",  ethers.utils.formatEther(addr1Info.stakedAmount));
  //     let balance2 = await kageToken.balanceOf(addr1.address);
  //     console.log("addr1 wallet amount",  ethers.utils.formatEther(balance2));

  //     await kageStaking.unstakeToken(ethers.utils.parseEther("500"), false);

  //     let userInfo = await kageStaking.userInfos(owner.address);
  //     console.log("owner staked amount",  ethers.utils.formatEther(userInfo.stakedAmount));
  //     console.log("owner pending amount",  ethers.utils.formatEther(userInfo.pendingAmount));
  //   });
    
  // });

//   it("should fail by depositing more than current balance", async () => {
//     const txFailure = initialSupply + 1;
//     await expect(contract.transfer(txFailure, aliceAddress)).to.be.revertedWith("Not enough funds");
// });

})
