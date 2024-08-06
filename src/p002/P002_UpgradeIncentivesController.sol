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

import {RewardsController} from "lib/periphery-contracts/contracts/rewards/RewardsController.sol";

interface IZeroAddressProvider {
    function setAddressAsProxy(bytes32 id, address newImplementationAddress) external;
}

contract P002_UpgradeIncentiveController {
    address private constant EMISSIONS_MANAGER = 0x749dF84Fd6DE7c0A67db3827e5118259ed3aBBa5;
    address private constant STAKING = 0x2666951A62d82860E8e1385581E2FB7669097647;
    address private constant ZERO_ADDRESS_PROVIDER = 0xC44827C51d00381ed4C52646aeAB45b455d200eB;
    bytes32 private constant INCENTIVE_CONTROLLER_ID = 0x703c2c8634bed68d98c029c18f310e7f7ec0e5d6342c590190b3cb8b3ba54532;

    IZeroAddressProvider zeroAddressProvider;
    RewardsController rewardsControllerImpl;

    constructor() {
        zeroAddressProvider = IZeroAddressProvider(ZERO_ADDRESS_PROVIDER);
        rewardsControllerImpl = new RewardsController(EMISSIONS_MANAGER, STAKING);
    }

    function execute() public {
        zeroAddressProvider.setAddressAsProxy(INCENTIVE_CONTROLLER_ID, address(rewardsControllerImpl));
    }
}
