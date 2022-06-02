 module.exports = async function ({ getNamedAccounts, deployments }) {
  const { deploy } = deployments

  const { deployer } = await getNamedAccounts()

  await deploy("TazorAuthority", {
    from: deployer,
    args: [deployer, deployer, deployer, deployer,],
    log: true,
    deterministicDeployment: false
  })
}

module.exports.tags = ["TazorAuthority"]
