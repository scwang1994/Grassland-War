pragma solidity ^0.8.17;

import "openzeppelin-contracts/contracts/token/ERC20/IERC20.sol";
import "openzeppelin-contracts/contracts/token/ERC20/utils/SafeERC20.sol";
import "compound-protocol/contracts/CErc20.sol";
import "compound-protocol/contracts/Comptroller.sol";

// sheep, wolves 會越來越肥

contract PoolGame {
    address public owner;

    uint8 public winner;
    address[] public sheep;
    address[] public wolves;
    uint public sheepPoolBalance;
    uint public wolfPoolBalance;

    mapping(address => uint) public sheepBalance;
    mapping(address => uint) public wolfBalance;
    mapping(address => uint) public reward;

    uint public endTime;

    event Withdrawal(address indexed recipient, uint256 amount);
    event Deposit(address indexed depositor, uint8 group, uint256 amount);
    event WithdrawalReward(address indexed recipient, uint256 amount);

    Comptroller public comptroller;
    CEther public cEther;

    constructor(address _comptroller, address _cEther) {
        comptroller = Comptroller(_comptroller);
        cEther = CEther(payable(_cEther));
        owner = msg.sender;
    }

    function joinSheepPool() external payable {
        require(msg.value > 0, "You must deposit some ETH.");
        // if not in sheep list, added sender
        if (sheepBalance[msg.sender] == 0) {
            sheep.push(msg.sender);
        }

        // updated sender(sheep) balance
        sheepBalance[msg.sender] += msg.value;
        uint sheepPoolBalanceBefore = sheepPoolBalance;
        sheepPoolBalance += msg.value;

        // if this cause sheep pool > wolf pool, update endTime, update winner status
        if (
            sheepPoolBalanceBefore <= wolfPoolBalance &&
            sheepPoolBalance > wolfPoolBalance
        ) {
            _updateEndTime();
            winner = 1;
        }

        _supplyToCompound(msg.value);
    }

    function joinWolfPool() external payable {
        require(msg.value > 0, "You must deposit some ETH.");
        // if not in wolf list, added sender
        if (wolfBalance[msg.sender] == 0) {
            wolves.push(msg.sender);
        }

        // updated sender(wolf) balance (wolf have 3 weight bonus)
        wolfBalance[msg.sender] += msg.value * 3;
        uint wolfPoolBalanceBefore = wolfPoolBalance;
        wolfPoolBalance += msg.value * 3;

        // if this cause wolf pool > sheep pool, update endTime, update winner status
        if (
            wolfPoolBalanceBefore <= sheepPoolBalance &&
            wolfPoolBalance > sheepPoolBalance
        ) {
            _updateEndTime();
            winner = 2;
        }

        _supplyToCompound(msg.value);
    }

    function _supplyToCompound(uint _amount) internal {
        require(_amount > 0, "Invalid amount");

        bool initEnter = false;
        if (getcTokenBalance() == 0) {
            initEnter = true;
        }
        // Mint cEther by supplying Ether to Compound
        cEther.mint{value: _amount}();

        // Enter the market for cEther
        if (initEnter) {
            address[] memory cTokens = new address[](1);
            cTokens[0] = address(cEther);
            uint[] memory errors = comptroller.enterMarkets(cTokens);
            require(errors[0] == 0, "Failed to enter market");
        }

        emit Deposit(msg.sender, 1, msg.value);
    }

    function leaveSheepPool(uint _amount) external {
        require(_amount > 0, "Amount must be greater than 0");
        require(_amount <= sheepBalance[msg.sender], "Insufficient balance");

        sheepBalance[msg.sender] -= _amount;
        uint sheepPoolBalanceBefore = sheepPoolBalance;
        sheepPoolBalance -= _amount;

        if (
            sheepPoolBalanceBefore >= wolfPoolBalance &&
            sheepPoolBalance < wolfPoolBalance
        ) {
            _updateEndTime();
            winner = 2;
        }

        // Transfer the amount to the recipient"s address
        _redeemFromCompound(_amount);
    }

    function leaveWolfPool(uint _amount) external {
        require(_amount > 0, "Amount must be greater than 0");
        require(_amount <= wolfBalance[msg.sender], "Insufficient balance");

        wolfBalance[msg.sender] -= _amount * 3;
        uint wolfPoolBalanceBefore = wolfPoolBalance;
        sheepPoolBalance -= _amount * 3;

        if (
            wolfPoolBalanceBefore >= sheepPoolBalance &&
            wolfPoolBalance < sheepPoolBalance
        ) {
            _updateEndTime();
            winner = 1;
        }

        // Transfer the amount to the recipient"s address
        _redeemFromCompound(_amount);
    }

    function _redeemFromCompound(uint _cTokenAmount) internal payable {
        require(_cTokenAmount > 0, "Invalid amount");

        // beforeRedeem
        uint beforeRedeem = address(this).balance;
        // Redeem cEther from Compound
        uint errorLog = cEther.redeem(_cTokenAmount);
        require(errorLog == 0, "Failed to redeem cEther");

        // Transfer redeemed Ether to the caller
        uint redeemedAmount = address(this).balance - beforeRedeem;
        payable(msg.sender).transfer(redeemedAmount);
        emit Withdrawal(msg.sender, _amount);
    }

    function getPrize() public returns (uint) {
        require(block.timestamp >= endTime, "Game is still in progress.");
        require(winner != 0, "There is no winner yet.");

        // farmingReward
        uint farmingReward;

        // check status
        if (wolves.length == 0) {
            winner = 3; // contract win
        } else if (wolves.length == 1) {
            winner = 2; // wolf win
        }

        if (winner == 1) {
            // call sheep win prize
            _updateSheepReward(farmingReward);
        } else if (winner == 2) {
            // call wolf win prize
            _updateWolfReward(farmingReward);
        }

        // transfer prize
        _updateEndTime(); // update to new game

        return winner;
    }

    function _updateSheepReward(uint _farmingReward) internal {
        address[] memory sheepWinner = sheep;
        uint sheepTotalBalance = sheepPoolBalance;

        // may cause risk
        for (uint256 i = 0; i < sheepWinner.length; i++) {
            reward[sheepWinner[i]] +=
                (sheepBalance[sheepWinner[i]] / sheepTotalBalance) *
                _farmingReward;
        }
    }

    function _updateWolfReward(uint _farmingReward) internal {
        address[] memory wolvesWinner = wolves;
        address wolfWinner;
        uint winnerBalance;

        // may cause risk
        for (uint256 i = 0; i < wolvesWinner.length; i++) {
            if (wolfBalance[wolvesWinner[i]] > winnerBalance) {
                wolfWinner = wolvesWinner[i];
                winnerBalance = wolfBalance[wolvesWinner[i]];
            }
            reward[wolfWinner] += _farmingReward;
        }
    }

    function _updateEndTime() internal {
        endTime = block.timestamp + 7 days;
    }

    function claim(uint _amount) external {
        require(_amount > 0, "Amount must be greater than 0");
        require(_amount <= reward[msg.sender], "Insufficient reward balance");

        reward[msg.sender] -= _amount;

        // Transfer the amount to the recipient"s address
        payable(msg.sender).transfer(_amount);
        emit WithdrawalReward(msg.sender, _amount);
    }

    function getcTokenBalance() public view returns (uint) {
        return cEther.balanceOf(address(this));
    }
}
