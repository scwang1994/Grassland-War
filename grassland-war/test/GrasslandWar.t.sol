// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.17;

import "forge-std/Test.sol";
import "../src/GrassLandWar.sol";

contract GrassLandWarTest is Test {
    GrassLandWar gameContract;
    address public owner; // owner
    address public player1; // sheep1
    address public player2; // sheep2
    address public player3; // sheep3
    address public player4; // wolf1
    address public player5; // wolf2
    uint initAmount = 10 ether;

    function setUp() public {
        // fork maninnet
        uint256 blocknum = 12299047;
        string memory rpc = vm.envString("MAINNET_RPC_URL");
        vm.createSelectFork(rpc, blocknum);
        assertEq(block.number, blocknum);

        owner = makeAddr("Owner");
        vm.startPrank(owner);
        gameContract = new GrassLandWar();
        vm.stopPrank();
        player1 = makeAddr("Player1");
        player2 = makeAddr("Player2");
        player3 = makeAddr("Player3");
        player4 = makeAddr("Player4");
        player5 = makeAddr("Player5");

        // vm.deal(address(gameContract), initAmount); // the game contract init balance
        vm.deal(player1, initAmount); // player1 init balance
        vm.deal(player2, initAmount); // player2 init balance
        vm.deal(player3, initAmount); // player3 init balance
        vm.deal(player4, initAmount); // player4 init balance
        vm.deal(player5, initAmount); // player5 init balance
    }

    function test_InitBalance() public {
        // assertEq(address(gameContract).balance, initAmount);
        assertEq(player1.balance, initAmount);
        assertEq(player2.balance, initAmount);
        assertEq(player3.balance, initAmount);
        assertEq(player4.balance, initAmount);
        assertEq(player5.balance, initAmount);
    }

    function test_JoinSheepPool() public {
        vm.startPrank(player1);

        // check sheep balance = 0
        require(
            gameContract.getSheepBalance() == 0,
            "unexpected failure before sheep balance init"
        );
        // check cETH balance = 0
        require(
            gameContract.getCTokenBalance() == 0,
            "unexpected failure before cETH balance init"
        );
        // check winner = 0
        require(
            gameContract.getWinner() == 0,
            "unexpected failure before winner init"
        );

        uint depositAmount = 2 ether;
        gameContract.joinSheepPool{value: depositAmount}();

        // test sheep balance change
        assertEq(gameContract.getSheepBalance(), depositAmount);
        // test cETH balance change
        assertGt(gameContract.getCTokenBalance(), 0); // 9979492945
        // test winner change
        assertEq(gameContract.getWinner(), 1);

        vm.stopPrank();
    }

    function test_JoinWolfPool() public {
        vm.startPrank(player4);

        // check wolf balance = 0
        require(
            gameContract.getWolfBalance() == 0,
            "unexpected failure before wolf balance init"
        );
        // check cETH balance = 0
        require(
            gameContract.getCTokenBalance() == 0,
            "unexpected failure before cETH balance init"
        );
        // check winner = 0
        require(
            gameContract.getWinner() == 0,
            "unexpected failure before winner init"
        );

        uint depositAmount = 1 ether;
        gameContract.joinWolfPool{value: depositAmount}();

        // test wolf balance change
        assertEq(gameContract.getWolfBalance(), depositAmount * 3);
        // test cETH balance change
        assertGt(gameContract.getCTokenBalance(), 0); // 4989746472
        // test winner change
        assertEq(gameContract.getWinner(), 2);

        vm.stopPrank();
    }

    function test_LeaveSheepPool() public {
        vm.startPrank(player1);

        // join sheep pool first
        uint depositAmount = 2 ether;
        gameContract.joinSheepPool{value: depositAmount}();

        // get player1 balace in this contract
        uint withdrawAmount = gameContract.getSheepBalance();
        // check withdrawAmount > 0
        require(withdrawAmount > 0, "insufficient amount");
        // check balance = initAmount - depositAmount
        require(
            player1.balance == initAmount - depositAmount,
            "incorrect amount"
        );
        // withdraw all amount from this contract
        gameContract.leaveSheepPool(withdrawAmount);
        // test player1 balance > initAmount - depositAmount
        assertGt(player1.balance, initAmount - depositAmount); // but smaller than before, correct?
        // test sheep balance change
        assertEq(gameContract.getSheepBalance(), 0);

        // console.log("player1 balance = %s", player1.balance);

        vm.stopPrank();
    }

    function test_LeaveWolfPool() public {
        vm.startPrank(player4);

        // join wolf pool first
        uint depositAmount = 1 ether;
        gameContract.joinWolfPool{value: depositAmount}();

        // get player1 balace in this contract
        uint withdrawAmount = gameContract.getWolfBalance();

        // check withdrawAmount > 0
        require(withdrawAmount > 0, "insufficient amount");
        // check balance = initAmount - depositAmount
        require(
            player4.balance == initAmount - depositAmount,
            "incorrect amount"
        );
        // withdraw all amount from this contract
        gameContract.leaveWolfPool(withdrawAmount);
        // test player4 balance > initAmount - depositAmount
        assertGt(player4.balance, initAmount - depositAmount);
        // test wolf balance change
        assertEq(gameContract.getWolfBalance(), 0);

        // console.log("player4 balance = %s", player4.balance);

        vm.stopPrank();
    }

    function test_PickWinner_Case_1_Sheep() public {
        uint depositAmountSheep = 3 ether;
        uint depositAmountWolf = 1 ether;

        vm.startPrank(player1);
        gameContract.joinSheepPool{value: depositAmountSheep}();
        vm.stopPrank();

        vm.startPrank(player2);
        gameContract.joinSheepPool{value: depositAmountSheep}();
        vm.stopPrank();

        vm.startPrank(player3);
        gameContract.joinSheepPool{value: depositAmountSheep}();
        vm.stopPrank();

        vm.startPrank(player4);
        gameContract.joinWolfPool{value: depositAmountWolf}();
        vm.stopPrank();

        vm.startPrank(player5);
        gameContract.joinWolfPool{value: depositAmountWolf}();
        vm.stopPrank();

        // check sheepPoolBalance = 9 eth;
        require(
            gameContract.getSheepPoolBalance() == 9 ether,
            "insufficient sheep pool amount"
        );
        // check wolfPoolBalance = 6 eth;
        require(
            gameContract.getWolfPoolBalance() == 6 ether,
            "insufficient wolf pool amount"
        );

        // roll to end time
        vm.warp(block.timestamp + 7 days + 1);
        vm.roll(13500000);

        // pick winner
        uint winner = gameContract.pickWinner();
        // console.log("winner is : %s", winner);

        vm.startPrank(player1);
        assertGt(gameContract.getReward(), 0);
        vm.stopPrank();

        vm.startPrank(player2);
        assertGt(gameContract.getReward(), 0);
        vm.stopPrank();

        vm.startPrank(player3);
        assertGt(gameContract.getReward(), 0);
        vm.stopPrank();

        vm.startPrank(player4);
        assertEq(gameContract.getReward(), 0);
        vm.stopPrank();

        vm.startPrank(player5);
        assertEq(gameContract.getReward(), 0);
        vm.stopPrank();
    }

    function test_PickWinner_Case_2_Wolf() public {
        uint depositAmountSheep = 1 ether;
        uint depositAmountWolf = 1 ether;

        vm.startPrank(player1);
        gameContract.joinSheepPool{value: depositAmountSheep}();
        vm.stopPrank();

        vm.startPrank(player2);
        gameContract.joinSheepPool{value: depositAmountSheep}();
        vm.stopPrank();

        vm.startPrank(player3);
        gameContract.joinSheepPool{value: depositAmountSheep}();
        vm.stopPrank();

        vm.startPrank(player4);
        gameContract.joinWolfPool{value: depositAmountWolf}();
        vm.stopPrank();

        vm.startPrank(player5);
        gameContract.joinWolfPool{value: depositAmountWolf}();
        vm.stopPrank();

        // check sheepPoolBalance = 3 eth;
        require(
            gameContract.getSheepPoolBalance() == 3 ether,
            "insufficient sheep pool amount"
        );
        // check wolfPoolBalance = 6 eth;
        require(
            gameContract.getWolfPoolBalance() == 6 ether,
            "insufficient wolf pool amount"
        );

        // roll to end time
        vm.warp(block.timestamp + 7 days + 1);
        vm.roll(13500000);

        // pick winner
        uint winner = gameContract.pickWinner();
        // console.log("winner is : %s", winner);

        vm.startPrank(player1);
        assertEq(gameContract.getReward(), 0);
        vm.stopPrank();

        vm.startPrank(player2);
        assertEq(gameContract.getReward(), 0);
        vm.stopPrank();

        vm.startPrank(player3);
        assertEq(gameContract.getReward(), 0);
        vm.stopPrank();

        vm.startPrank(player4);
        assertGt(gameContract.getReward(), 0);
        vm.stopPrank();

        vm.startPrank(player5);
        assertEq(gameContract.getReward(), 0);
        vm.stopPrank();
    }

    function test_PickWinner_Case_3_Balance_Equal() public {
        uint depositAmountSheep = 2 ether;
        uint depositAmountWolf = 1 ether;

        vm.startPrank(player1);
        gameContract.joinSheepPool{value: depositAmountSheep}();
        vm.stopPrank();

        vm.startPrank(player2);
        gameContract.joinSheepPool{value: depositAmountSheep}();
        vm.stopPrank();

        vm.startPrank(player3);
        gameContract.joinSheepPool{value: depositAmountSheep}();
        vm.stopPrank();

        vm.startPrank(player4);
        gameContract.joinWolfPool{value: depositAmountWolf}();
        vm.stopPrank();

        vm.startPrank(player5);
        gameContract.joinWolfPool{value: depositAmountWolf}();
        vm.stopPrank();

        // check sheepPoolBalance = 6 eth;
        require(
            gameContract.getSheepPoolBalance() == 6 ether,
            "insufficient sheep pool amount"
        );
        // check wolfPoolBalance = 6 eth;
        require(
            gameContract.getWolfPoolBalance() == 6 ether,
            "insufficient wolf pool amount"
        );

        // roll to end time
        vm.warp(block.timestamp + 7 days + 1);
        vm.roll(13500000);

        // pick winner
        uint winner = gameContract.pickWinner();
        // console.log("winner is : %s", winner);
        assertEq(winner, 1);
    }

    function test_PickWinner_Case_4_No_Wolf() public {
        uint depositAmountSheep = 1 ether;

        vm.startPrank(player1);
        gameContract.joinSheepPool{value: depositAmountSheep}();
        vm.stopPrank();

        vm.startPrank(player2);
        gameContract.joinSheepPool{value: depositAmountSheep}();
        vm.stopPrank();

        // check sheepPoolBalance = 2 eth;
        require(
            gameContract.getSheepPoolBalance() == 2 ether,
            "insufficient sheep pool amount"
        );
        // check wolfPoolBalance = 0 eth;
        require(
            gameContract.getWolfPoolBalance() == 0 ether,
            "insufficient wolf pool amount"
        );

        // roll to end time
        vm.warp(block.timestamp + 7 days + 1);
        vm.roll(13500000);

        // pick winner
        uint winner = gameContract.pickWinner();
        // console.log("winner is : %s", winner);
        assertEq(winner, 3);
    }

    function test_PickWinner_Case_5_One_Wolf() public {
        uint depositAmountSheep = 2 ether;
        uint depositAmountWolf = 1 ether;

        vm.startPrank(player1);
        gameContract.joinSheepPool{value: depositAmountSheep}();
        vm.stopPrank();

        vm.startPrank(player2);
        gameContract.joinSheepPool{value: depositAmountSheep}();
        vm.stopPrank();

        vm.startPrank(player3);
        gameContract.joinSheepPool{value: depositAmountSheep}();
        vm.stopPrank();

        vm.startPrank(player4);
        gameContract.joinWolfPool{value: depositAmountWolf}();
        vm.stopPrank();

        // check sheepPoolBalance = 6 eth;
        require(
            gameContract.getSheepPoolBalance() == 6 ether,
            "insufficient sheep pool amount"
        );
        // check wolfPoolBalance = 3 eth;
        require(
            gameContract.getWolfPoolBalance() == 3 ether,
            "insufficient wolf pool amount"
        );

        // roll to end time
        vm.warp(block.timestamp + 7 days + 1);
        vm.roll(13500000);

        // pick winner
        uint winner = gameContract.pickWinner();
        // console.log("winner is : %s", winner);
        assertEq(winner, 2);
    }

    function test_Leave_SheepPool_Before_PickWinner_Case_1_Sheep_Win() public {
        uint depositAmountSheep = 3 ether;
        uint depositAmountWolf = 1 ether;

        vm.startPrank(player1);
        gameContract.joinSheepPool{value: depositAmountSheep}();
        vm.stopPrank();

        vm.startPrank(player2);
        gameContract.joinSheepPool{value: depositAmountSheep}();
        vm.stopPrank();

        vm.startPrank(player3);
        gameContract.joinSheepPool{value: depositAmountSheep}();
        vm.stopPrank();

        vm.startPrank(player4);
        gameContract.joinWolfPool{value: depositAmountWolf}();
        vm.stopPrank();

        vm.startPrank(player5);
        gameContract.joinWolfPool{value: depositAmountWolf}();
        vm.stopPrank();

        // check sheepPoolBalance = 9 eth;
        require(
            gameContract.getSheepPoolBalance() == 9 ether,
            "insufficient sheep pool amount"
        );
        // check wolfPoolBalance = 6 eth;
        require(
            gameContract.getWolfPoolBalance() == 6 ether,
            "insufficient wolf pool amount"
        );

        // roll to game duration-time
        // vm.warp(block.timestamp + 3 days);
        vm.roll(13000000);

        vm.startPrank(player1);
        uint withdrawAmount = gameContract.getSheepBalance();
        gameContract.leaveSheepPool(withdrawAmount);
        vm.stopPrank();

        // roll to end time
        vm.warp(block.timestamp + 7 days + 1);
        vm.roll(13500000);

        // pick winner
        uint winner = gameContract.pickWinner();
        // console.log("winner is : %s", winner);

        vm.startPrank(player1);
        assertEq(gameContract.getReward(), 0);
        vm.stopPrank();

        vm.startPrank(player2);
        assertGt(gameContract.getReward(), 0);
        vm.stopPrank();

        vm.startPrank(player3);
        assertGt(gameContract.getReward(), 0);
        vm.stopPrank();

        vm.startPrank(player4);
        assertEq(gameContract.getReward(), 0);
        vm.stopPrank();

        vm.startPrank(player5);
        assertEq(gameContract.getReward(), 0);
        vm.stopPrank();
    }

    function test_Leave_SheepPool_Before_PickWinner_Case_2_Wolf_Win() public {
        uint depositAmountSheep = 3 ether;
        uint depositAmountWolf = 2 ether;

        vm.startPrank(player1);
        gameContract.joinSheepPool{value: depositAmountSheep}();
        vm.stopPrank();

        vm.startPrank(player2);
        gameContract.joinSheepPool{value: depositAmountSheep}();
        vm.stopPrank();

        vm.startPrank(player3);
        gameContract.joinSheepPool{value: depositAmountSheep}();
        vm.stopPrank();

        vm.startPrank(player4);
        gameContract.joinWolfPool{value: depositAmountWolf}();
        vm.stopPrank();

        vm.startPrank(player5);
        gameContract.joinWolfPool{value: depositAmountWolf}();
        vm.stopPrank();

        // check sheepPoolBalance = 9 eth;
        require(
            gameContract.getSheepPoolBalance() == 9 ether,
            "insufficient sheep pool amount"
        );
        // check wolfPoolBalance = 12 eth;
        require(
            gameContract.getWolfPoolBalance() == 12 ether,
            "insufficient wolf pool amount"
        );

        // roll to game duration-time
        // vm.warp(block.timestamp + 3 days);
        vm.roll(13000000);

        vm.startPrank(player1);
        uint withdrawAmount = gameContract.getSheepBalance();
        gameContract.leaveSheepPool(withdrawAmount);
        vm.stopPrank();

        vm.startPrank(player2);
        uint withdrawAmount2 = gameContract.getSheepBalance();
        gameContract.leaveSheepPool(withdrawAmount2);
        vm.stopPrank();

        // roll to end time
        vm.warp(block.timestamp + 7 days + 1);
        vm.roll(13500000);

        // pick winner
        uint winner = gameContract.pickWinner();
        // console.log("winner is : %s", winner);

        vm.startPrank(player1);
        assertEq(gameContract.getReward(), 0);
        vm.stopPrank();

        vm.startPrank(player2);
        assertEq(gameContract.getReward(), 0);
        vm.stopPrank();

        vm.startPrank(player3);
        assertEq(gameContract.getReward(), 0);
        vm.stopPrank();

        vm.startPrank(player4);
        assertGt(gameContract.getReward(), 0);
        vm.stopPrank();

        vm.startPrank(player5);
        assertEq(gameContract.getReward(), 0);
        vm.stopPrank();
    }

    function test_Leave_WolfPool_Before_PickWinner_Case_3_Sheep_Win() public {
        uint depositAmountSheep = 3 ether;
        uint depositAmountWolf = 1 ether;

        vm.startPrank(player1);
        gameContract.joinSheepPool{value: depositAmountSheep}();
        vm.stopPrank();

        vm.startPrank(player2);
        gameContract.joinSheepPool{value: depositAmountSheep}();
        vm.stopPrank();

        vm.startPrank(player3);
        gameContract.joinSheepPool{value: depositAmountSheep}();
        vm.stopPrank();

        vm.startPrank(player4);
        gameContract.joinWolfPool{value: depositAmountWolf}();
        vm.stopPrank();

        vm.startPrank(player5);
        gameContract.joinWolfPool{value: depositAmountWolf}();
        vm.stopPrank();

        // check sheepPoolBalance = 9 eth;
        require(
            gameContract.getSheepPoolBalance() == 9 ether,
            "insufficient sheep pool amount"
        );
        // check wolfPoolBalance = 6 eth;
        require(
            gameContract.getWolfPoolBalance() == 6 ether,
            "insufficient wolf pool amount"
        );

        // roll to game duration-time
        // vm.warp(block.timestamp + 3 days);
        vm.roll(13000000);

        // vm.startPrank(player4);
        // uint withdrawAmount = gameContract.getWolfBalance();

        // console.log("withdrawAmount is %s", withdrawAmount);

        // gameContract.leaveWolfPool(withdrawAmount);
        // vm.stopPrank();

        // roll to end time
        vm.warp(block.timestamp + 7 days + 1);
        vm.roll(13500000);

        // pick winner
        uint winner = gameContract.pickWinner();
        // console.log("winner is : %s", winner);

        vm.startPrank(player1);
        assertGt(gameContract.getReward(), 0);
        vm.stopPrank();

        vm.startPrank(player2);
        assertGt(gameContract.getReward(), 0);
        vm.stopPrank();

        vm.startPrank(player3);
        assertGt(gameContract.getReward(), 0);
        vm.stopPrank();

        vm.startPrank(player4);
        assertEq(gameContract.getReward(), 0);
        vm.stopPrank();

        vm.startPrank(player5);
        assertEq(gameContract.getReward(), 0);
        vm.stopPrank();
    }

    function test_Leave_WolfPool_Before_PickWinner_Case_4_Wolf_Win() public {
        uint depositAmountSheep = 1 ether;
        uint depositAmountWolf = 2 ether;

        vm.startPrank(player1);
        gameContract.joinSheepPool{value: depositAmountSheep}();
        vm.stopPrank();

        vm.startPrank(player2);
        gameContract.joinSheepPool{value: depositAmountSheep}();
        vm.stopPrank();

        vm.startPrank(player3);
        gameContract.joinSheepPool{value: depositAmountSheep}();
        vm.stopPrank();

        vm.startPrank(player4);
        gameContract.joinWolfPool{value: depositAmountWolf}();
        vm.stopPrank();

        vm.startPrank(player5);
        gameContract.joinWolfPool{value: depositAmountWolf}();
        vm.stopPrank();

        // check sheepPoolBalance = 3 eth;
        require(
            gameContract.getSheepPoolBalance() == 3 ether,
            "insufficient sheep pool amount"
        );
        // check wolfPoolBalance = 12 eth;
        require(
            gameContract.getWolfPoolBalance() == 12 ether,
            "insufficient wolf pool amount"
        );

        // roll to game duration-time
        // vm.warp(block.timestamp + 3 days);
        vm.roll(13000000);

        // vm.startPrank(player4);
        // uint withdrawAmount = gameContract.getWolfBalance();

        // console.log("withdrawAmount is %s", withdrawAmount);

        // gameContract.leaveWolfPool(withdrawAmount);
        // vm.stopPrank();

        // roll to end time
        vm.warp(block.timestamp + 7 days + 1);
        vm.roll(13500000);

        // pick winner
        uint winner = gameContract.pickWinner();
        // console.log("winner is : %s", winner);

        vm.startPrank(player1);
        assertEq(gameContract.getReward(), 0);
        vm.stopPrank();

        vm.startPrank(player2);
        assertEq(gameContract.getReward(), 0);
        vm.stopPrank();

        vm.startPrank(player3);
        assertEq(gameContract.getReward(), 0);
        vm.stopPrank();

        vm.startPrank(player4);
        assertGt(gameContract.getReward(), 0);
        vm.stopPrank();

        vm.startPrank(player5);
        assertEq(gameContract.getReward(), 0);
        vm.stopPrank();
    }

    function test_Claim_By_Sheep() public {
        uint depositAmountSheep = 3 ether;
        uint depositAmountWolf = 1 ether;

        vm.startPrank(player1);
        gameContract.joinSheepPool{value: depositAmountSheep}();
        vm.stopPrank();

        vm.startPrank(player2);
        gameContract.joinSheepPool{value: depositAmountSheep}();
        vm.stopPrank();

        vm.startPrank(player3);
        gameContract.joinSheepPool{value: depositAmountSheep}();
        vm.stopPrank();

        vm.startPrank(player4);
        gameContract.joinWolfPool{value: depositAmountWolf}();
        vm.stopPrank();

        vm.startPrank(player5);
        gameContract.joinWolfPool{value: depositAmountWolf}();
        vm.stopPrank();

        // check sheepPoolBalance = 9 eth;
        require(
            gameContract.getSheepPoolBalance() == 9 ether,
            "insufficient sheep pool amount"
        );
        // check wolfPoolBalance = 6 eth;
        require(
            gameContract.getWolfPoolBalance() == 6 ether,
            "insufficient wolf pool amount"
        );

        // roll to end time
        vm.warp(block.timestamp + 7 days + 1);
        vm.roll(13500000);

        // pick winner
        uint winner = gameContract.pickWinner();
        console.log("winner is : %s", winner);

        require(player1.balance == 7 ether, "incorrect amount");
        vm.startPrank(player1);
        gameContract.claim();
        vm.stopPrank();
        assertGt(player1.balance, 7 ether);
        console.log(player1.balance);
    }

    function test_Claim_By_Wolf() public {
        uint depositAmountSheep = 1 ether;
        uint depositAmountWolf = 4 ether;

        vm.startPrank(player1);
        gameContract.joinSheepPool{value: depositAmountSheep}();
        vm.stopPrank();

        vm.startPrank(player2);
        gameContract.joinSheepPool{value: depositAmountSheep}();
        vm.stopPrank();

        vm.startPrank(player3);
        gameContract.joinSheepPool{value: depositAmountSheep}();
        vm.stopPrank();

        vm.startPrank(player4);
        gameContract.joinWolfPool{value: depositAmountWolf}();
        vm.stopPrank();

        vm.startPrank(player5);
        gameContract.joinWolfPool{value: depositAmountWolf}();
        vm.stopPrank();

        // check sheepPoolBalance = 3 eth;
        require(
            gameContract.getSheepPoolBalance() == 3 ether,
            "insufficient sheep pool amount"
        );
        // check wolfPoolBalance = 24 eth;
        require(
            gameContract.getWolfPoolBalance() == 24 ether,
            "insufficient wolf pool amount"
        );

        // roll to end time
        vm.warp(block.timestamp + 7 days + 1);
        vm.roll(13500000);

        // pick winner
        uint winner = gameContract.pickWinner();
        console.log("winner is : %s", winner);

        require(player4.balance == 6 ether, "incorrect amount");
        vm.startPrank(player4);
        gameContract.claim();
        vm.stopPrank();
        assertGt(player4.balance, 6 ether);
        console.log(player4.balance);
    }

    function test_Claim_By_Owner() public {
        uint depositAmountSheep = 4 ether;

        vm.startPrank(player1);
        gameContract.joinSheepPool{value: depositAmountSheep}();
        vm.stopPrank();

        vm.startPrank(player2);
        gameContract.joinSheepPool{value: depositAmountSheep}();
        vm.stopPrank();

        vm.startPrank(player3);
        gameContract.joinSheepPool{value: depositAmountSheep}();
        vm.stopPrank();

        // check sheepPoolBalance = 12 eth;
        require(
            gameContract.getSheepPoolBalance() == 12 ether,
            "insufficient sheep pool amount"
        );
        // check wolfPoolBalance = 6 eth;
        require(
            gameContract.getWolfPoolBalance() == 0 ether,
            "insufficient wolf pool amount"
        );

        // roll to end time
        vm.warp(block.timestamp + 7 days + 1);
        vm.roll(13500000);

        // pick winner
        uint winner = gameContract.pickWinner();
        console.log("winner is : %s", winner);

        require(owner.balance == 0 ether, "incorrect amount");
        vm.startPrank(owner);
        gameContract.claim();
        vm.stopPrank();
        assertGt(owner.balance, 0 ether);
        console.log(owner.balance);
    }

    function test_Game_2() public {
        uint depositAmountSheep = 3 ether;
        uint depositAmountWolf = 1 ether;

        vm.startPrank(player1);
        gameContract.joinSheepPool{value: depositAmountSheep}();
        vm.stopPrank();

        vm.startPrank(player2);
        gameContract.joinSheepPool{value: depositAmountSheep}();
        vm.stopPrank();

        vm.startPrank(player3);
        gameContract.joinSheepPool{value: depositAmountSheep}();
        vm.stopPrank();

        vm.startPrank(player4);
        gameContract.joinWolfPool{value: depositAmountWolf}();
        vm.stopPrank();

        vm.startPrank(player5);
        gameContract.joinWolfPool{value: depositAmountWolf}();
        vm.stopPrank();

        // check sheepPoolBalance = 9 eth;
        require(
            gameContract.getSheepPoolBalance() == 9 ether,
            "insufficient sheep pool amount"
        );
        // check wolfPoolBalance = 6 eth;
        require(
            gameContract.getWolfPoolBalance() == 6 ether,
            "insufficient wolf pool amount"
        );

        // roll to end time
        vm.warp(block.timestamp + 7 days + 1);
        vm.roll(13500000);

        // pick game#1 winner
        uint game1Winner = gameContract.pickWinner();
        console.log("the game#1 winner is : %s", game1Winner);

        require(game1Winner == 1, "incorrect game#1 winner");
        vm.startPrank(player4);
        gameContract.joinWolfPool{value: depositAmountSheep}();
        vm.stopPrank();

        // roll to end time
        vm.warp(block.timestamp + 7 days + 1);
        vm.roll(14000000);

        // pick game#2 winner
        uint game2Winner = gameContract.pickWinner();
        console.log("the game#2 winner is : %s", game2Winner);
    }
}
