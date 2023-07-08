# 狼與羊群

在這個合約中，玩家可以存入 ETH 選擇加入 `Sheep Pool` 或 `Wolf Pool`，加入時，ETH 將轉移至 Compound 賺取利息，當每場遊戲時間截止時，優勢物種將可以獲得利息收益。遊戲詳細的玩法如下：

### 架構

#### 玩法
* 玩家選擇加入 `Sheep Pool` 或 `Wolf Pool`，存入 ETH。
* 存入的 ETH 將用於 Compound 賺取利息。
* 在兩個 Pool 中，金額較高的 Pool 將成為優勢池。`Wolf Pool` 計算時享有 3 倍的權重優勢。
* 遊戲進行期間為 7 天，如果 7 天內優勢池未更改，則優勢種群獲勝；如 7 天內優勢池更改，則時間將從七日重新倒數。
* 如果優勢種群結果是 `Sheep Pool`，則所有 `Sheep` 將分享利息。利息分配將根據投入金額進行權重分配， `Wolf` 將沒收利息。
* 如果優勢種群結果是 `Wolf Pool`，則存入金額最高者獨得所有利息。
* 如果時間截止時，`Wolf Pool` 的地址數量為 0，則協議獲勝。
* 如果時間截止時，`Wolf Pool` 的地址數量為 1，則 `Wolf` 將直接獲勝。
* 協議將從每場遊戲結果中獲得 2% 的收入。
* 第二場遊戲將於第一場遊戲結束後立即開始，以此類推...

#### 功能列表
用戶實際操作的功能為加入羊群、離開羊群、加入狼群、離開狼群，以及領取獎勵五項，以下為上述功能、對應函數：
| 功能 | 對應函數 | 
|----------|----------|
| 加入羊群    | joinSheepPool  | 
| 離開羊群    | joinWolfPool  | 
| 加入狼群    | leaveSheepPool  | 
| 離開狼群    | leaveWolfPool  | 
| 領取獎勵    | claim  | 

其餘查詢功能如下：
| 功能 | 對應函數 | 
|----------|----------|
| 查詢此輪遊戲截止時間    | getEndTime  | 
| 查詢目前贏家    | getWinner  | 
| 查詢羊群數量    | getSheep  | 
| 查詢狼群數量    | getWolves  | 
| 查詢羊群池子總量    | getSheepPoolBalance  | 
| 查詢狼群池子總量    | getWolfPoolBalance  | 
| 查詢用戶於羊群的投入額    | getSheepBalance  | 
| 查詢用戶於狼群的投入額    | getWolfBalance  | 
| 查詢用戶累積獎勵    | getReward  | 
| 查詢合約現有 cETH 總量    | getCTokenBalance  | 

#### 流程圖
![FlowChart](https://github.com/scwang1994/Grassland-War/blob/1034ec925199df6a364d622c861b7569b87de2ca/Grassland-War.png)

