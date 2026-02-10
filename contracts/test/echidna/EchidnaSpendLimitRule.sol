// SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;

import {SpendLimitRule} from "../../src/rules/SpendLimitRule.sol";
import {PolicyCodec} from "../../src/libraries/PolicyCodec.sol";

/// @title EchidnaSpendLimitRule
/// @notice Echidna property tests for SpendLimitRule
contract EchidnaSpendLimitRule {
    SpendLimitRule internal rule;

    // Test constants
    address internal constant TOKEN = address(0xBEEF);
    uint256 internal constant WINDOW = 3600; // 1 hour

    // ERC20 transfer selector: transfer(address,uint256)
    bytes4 private constant TRANSFER_SELECTOR = 0xa9059cbb;

    constructor() {
        rule = new SpendLimitRule();
    }

    // ──────────────────── Helpers ────────────────────

    function _makeParams(uint256 maxAmount) internal pure returns (bytes memory) {
        return PolicyCodec.encodeSpendLimitParams(TOKEN, maxAmount, WINDOW);
    }

    function _makeTransferData(address to, uint256 amount) internal pure returns (bytes memory) {
        return abi.encodeWithSelector(TRANSFER_SELECTOR, to, amount);
    }

    // ──────────────────── Properties ────────────────────

    /// @notice A zero-value transfer should always pass
    function test_zero_transfer_always_passes(uint256 maxAmount) public {
        if (maxAmount == 0) maxAmount = 1;

        bytes memory params = _makeParams(maxAmount);
        bytes memory data = _makeTransferData(address(0x1), 0);

        (bool passed,) = rule.evaluate(params, address(this), TOKEN, 0, data);
        assert(passed);
    }

    /// @notice A transfer within limits should pass on a fresh state
    function test_transfer_within_limit_passes(uint256 maxAmount, uint256 amount) public {
        if (maxAmount == 0) maxAmount = 1;
        if (amount > maxAmount) amount = maxAmount;

        bytes memory params = _makeParams(maxAmount);
        bytes memory data = _makeTransferData(address(0x1), amount);

        (bool passed,) = rule.evaluate(params, address(this), TOKEN, 0, data);
        assert(passed);
    }

    /// @notice Non-token transactions should always pass (no spend tracking)
    function test_non_token_tx_always_passes(uint256 maxAmount, uint256 value) public {
        if (maxAmount == 0) maxAmount = 1;

        bytes memory params = _makeParams(maxAmount);

        // Send to a non-token address with arbitrary value
        (bool passed,) = rule.evaluate(params, address(this), address(0xDEAD), value, "");
        assert(passed);
    }

    /// @notice Recording a spend should increase the tracked state
    function test_record_increases_spend(uint256 maxAmount, uint256 amount) public {
        if (maxAmount == 0) maxAmount = 1;
        if (amount == 0) amount = 1;
        if (amount > maxAmount) amount = maxAmount;

        bytes memory params = _makeParams(maxAmount);
        bytes memory data = _makeTransferData(address(0x1), amount);

        // Record a spend
        rule.record(address(this), 0, params, address(0), TOKEN, 0, data);

        // Retrieve state
        (uint256 spent,) = rule.spendStates(address(this), 0);
        assert(spent >= amount);
    }

    /// @notice Native ETH tracking: spending ETH with token=address(0) should be tracked
    function test_native_eth_tracked(uint256 maxAmount, uint256 value) public {
        if (maxAmount == 0) maxAmount = 1;
        if (value > maxAmount) value = maxAmount;

        bytes memory params = PolicyCodec.encodeSpendLimitParams(address(0), maxAmount, WINDOW);

        (bool passed,) = rule.evaluate(params, address(this), address(0xDEAD), value, "");
        assert(passed);
    }
}
