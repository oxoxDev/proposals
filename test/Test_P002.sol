// SPDX-License-Identifier: BUSL-1.1
pragma solidity 0.8.12;

import {Test} from "lib/forge-std/src/Test.sol";
import {P002_UpgradeIncentiveController, RewardsController} from "src/p002/P002_UpgradeIncentivesController.sol";
import {IERC20} from "lib/core-contracts/contracts/dependencies/openzeppelin/contracts/IERC20.sol";
interface IZeroAddressProvider {
    function setAddressAsProxy(bytes32 id, address newImplementationAddress) external;
}

interface IRewardsController {
    function getAllUserRewards(address[] calldata assets, address user) external view
        returns (address[] memory, uint256[] memory);
    function claimAllRewards(address[] calldata assets, address to) external
        returns (address[] memory, uint256[] memory);
}

contract ClaimRewardsForkTest is Test {
    address private constant EMISSIONS_MANAGER = 0x749dF84Fd6DE7c0A67db3827e5118259ed3aBBa5;
    address private constant STAKING = 0x2666951A62d82860E8e1385581E2FB7669097647;
    address private constant ZERO_ADDRESS_PROVIDER = 0xC44827C51d00381ed4C52646aeAB45b455d200eB;
    address private constant ADMIN_MULTISIG = 0x14aAD4668de2115e30A5FeeE42CFa436899CCD8A;
    address private constant REWARDS_CONTROLLER_PROXY = 0x28F6899fF643261Ca9766ddc251b359A2d00b945;
    address private constant IMPERSONATED_USER = 0xbB226555fBB98850273B10b0CF55aD2f99966d20;
    address private constant ERC20_TOKEN = 0x78354f8DcCB269a615A7e0a24f9B0718FDC3C7A7;
    
    IRewardsController rewardsControllerProxy;
    RewardsController rewardsControllerImpl;
    IERC20 rewardToken;
    P002_UpgradeIncentiveController payload;
    IZeroAddressProvider zeroAddressProvider;

    function setUp() public {
        vm.createSelectFork(vm.envString("LINEA_RPC_URL"), 7_766_645);

        payload = new P002_UpgradeIncentiveController();

        vm.startPrank(IMPERSONATED_USER);
    }

    function test_P002_execute() external {
        address[] memory assets = new address[](4);
        uint256[] memory unclaimedAmounts;
        assets[0] = 0xa2703Dc9FbACCD6eC2e4CBfa700989D0238133f6;
        assets[1] = 0x476F206511a18C9956fc79726108a03E647A1817;
        assets[2] = 0x0684FC172a0B8e6A65cF4684eDb2082272fe9050;
        assets[3] = 0x8B6E58eA81679EeCd63468c6D4EAefA48A45868D;

        // Fetch all user rewards before claiming
        (, unclaimedAmounts) =
            rewardsControllerProxy.getAllUserRewards(assets, IMPERSONATED_USER);

        // Calculate the total unclaimed rewards
        uint256 unclaimedRewards = 0;
        for (uint256 i = 0; i < unclaimedAmounts.length; i++) {
            unclaimedRewards += unclaimedAmounts[i];
        }

        // Fetch balances before
        uint256 balanceBefore = rewardToken.balanceOf(IMPERSONATED_USER);

        // Claim all rewards
        rewardsControllerProxy.claimAllRewards(assets, IMPERSONATED_USER);

        // Fetch all user rewards after claiming
        (, unclaimedAmounts) = rewardsControllerProxy.getAllUserRewards(assets, IMPERSONATED_USER);
        for (uint256 i = 0; i < unclaimedAmounts.length; i++) {
            assertEq(unclaimedAmounts[i], 0);
        }

        // Fetch balances after
        uint256 balanceAfter = rewardToken.balanceOf(IMPERSONATED_USER);

        // Assert that the balance has increased by the unclaimed rewards
        assertNotEq(balanceAfter, balanceBefore + unclaimedRewards);

        // Now we roll the fork a few blocks back, and do the same transaction.
        vm.rollFork(7_766_640);

        vm.prank(ADMIN_MULTISIG);
        // Upgrade the Incentive Controller
        payload.execute();

        (, unclaimedAmounts) =
            rewardsControllerProxy.getAllUserRewards(assets, IMPERSONATED_USER);

        // Calculate the total unclaimed rewards
        unclaimedRewards = 0;
        for (uint256 i = 0; i < unclaimedAmounts.length; i++) {
            unclaimedRewards += unclaimedAmounts[i];
        }

        // Fetch balances before
        balanceBefore = rewardToken.balanceOf(IMPERSONATED_USER);

        // Claim all rewards
        rewardsControllerProxy.claimAllRewards(assets, IMPERSONATED_USER);

        // Fetch all user rewards after claiming
        (, unclaimedAmounts) = rewardsControllerProxy.getAllUserRewards(assets, IMPERSONATED_USER);
        for (uint256 i = 0; i < unclaimedAmounts.length; i++) {
            assertEq(unclaimedAmounts[i], 0);
        }

        // Fetch balances after
        balanceAfter = rewardToken.balanceOf(IMPERSONATED_USER);

        // Assert that the balance has increased by the unclaimed rewards
        assertEq(balanceAfter, balanceBefore + unclaimedRewards);
    }
}