// SPDX-License-Identifier: BUSL-1.1
pragma solidity 0.8.19;

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

interface IRewardsController {
    function upgradeTo(address newImplementation) external;
}

contract P002_UpgradeIncentiveController {
    address private constant EMISSIONS_MANAGER = 0x749dF84Fd6DE7c0A67db3827e5118259ed3aBBa5;
    address private constant STAKING = 0x2666951A62d82860E8e1385581E2FB7669097647;
    address private constant REWARDS_CONTROLLER_PROXY = 0x28F6899fF643261Ca9766ddc251b359A2d00b945;

    IRewardsController rewardsControllerProxy;
    RewardsController rewardsControllerImpl;

    constructor() {
        rewardsControllerProxy = IRewardsController(REWARDS_CONTROLLER_PROXY);
        rewardsControllerImpl = new RewardsController(EMISSIONS_MANAGER, STAKING);
    }

    function execute() public {
        rewardsControllerProxy.upgradeTo(address(rewardsControllerImpl));
    }
}
