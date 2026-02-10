// SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;

import {MaxValueRule} from "../../src/rules/MaxValueRule.sol";
import {PolicyCodec} from "../../src/libraries/PolicyCodec.sol";

/// @title EchidnaMaxValueRule
/// @notice Echidna property tests for MaxValueRule
contract EchidnaMaxValueRule {
    MaxValueRule internal rule;

    constructor() {
        rule = new MaxValueRule();
    }

    /// @notice Values at or below the limit always pass
    function test_value_at_or_below_limit_passes(uint256 maxVal, uint256 value) public {
        if (value > maxVal) return;

        bytes memory params = PolicyCodec.encodeMaxValueParams(maxVal);
        (bool passed,) = rule.evaluate(params, address(0), address(0), value, "");
        assert(passed);
    }

    /// @notice Values above the limit always fail
    function test_value_above_limit_fails(uint256 maxVal, uint256 value) public {
        if (maxVal >= type(uint256).max) return;
        if (value <= maxVal) return;

        bytes memory params = PolicyCodec.encodeMaxValueParams(maxVal);
        (bool passed,) = rule.evaluate(params, address(0), address(0), value, "");
        assert(!passed);
    }

    /// @notice Zero value always passes regardless of limit
    function test_zero_value_always_passes(uint256 maxVal) public {
        bytes memory params = PolicyCodec.encodeMaxValueParams(maxVal);
        (bool passed,) = rule.evaluate(params, address(0), address(0), 0, "");
        assert(passed);
    }

    /// @notice Rule evaluation is pure - same inputs always give same outputs
    function test_deterministic(uint256 maxVal, uint256 value) public {
        bytes memory params = PolicyCodec.encodeMaxValueParams(maxVal);
        (bool passed1,) = rule.evaluate(params, address(0), address(0), value, "");
        (bool passed2,) = rule.evaluate(params, address(0), address(0), value, "");
        assert(passed1 == passed2);
    }
}
