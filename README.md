# GrasslandWar
[Link to Chinese README](https://github.com/scwang1994/Grassland-War/blob/f0296d1ef29e66b07e7d5d848961a9a78fcbbfb3/grassland-war/README.md)

In this contract, players can deposit ETH and choose to join either the `Sheep Pool` or the `Wolf Pool`. When joining, ETH will be transferred to Compound to earn interest, and at the end of each game, the dominant species will receive interest earnings. The detailed gameplay is as follows:

### Framework

#### Gameplay
* Players choose to join either the `Sheep Pool` or the `Wolf Pool` and deposit ETH.
* The deposited ETH will be used in Compound to earn interest.
* In both pools, the pool with the higher amount will become the dominant pool. The `Wolf Pool` has a 3x weight advantage in the calculation.
* The game duration is 7 days. If the dominant pool doesn't change within 7 days, the dominant species wins. If the dominant pool changes within 7 * days, the countdown restarts.
* If the result is in favor of the `Sheep Pool,` all `Sheep` participants will share the interest. The interest distribution will be weighted based on the amount invested, and `Wolves` will forfeit the interest.
* If the result is in favor of the `Wolf Pool,` the participant with the highest deposit amount will receive all the interest.
* If, at the end of the game, the number of addresses in the `Wolf Pool` is 0, the protocol wins.
* If, at the end of the game, the number of addresses in the `Wolf Pool` is 1, the `Wolf` will directly win.
* The protocol will receive 2% of the revenue from each game result.
* The second game will start immediately after the first game ends, and so on...

#### FeatureList
The operations performed by the user include joining the Sheep Pool, leaving the Sheep Pool, joining the Wolf Pool, leaving the Wolf Pool, and claiming rewards. The following are the corresponding functions for the mentioned features:

| Feature | Function | 
|----------|----------|
| Join Sheep Pool    | joinSheepPool  | 
| Leave Sheep Pool    | joinWolfPool  | 
| Join Wolf Pool    | leaveSheepPool  | 
| Leave Wolf Pool    | leaveWolfPool  | 
| Claim Reward    | claim  | 

Other query functions are as follows:
| Feature | Function | 
|----------|----------|
| Get End Time of the Current Round    | getEndTime  | 
| Get Current Winner    | getWinner  | 
| Get Sheep Count    | getSheep  | 
| Get Wolves Count    | getWolves  | 
| Get Total Sheep Pool Balance    | getSheepPoolBalance  | 
| Get Total Wolf Pool Balance    | getWolfPoolBalance  | 
| Get User's Investment in Sheep Pool    | getSheepBalance  | 
| Get User's Investment in Wolf Pool    | getWolfBalance  | 
| Get User's Accumulated Rewards    | getReward  | 
| Get Total cETH Balance of the Contract    | getCTokenBalance  | 

#### Flowchart
![FlowChart](https://github.com/scwang1994/Grassland-War/blob/1034ec925199df6a364d622c861b7569b87de2ca/Grassland-War.png)

### Development
The contract and testing of this game are conducted on the main network. If you wish to perform testing on the GOERLI test network, the following adjustments need to be made:

1. ./src/GrasslandWar.sol
* MAINNET
```
    constructor() payable {
        comptroller = Comptroller(0x3d9819210A31b4961b30EF54bE2aeD79B9c9Cd3B);
        cEther = CEther(payable(0x4Ddc2D193948926D02f9B1fE9e1daa0718270ED5));
        owner = msg.sender;
    }
```
    
* GOERLI

```solidity
    constructor() payable {
        comptroller = Comptroller(0x627EA49279FD0dE89186A58b8758aD02B6Be2867);
        cEther = CEther(payable(0x20572e4c090f15667cF7378e16FaD2eA0e2f3EfF));
        owner = msg.sender;
    }
```
2. ./test/GrasslandWar.t

* `blocknum`、`vm.roll`
 
* MAINNET
``` .sol
    string memory rpc = vm.envString("MAINNET_RPC_URL");
```
    
* GOERLI
```solidity
    string memory rpc = vm.envString("GOERLI_RPC_URL");
```
