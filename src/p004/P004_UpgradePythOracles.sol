// SPDX-License-Identifier: BUSL-1.1
pragma solidity 0.8.12;

// ███████╗███████╗██████╗  ██████╗
// ╚══███╔╝██╔════╝██╔══██╗██╔═══██╗
//   ███╔╝ █████╗  ██████╔╝██║   ██║
//  ███╔╝  ██╔══╝  ██╔══██╗██║   ██║
// ███████╗███████╗██║  ██║╚██████╔╝
// ╚══════╝╚══════╝╚═╝  ╚═╝ ╚═════╝

// Website: https://zerolend.xyz
// Discord: https://discord.gg/zerolend
// Twitter: https://twitter.com/zerolendxyz
// Telegram: https://t.me/zerolendxyz

// visit https://github.com/zerolend/proposals for information about tests and deployment scripts
import { PythAggregatorV3 } from "lib/pyth-oracles/contracts/PythAggregatorV3.sol";

contract P004_UpgradePythOracles {
    PythAggregatorV3 pythOracle;

    event PythOracleDeployed(address indexed deployer, address indexed pythOracleAddress);

    constructor() {}

    function execute(address pyth, bytes32 priceId, uint64 maxStalePeriod) public {
        pythOracle = new PythAggregatorV3(pyth, priceId, maxStalePeriod);
        emit PythOracleDeployed(msg.sender, address(pythOracle));
    }
}
