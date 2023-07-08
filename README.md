# GrasslandWar

In this contract, players can deposit ETH and choose to join either the `Sheep Pool` or the `Wolf Pool`. When joining, ETH will be transferred to Compound to earn interest, and at the end of each game, the dominant species will receive interest earnings. The detailed gameplay is as follows:

### Gameplay

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

### Flowchart
![FlowChart](https://github.com/scwang1994/Grassland-War/blob/1034ec925199df6a364d622c861b7569b87de2ca/Grassland-War.png)
