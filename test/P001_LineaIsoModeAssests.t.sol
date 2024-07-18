// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Test, console} from "../lib/forge-std/src/Test.sol";
import {P001_LineaIsoModeAssests} from "../src/P001_LineaIsoModeAssests.sol";

contract P001_LineaIsoModeAssestsTest is Test {
    P001_LineaIsoModeAssests public payload;

    function setUp() public {
        payload = new P001_LineaIsoModeAssests();

        // create fork network
    }

    function test__P001__Payload() public {
        payload.execute();
    }
}
