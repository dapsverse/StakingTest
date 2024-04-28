# Staking Project Deployment Step

1. Setup your hardhat vars

```
npx hardhat vars set ALCHEMY_API_KEY
npx hardhat vars set SEPOLIA_PRIVATE_KEY
```

2. Run ignition

```
npx hardhat ignition deploy ./ignition/modules/Staking.js --network sepolia
```