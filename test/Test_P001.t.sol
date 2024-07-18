// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Test, console} from "../lib/forge-std/src/Test.sol";
import {P001_LineaIsoModeAssests, IPoolConfigurator, IACLManager} from "../src/P001_LineaIsoModeAssests.sol";
import {IPool, DataTypes} from "../lib/core-contracts/contracts/interfaces/IPool.sol";
import {IWrappedTokenGatewayV3} from "../lib/periphery-contracts/contracts/misc/interfaces/IWrappedTokenGatewayV3.sol";

contract Test_P001 is Test {
    P001_LineaIsoModeAssests payload;
    uint256 lineaFork;

    address mai = address(0xf3B001D64C656e30a62fbaacA003B1336b4ce12A);
    address wstETH = address(0xB5beDd42000b71FddE22D3eE8a79Bd49A568fC8F);
    address grai = address(0x894134a25a5faC1c2C26F1d8fBf05111a3CB9487);
    address ezETH = address(0x2416092f143378750bb29b79eD961ab195CcEea5);
    address weth = address(0xe5D7C2a44FfDDf6b295A15c148167daaAf5Cf34f);

    address wbtc = address(0x3aAB2285ddcDdaD8edf438C1bAB47e1a9D05a9b4);
    address wrsETH = address(0xD2671165570f41BBB3B0097893300b6EB6101E6C);
    address weETH = address(0x1Bf74C010E6320bab11e2e5A532b5AC15e0b8aA6);
    address usde = address(0x5d3a1Ff2b6BAb83b63cd9AD0787074081a52ef34);
    address dai = address(0x4AF15ec2A0BD43Db75dd04E62FAA3B8EF36b00d5);

    address provider = address(0xC44827C51d00381ed4C52646aeAB45b455d200eB);

    IPoolConfigurator config;
    IACLManager acl;
    IPool pool;

    IWrappedTokenGatewayV3 gateway =
        IWrappedTokenGatewayV3(0x5d50bE703836C330Fc2d147a631CDd7bb8D7171c);

    // safe that has access to the acl manager (eventually this should go into a timelock)
    address admin = address(0x14aAD4668de2115e30A5FeeE42CFa436899CCD8A);

    address weETHborrower = address(0x5eFb1c0ba60Ee295056c6EE112491584C31d2A33);

    uint256 internal constant COLLATERAL_MASK =
        0xAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA;
    uint256 internal constant DEBT_CEILING_MASK =              0xF0000000000FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF; // prettier-ignore
    uint256 internal constant DEBT_CEILING_START_BIT_POSITION = 212;

    function setUp() external {
        lineaFork = vm.createFork(vm.envString("LINEA_RPC_URL"));
        vm.selectFork(lineaFork);
        vm.rollFork(6_953_695);

        payload = new P001_LineaIsoModeAssests(
            mai,
            wstETH,
            grai,
            ezETH,
            weth,
            wbtc,
            wrsETH,
            weETH,
            usde,
            dai,
            address(provider)
        );

        acl = payload.acl();
        pool = payload.pool();
        config = payload.config();

        // create fork network
        vm.prank(admin);
        acl.addPoolAdmin(address(payload));

        vm.prank(admin);
        acl.addPoolAdmin(address(this));
    }

    function test__P001__execute() external {
        payload.execute();
    }

    function test__P001__canRepayDisabledIsolatedDebt_WEETH() external {
        payload.execute();

        // try to repay isolated debt
        vm.prank(weETHborrower);
        gateway.repayETH{value: 1 ether}(
            address(pool),
            1 ether,
            2,
            weETHborrower
        );
    }

    function test__P001__canRepayDisabledIsolatedDebtBeyondLimits_WEETH()
        external
    {
        config.setDebtCeiling(weETH, 1);
        config.setBorrowableInIsolation(weth, false);

        // try to repay isolated debt
        vm.prank(weETHborrower);
        gateway.repayETH{value: 2 ether}(
            address(pool),
            2 ether,
            2,
            weETHborrower
        );
    }

    function test__P001__canBorrowAnotherIsolatedDebtAsset() external {
        payload.execute();
    }

    function test__P001__cannotBorrowDisabledIsolatedAsset_WEETH() external {
        payload.execute();

        vm.prank(weETHborrower);
        vm.expectRevert(bytes("36"));
        gateway.borrowETH(address(pool), 1 ether, 2, 0);
    }

    function test__P001__canExitIsolationMode() external {
        payload.execute();
    }

    function test__P001__noOverflowsOrUnderflows() external {
        payload.execute();
    }

    function _getIsolationModeAsset(
        address who
    ) internal view returns (address assetAddress, uint256 ceiling) {
        DataTypes.UserConfigurationMap memory self = pool.getUserConfiguration(
            who
        );
        uint256 id = _getFirstAssetIdByMask(self, COLLATERAL_MASK);

        assetAddress = pool.getReservesList()[id];
        DataTypes.ReserveData memory d = pool.getReserveData(assetAddress);
        ceiling = _getDebtCeiling(d.configuration);
    }

    function _getFirstAssetIdByMask(
        DataTypes.UserConfigurationMap memory self,
        uint256 mask
    ) internal pure returns (uint256) {
        unchecked {
            uint256 bitmapData = self.data & mask;
            uint256 firstAssetPosition = bitmapData & ~(bitmapData - 1);
            uint256 id;
            while ((firstAssetPosition >>= 2) != 0) {
                id += 1;
            }
            return id;
        }
    }

    function _getDebtCeiling(
        DataTypes.ReserveConfigurationMap memory self
    ) internal pure returns (uint256) {
        return
            (self.data & ~DEBT_CEILING_MASK) >> DEBT_CEILING_START_BIT_POSITION;
    }
}
