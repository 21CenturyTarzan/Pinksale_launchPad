# This is hardhat project for Pinksale LaunchPad Contracts

#npx hardhat compile
 -- this will compile all smart contract file.
#npx hardhat test
 -- this will run test script.

# deploy
    npm run bsctest:deploy


# contract deployment step.🚀🚀🚀🚀

1. deploy TokenFactoryManager.sol 
2. deploy token contracts. (standard token, liqudity generator token, babytoken, babybuyback)

3. deploy standardTokenFactory.sol contract.
   (factorymanager address,  token implmentation address)

4. add token factory to the TokenFactoryManager.sol

5. create new token 

    call create function in StandardTokenFactory.sol : create(name, symbol, decimals, totalsupply)


6. deploy presale contract 

7. deploy presaleFactory contract.


# smart contract testing related to router address.
refer this url
https://hardhat.org/hardhat-network/guides/mainnet-forking

- set hardhat forking configuration with ehtereum-mainnet alchemy key
my configuration
    hardhat: {
      forking: {
        // enabled: process.env.FORKING === "true",
        url: `https://eth-mainnet.alchemyapi.io/v2/${process.env.ALCHEMY_API_KEY2}`,
      },
      // live: false,
      // saveDeployments: true,
      // tags: ["test", "local"],
    },

- open a terminal and type
    npx hardhat node
    (then: npx hardhat test)
- open another terminal and type
    npx hardhat test

it will compile smart contract files first then show yellow messages like below
```diff
- text in red
+ text in green
! text in You're running a network fork starting from the latest block.
! Performance may degrade due to fetching data from the network with each run.
! If connecting to an archival node (e.g. Alchemy), we strongly recommend setting
! blockNumber to a fixed value to increase performance with a local cache.
# text in gray
@@ text in purple (and bold)@@
```
