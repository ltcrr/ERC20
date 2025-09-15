# Decentralized Crowdfunding
- Use of custom errors to reduce bytecode size and gas on revert.


## Security considerations


- The contract uses checks-effects-interactions and a reentrancy guard where funds are moved.
- Withdrawal and refund both use `call` and check the return value; they also update contract state before transferring funds.
- Creators cannot withdraw until the campaign is finished and the goal is met.
- Contributors can only refund after the campaign end and only if the goal was not met.


## Gas and optimization notes


- Using `uint64` for timestamps reduces slot usage in the struct.
- Custom errors reduce revert string costs.
- Packing frequently-updated fields together reduces SSTORE gas overhead.


## Development


### Prerequisites


- Node.js (v18+ recommended)
- npm or yarn
- Hardhat or Foundry


### Suggested Hardhat setup


1. `npm init -y`
2. `npm install --save-dev hardhat @nomiclabs/hardhat-ethers ethers`
3. Create `hardhat.config.js` and place the contract under `contracts/Crowdfunding.sol`.


### Compile


`npx hardhat compile`


### Local testing (example using Hardhat)


Create a test that:


- Deploys the contract
- Creates a campaign with a short duration
- Simulates multiple contributors
- Advances time to after the deadline
- Checks that withdraw succeeds when goal met
- Checks that refund succeeds when goal not met


### Example Hardhat script (pseudocode)


- Deploy
- call `createCampaign`
- send contributions via `contribute` from different accounts
- increase time using `evm_increaseTime`
- call `withdraw` or `refund` depending on raised amount


## Deployment


- Ensure the compiler matches `pragma solidity ^0.8.20`.
- Verify contract on Etherscan after deployment.
- For mainnet deployments, consider an independent security audit.


## Possible extensions


- Off-chain metadata and contribution tiers using ERC-20 stablecoins.
- Integration with a front-end dApp (React + Ethers.js or Wagmi).
- Support for partial withdrawals or milestone-based releases.
- Add Chainlink price feeds to accept fiat-pegged targets.
- Add an allowlist or KYC gating mechanism if required.


## Testing checklist


- Unit tests: all functions, edge cases, revert paths
- Fuzz tests for arithmetic and timestamp handling
- Gas profiling for common flows (create, contribute, withdraw, refund)
- Property tests for invariants like "total pledged equals sum of contributions"


## License


MIT
