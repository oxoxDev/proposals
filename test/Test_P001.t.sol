// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Test, console} from "../lib/forge-std/src/Test.sol";
import {P001_LineaIsoModeAssests, IPoolConfigurator, IACLManager} from "../src/P001_LineaIsoModeAssests.sol";

contract Test_P001 is Test {
    P001_LineaIsoModeAssests public payload;
    uint256 lineaFork;

    address public mai = address(0xf3B001D64C656e30a62fbaacA003B1336b4ce12A);
    address public wstETH = address(0xB5beDd42000b71FddE22D3eE8a79Bd49A568fC8F);
    address public grai = address(0x894134a25a5faC1c2C26F1d8fBf05111a3CB9487);
    address public ezETH = address(0x2416092f143378750bb29b79eD961ab195CcEea5);
    address public weth = address(0xe5D7C2a44FfDDf6b295A15c148167daaAf5Cf34f);
    IPoolConfigurator public config =
        IPoolConfigurator(0xf17218B09699d0F7145e40E771e72130FF616498);
    IACLManager public acl =
        IACLManager(0xb2178109A414C3a869E5104283Fcf1a18923D0B8);

    address public admin = address(0x14aAD4668de2115e30A5FeeE42CFa436899CCD8A);

    function setUp() public {
        lineaFork = vm.createFork(vm.envString("LINEA_RPC_URL"));
        vm.selectFork(lineaFork);
        vm.rollFork(6_953_695);

        payload = new P001_LineaIsoModeAssests(
            mai,
            wstETH,
            grai,
            ezETH,
            weth,
            address(config),
            address(acl)
        );

        // create fork network
        vm.prank(admin);
        acl.addPoolAdmin(address(payload));
    }

    function test__P001__execute() public {
        payload.execute();
    }

    function test__P001__checkStates() public {
        payload.execute();
    }
}
