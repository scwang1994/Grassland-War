pragma solidity 0.8.17;

import "forge-std/Test.sol";
import "openzeppelin-contracts/contracts/token/ERC20/IERC20.sol";
import "openzeppelin-contracts/contracts/token/ERC20/utils/SafeERC20.sol";
import "compound-protocol/contracts/CEther.sol";
import "compound-protocol/contracts/Comptroller.sol";

contract GrassLandWar {
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
    event InterestEarned(address account, uint256 amount);

    Comptroller public comptroller;
    CEther public cEther;

    constructor() payable {
        comptroller = Comptroller(0x3d9819210A31b4961b30EF54bE2aeD79B9c9Cd3B);
        cEther = CEther(payable(0x4Ddc2D193948926D02f9B1fE9e1daa0718270ED5));
        owner = msg.sender;
    }

    function joinSheepPool() external payable {
        require(msg.value > 0, "You must deposit some ETH.");
        require(endTime == 0 || block.timestamp < endTime, "Game is ended");
        require(sheep.length < 10, "Too many sheep");

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
        // if (sheep.length == 1) {
        //     _updateEndTime();
        //     winner = 1;
        // }

        _supplyToCompound(msg.value);
    }

    function joinWolfPool() external payable {
        require(msg.value > 0, "You must deposit some ETH.");
        require(endTime == 0 || block.timestamp < endTime, "Game is ended");
        require(wolves.length < 10, "Too many wolves");

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
        // if (wolves.length == 1) {
        //     _updateEndTime();
        //     winner = 2;
        // }

        _supplyToCompound(msg.value);
    }

    function _supplyToCompound(uint _amount) internal {
        require(_amount > 0, "Invalid amount");

        bool initEnter = false;
        if (getCTokenBalance() == 0) {
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

        uint sheepPoolBalanceBefore = sheepPoolBalance;
        uint _cTokenAmount = (getCTokenBalance() * _amount) /
            (sheepPoolBalanceBefore + wolfPoolBalance / 3);

        sheepBalance[msg.sender] -= _amount;
        sheepPoolBalance -= _amount;

        if (
            sheepPoolBalanceBefore >= wolfPoolBalance &&
            sheepPoolBalance < wolfPoolBalance
        ) {
            _updateEndTime();
            winner = 2;
        }
        // if (sheep.length == 1) {
        //     _updateEndTime();
        //     winner = 1;
        // }

        // Transfer the amount to the recipient"s address
        uint redeemedAmount = _redeemFromCompound(_cTokenAmount);
        payable(msg.sender).transfer(redeemedAmount);
        emit Withdrawal(msg.sender, redeemedAmount);
    }

    function leaveWolfPool(uint _amount) external {
        require(_amount > 0, "Amount must be greater than 0");
        require(_amount <= wolfBalance[msg.sender], "Insufficient balance");

        uint wolfPoolBalanceBefore = wolfPoolBalance;
        uint _cTokenAmount = ((getCTokenBalance() * _amount) / 3) /
            ((wolfPoolBalanceBefore / 3) + sheepPoolBalance);

        wolfBalance[msg.sender] -= _amount;
        wolfPoolBalance -= _amount;

        if (
            wolfPoolBalanceBefore >= sheepPoolBalance &&
            wolfPoolBalance < sheepPoolBalance
        ) {
            _updateEndTime();
            winner = 1;
        }
        // if (wolves.length == 1) {
        //     _updateEndTime();
        //     winner = 2;
        // }

        // Transfer the amount to the recipient"s address
        uint redeemedAmount = _redeemFromCompound(_cTokenAmount);
        payable(msg.sender).transfer(redeemedAmount);
        emit Withdrawal(msg.sender, redeemedAmount);
    }

    function _redeemFromCompound(uint _cTokenAmount) internal returns (uint) {
        require(_cTokenAmount > 0, "Invalid amount");

        // 懲罰性扣除1%資金
        uint newAmount = (_cTokenAmount * 99) / 100;

        // beforeRedeem
        uint beforeRedeem = address(this).balance;
        // Redeem cEther from Compound
        uint errorLog = cEther.redeem(newAmount);
        require(errorLog == 0, "Failed to redeem cEther");

        // Transfer redeemed Ether to the caller
        uint redeemedAmount = address(this).balance - beforeRedeem;

        return redeemedAmount;
    }

    function pickWinner() external payable returns (uint) {
        require(block.timestamp >= endTime, "Game is still in progress.");
        require(winner != 0, "There is no winner yet.");

        uint interestEarned = _claimInterest();
        // console.log("interestEarned is %s", interestEarned);

        // check status
        if (sheep.length == 0 || wolves.length == 0) {
            winner = 3; // contract win
        } else if (sheep.length == 1 && wolves.length != 1) {
            winner = 1; // sheep win
        } else if (wolves.length == 1 && sheep.length != 1) {
            winner = 2; // wolf win
        }

        if (winner == 1) {
            // call sheep win prize
            _updateSheepReward((interestEarned * 98) / 100);
            reward[owner] += ((interestEarned * 2) / 100);
        } else if (winner == 2) {
            // call wolf win prize
            _updateWolfReward((interestEarned * 98) / 100);
            reward[owner] += ((interestEarned * 2) / 100);
        } else {
            reward[owner] += interestEarned;
        }

        // transfer prize
        _updateEndTime(); // update to new game

        return winner;
    }

    function _claimInterest() internal returns (uint) {
        uint cETHBalance = getCTokenBalance();
        require(cETHBalance > 0, "No interest available");

        uint ethBeforeRedeem = address(this).balance;
        uint errorLog = cEther.redeem(cETHBalance);
        require(errorLog == 0, "Failed to redeem cEther");
        uint ethAfterRedeem = address(this).balance;

        uint interestEarned = ethAfterRedeem -
            ethBeforeRedeem -
            (sheepPoolBalance + wolfPoolBalance / 3);

        // mint it back
        _supplyToCompound(ethAfterRedeem - ethBeforeRedeem - interestEarned);

        emit InterestEarned(address(this), interestEarned);
        return interestEarned;
    }

    function _updateSheepReward(uint _farmingReward) internal {
        address[] memory sheepWinner = sheep;
        uint sheepTotalBalance = sheepPoolBalance;

        for (uint256 i = 0; i < sheepWinner.length; i++) {
            reward[sheepWinner[i]] += ((sheepBalance[sheepWinner[i]] *
                _farmingReward) / sheepTotalBalance);
        }
    }

    function _updateWolfReward(uint _farmingReward) internal {
        address[] memory wolvesWinner = wolves;
        address wolfWinner;
        uint winnerBalance;

        for (uint256 i = 0; i < wolvesWinner.length; i++) {
            if (wolfBalance[wolvesWinner[i]] > winnerBalance) {
                wolfWinner = wolvesWinner[i];
                winnerBalance = wolfBalance[wolvesWinner[i]];
            }
        }
        reward[wolfWinner] += _farmingReward;
    }

    function _updateEndTime() internal {
        endTime = block.timestamp + 7 days;
    }

    function claim() external {
        uint amount = reward[msg.sender];

        require(amount > 0, "Amount must be greater than 0");
        reward[msg.sender] = 0;

        // Transfer the amount to the recipient"s address
        payable(msg.sender).transfer(amount);
        emit WithdrawalReward(msg.sender, amount);
    }

    function getEndTime() public view returns (uint) {
        return endTime;
    }

    function getWinner() public view returns (uint) {
        return winner;
    }

    function getSheep() public view returns (uint) {
        return sheep.length;
    }

    function getWolves() public view returns (uint) {
        return wolves.length;
    }

    function getSheepPoolBalance() public view returns (uint) {
        return sheepPoolBalance;
    }

    function getWolfPoolBalance() public view returns (uint) {
        return wolfPoolBalance;
    }

    function getSheepBalance() public view returns (uint) {
        return sheepBalance[msg.sender];
    }

    function getWolfBalance() public view returns (uint) {
        return wolfBalance[msg.sender];
    }

    function getReward() public view returns (uint) {
        return reward[msg.sender];
    }

    function getCTokenBalance() public view returns (uint) {
        return cEther.balanceOf(address(this));
    }

    receive() external payable {}
}
