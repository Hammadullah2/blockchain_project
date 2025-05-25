# Blockchain Project

This repository contains a simple smart contract for an Auction system written in Solidity.

## Files
- `auction.sol`: Main auction contract
- `auc.sol`, `ICO.sol`, `MYCoin.sol`: Additional contracts (details not included in this README)

## Auction Contract Overview
- Allows users to place bids within a specified time window
- Owner can cancel the auction
- Highest binding bid logic with bid increment
- Finalization logic for owner, highest bidder, and other participants

## Usage
1. Deploy `auction.sol` using a Solidity-compatible environment (e.g., Remix, Hardhat, Truffle)
2. Interact with the contract to start an auction, place bids, cancel, and finalize

## License
MIT
