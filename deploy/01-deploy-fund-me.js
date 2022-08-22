// async function deployFunc(hre) {
//     console.log("hi")
// }

const { hexStripZeros } = require("ethers/lib/utils")
const { network, deployments } = require("hardhat")
// we are getting the netWork cofigurations from our helper config fie
const { networkConfig, developmentChains } = require("../helper-hardhat-config")
const chainId = network.config.chainId
const { verify } = require("../utils/verify")

// module.exports = async (hre) => {
//     const { getNamedAccounts, deployments } = hre }

// if chainId is x use address y ....etc

// const ethUsdPriceFeedAddress = networkConfig[chainId]["ethUsdPriceFeed"]

module.exports = async ({ getNamedAccounts, deployments }) => {
    const { deploy, log } = deployments
    // we get our accounts based on the accounts of number in the accounts section of each network in hardhat.conifg file
    const { deployer } = await getNamedAccounts()
    const chainId = network.config.chainId

    let ethUsdPriceFeedAddress
    if (developmentChains.includes(network.name)) {
        const ethUsdAggregator = await deployments.get("MockV3Aggregator")
        ethUsdPriceFeedAddress = ethUsdAggregator.address
    } else {
        ethUsdPriceFeedAddress = networkConfig[chainId]["ethUsdPriceFeed"]
    }

    //when going for a local host or a hardhat network we wan to use a mock
    const args = [ethUsdPriceFeedAddress]
    const fundMe = await deploy("FundMe", {
        from: deployer,
        args: args, //put price feed address
        log: true, //logs out info about deployment like address and things on the console
        waitConfirmations: network.config.blockConfirmations || 1,
    })

    if (
        !developmentChains.includes(network.name) &&
        process.env.ETHERSCAN_API
    ) {
        await verify(fundMe.address, args)
    }
    log("----------------------------------------------")
}

module.exports.tags = ["all", "fundme"]
