# PolicyKit

Decentralized policies-as-code SDK for smart accounts and AI agents. Define composable, enforceable transaction policies with on-chain and off-chain evaluation.

## Features

- **Policies as Code** -- Define transaction policies programmatically in TypeScript
- **Three-Tier Rule System** -- Stateless on-chain, stateful on-chain, and off-chain (Lit Protocol) rules
- **ERC-7579 Compatible** -- Works with standard smart account modules
- **Non-Custodial** -- Account owners maintain full control
- **Decentralized Off-Chain Evaluation** -- Lit Protocol's TEE network for complex rule evaluation
- **Encrypted Policies** -- Optional Lit Protocol encryption for sensitive policy logic
- **Local Simulation** -- Test and simulate policies before deployment

## Architecture

PolicyKit uses a three-tier rule evaluation system:

| Tier | Where | Trust Model | Latency | Examples |
|------|-------|-------------|---------|----------|
| **Tier 1** -- Stateless On-Chain | EVM | Trustless | Instant | `ALLOW_TARGETS`, `DENY_TARGETS`, `ALLOW_SELECTORS`, `DENY_SELECTORS`, `MAX_VALUE` |
| **Tier 2** -- Stateful On-Chain | EVM | Trustless | Instant | `SPEND_LIMIT`, `COOLDOWN` |
| **Tier 3** -- Off-Chain | Lit Protocol | Decentralized TEE | ~1-3s | `MAX_SLIPPAGE_BPS`, `REQUIRE_SIMULATION`, `CUSTOM` |

## Packages

| Package | npm | Description |
|---------|-----|-------------|
| [`@policy-kit/sdk`](./sdk) | [![npm](https://img.shields.io/npm/v/@policy-kit/sdk)](https://www.npmjs.com/package/@policy-kit/sdk) | Core TypeScript SDK -- PolicyBuilder, PolicyKit client, PolicySimulator, Lit & IPFS integrations |
| [`@policy-kit/cli`](./cli) | [![npm](https://img.shields.io/npm/v/@policy-kit/cli)](https://www.npmjs.com/package/@policy-kit/cli) | CLI for initializing, deploying, simulating, inspecting, and removing policies |
| [`@policy-kit/contracts`](./contracts) | [![npm](https://img.shields.io/npm/v/@policy-kit/contracts)](https://www.npmjs.com/package/@policy-kit/contracts) | Solidity smart contracts -- PolicyEngine, PolicyGuard, ERC-7579 module, rule evaluators |
| [`@policy-kit/lit-actions`](./lit-actions) | [![npm](https://img.shields.io/npm/v/@policy-kit/lit-actions)](https://www.npmjs.com/package/@policy-kit/lit-actions) | Lit Protocol actions for off-chain policy evaluation and EIP-712 attestation signing |
| [`examples`](./examples) | -- | Example implementations (smart account, agent wallet, DAO guard) |

## Quick Start

### Install

```bash
# SDK
pnpm add @policy-kit/sdk

# CLI
pnpm add -g @policy-kit/cli

# Solidity contracts (for your own smart contracts)
pnpm add @policy-kit/contracts

# Lit Actions (pre-built bundle for off-chain evaluation)
pnpm add @policy-kit/lit-actions
```

### Usage

```typescript
import { PolicyBuilder } from "@policy-kit/sdk";
import { parseEther } from "viem";

const policy = new PolicyBuilder("treasury-policy")
  .allowTargets(["0xUniswapRouter"])
  .maxValue(parseEther("10"))
  .spendLimit("0xUSDC", parseEther("50000"), 86400)
  .cooldown(300)
  .maxSlippageBps(50)
  .requireSimulation(true)
  .setFailMode("closed")
  .build();
```

## Tech Stack

- **TypeScript** / **Solidity**
- **viem** -- Ethereum interactions
- **Lit Protocol v8 (Naga)** -- Decentralized off-chain evaluation
- **Foundry** -- Smart contract tooling
- **Turbo** + **pnpm** workspaces -- Monorepo orchestration
- **Zod** -- Runtime validation
- **IPFS (Pinata)** -- Content-addressed policy storage

## Development

### Prerequisites

- Node.js >= 18.0.0
- [pnpm](https://pnpm.io/) >= 9.15.0
- [Foundry](https://book.getfoundry.sh/) (for smart contract development)

```bash
git clone https://github.com/policy-kit/policykit.git
cd policykit
pnpm install
pnpm build
pnpm test
```

## Contributing

Contributions are welcome! Please open an issue or submit a pull request.

## Author

**Rodrigo Serviuc Pavezi** ([@rodrigopavezi](https://github.com/rodrigopavezi)) -- creator and main contributor.

## License

[MIT](./LICENSE) -- Copyright (c) 2026 Rodrigo Serviuc Pavezi
