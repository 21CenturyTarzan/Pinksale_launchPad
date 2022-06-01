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