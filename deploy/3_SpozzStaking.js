 module.exports = async function ({ getNamedAccounts, deployments }) {
  const { deploy } = deployments

  const { deployer } = await getNamedAccounts()

  await deploy("Spozz", {
    from: deployer,
    args: [],
    log: true,
    deterministicDeployment: false
  })

  const spozzAddress = (await deployments.get("Spozz")).address;

  await deploy("SpozzStaking", {
    from: deployer,
    args: [spozzAddress],
    log: true,
    deterministicDeployment: false
  })
}

module.exports.tags = ["SpozzStaking"]
