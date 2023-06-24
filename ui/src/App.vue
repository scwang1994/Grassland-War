<template>
  <v-app>
    <v-app-bar style="background: black" app :elevation="0">
      <v-icon color="white" large @click="render('home')"
        >mdi-home-circle-outline
      </v-icon>

      <v-spacer></v-spacer>
      <a class="mr-5" style="color: white" @click="render('how-to-play')">
        <!-- href="https://github.com/vuetifyjs/vuetify/releases/latest" -->
        <span>HOW TO PLAY</span>
      </a>
      <v-btn large outlined color="#00896c" dark> Connect wallet </v-btn>
    </v-app-bar>

    <v-container class="setting" fill-height fluid>
      <v-main>
        <router-view />
      </v-main>
      <!-- <button v-if="!connected" @click="connect">Connect wallet</button> -->

      <!-- "callContract" event handler is added -->
      <!-- <button v-if="connected" @click="callWinner">Call winner</button> -->

      <!-- <button v-if="connected" @click="joinSheepPool">Join sheep-pool</button> -->
      <!-- <button v-if="connected" @click="joinWolfPool">Join WolfPool</button> -->
      <!-- displays the result of the contract -->
      <!-- {{ contractResult }} -->
    </v-container>
  </v-app>
</template>

<script>
import Web3 from "web3";
export default {
  name: "App",

  data() {
    return {
      connected: false,
      contractResult: "",
    };
  },
  methods: {
    render(_pathUrl) {
      this.$router.push({ name: _pathUrl });
    },

    connect() {
      let ethereum = window.ethereum;
      if (ethereum) {
        ethereum.request({ method: "eth_requestAccounts" }).then(() => {
          this.connected = true;
        });
      }
    },

    async joinSheepPool() {
      // method for calling the contract method
      let web3 = new Web3(window.ethereum);
      let contractAddress = "0x10De6eB1e244C5542fa1E14aB02393c3431b77DA";

      let abi = JSON.parse(
        `[
	{
		"inputs": [],
		"stateMutability": "nonpayable",
		"type": "constructor"
	},
	{
		"anonymous": false,
		"inputs": [
			{
				"indexed": true,
				"internalType": "address",
				"name": "depositor",
				"type": "address"
			},
			{
				"indexed": false,
				"internalType": "uint8",
				"name": "group",
				"type": "uint8"
			},
			{
				"indexed": false,
				"internalType": "uint256",
				"name": "amount",
				"type": "uint256"
			}
		],
		"name": "Deposit",
		"type": "event"
	},
	{
		"anonymous": false,
		"inputs": [
			{
				"indexed": true,
				"internalType": "address",
				"name": "recipient",
				"type": "address"
			},
			{
				"indexed": false,
				"internalType": "uint256",
				"name": "amount",
				"type": "uint256"
			}
		],
		"name": "Withdrawal",
		"type": "event"
	},
	{
		"anonymous": false,
		"inputs": [
			{
				"indexed": true,
				"internalType": "address",
				"name": "recipient",
				"type": "address"
			},
			{
				"indexed": false,
				"internalType": "uint256",
				"name": "amount",
				"type": "uint256"
			}
		],
		"name": "WithdrawalReward",
		"type": "event"
	},
	{
		"inputs": [
			{
				"internalType": "uint256",
				"name": "amount",
				"type": "uint256"
			}
		],
		"name": "claim",
		"outputs": [],
		"stateMutability": "nonpayable",
		"type": "function"
	},
	{
		"inputs": [],
		"name": "endTime",
		"outputs": [
			{
				"internalType": "uint256",
				"name": "",
				"type": "uint256"
			}
		],
		"stateMutability": "view",
		"type": "function"
	},
	{
		"inputs": [],
		"name": "getPrize",
		"outputs": [
			{
				"internalType": "uint256",
				"name": "",
				"type": "uint256"
			}
		],
		"stateMutability": "nonpayable",
		"type": "function"
	},
	{
		"inputs": [],
		"name": "joinSheepPool",
		"outputs": [],
		"stateMutability": "payable",
		"type": "function"
	},
	{
		"inputs": [],
		"name": "joinWolfPool",
		"outputs": [],
		"stateMutability": "payable",
		"type": "function"
	},
	{
		"inputs": [
			{
				"internalType": "uint256",
				"name": "amount",
				"type": "uint256"
			}
		],
		"name": "leaveSheepPool",
		"outputs": [],
		"stateMutability": "nonpayable",
		"type": "function"
	},
	{
		"inputs": [
			{
				"internalType": "uint256",
				"name": "amount",
				"type": "uint256"
			}
		],
		"name": "leaveWolfPool",
		"outputs": [],
		"stateMutability": "nonpayable",
		"type": "function"
	},
	{
		"inputs": [],
		"name": "owner",
		"outputs": [
			{
				"internalType": "address",
				"name": "",
				"type": "address"
			}
		],
		"stateMutability": "view",
		"type": "function"
	},
	{
		"inputs": [
			{
				"internalType": "address",
				"name": "",
				"type": "address"
			}
		],
		"name": "reward",
		"outputs": [
			{
				"internalType": "uint256",
				"name": "",
				"type": "uint256"
			}
		],
		"stateMutability": "view",
		"type": "function"
	},
	{
		"inputs": [
			{
				"internalType": "uint256",
				"name": "",
				"type": "uint256"
			}
		],
		"name": "sheep",
		"outputs": [
			{
				"internalType": "address",
				"name": "",
				"type": "address"
			}
		],
		"stateMutability": "view",
		"type": "function"
	},
	{
		"inputs": [
			{
				"internalType": "address",
				"name": "",
				"type": "address"
			}
		],
		"name": "sheepBalance",
		"outputs": [
			{
				"internalType": "uint256",
				"name": "",
				"type": "uint256"
			}
		],
		"stateMutability": "view",
		"type": "function"
	},
	{
		"inputs": [],
		"name": "sheepPoolBalance",
		"outputs": [
			{
				"internalType": "uint256",
				"name": "",
				"type": "uint256"
			}
		],
		"stateMutability": "view",
		"type": "function"
	},
	{
		"inputs": [],
		"name": "winner",
		"outputs": [
			{
				"internalType": "uint8",
				"name": "",
				"type": "uint8"
			}
		],
		"stateMutability": "view",
		"type": "function"
	},
	{
		"inputs": [
			{
				"internalType": "address",
				"name": "",
				"type": "address"
			}
		],
		"name": "wolfBalance",
		"outputs": [
			{
				"internalType": "uint256",
				"name": "",
				"type": "uint256"
			}
		],
		"stateMutability": "view",
		"type": "function"
	},
	{
		"inputs": [],
		"name": "wolfPoolBalance",
		"outputs": [
			{
				"internalType": "uint256",
				"name": "",
				"type": "uint256"
			}
		],
		"stateMutability": "view",
		"type": "function"
	},
	{
		"inputs": [
			{
				"internalType": "uint256",
				"name": "",
				"type": "uint256"
			}
		],
		"name": "wolves",
		"outputs": [
			{
				"internalType": "address",
				"name": "",
				"type": "address"
			}
		],
		"stateMutability": "view",
		"type": "function"
	}
]`
      );

      let contract = new web3.eth.Contract(abi, contractAddress);

      //   contract.methods
      //     .owner()
      //     .call()
      //     .then((result) => (this.contractResult = result));

      // Set the amount of Ether to send (in wei)
      let accounts = await window.ethereum.request({
        method: "eth_requestAccounts",
      });
      let userAddress = accounts[0];
      let amountToSend = web3.utils.toWei("0.001", "ether");
      // Example of calling a contract method that modifies data and sends Ether
      let txHash = await contract.methods.joinSheepPool().send({
        from: userAddress,
        value: amountToSend,
      });

      console.log(txHash);

      // wait for the transaction to be mined
      let result = await web3.eth.getTransactionReceipt(txHash);

      console.log(result);
    },
  },
};
</script>

<style scoped>
.setting {
  font-family: monospace, sans-serif;
  background: black;
}
</style>