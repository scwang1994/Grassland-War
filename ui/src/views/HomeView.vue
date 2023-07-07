<template>
  <div id="centering">
    <v-card class="card" width="80vw" dark>
      <v-row align="center" justify="center" style="text-align: center">
        <v-col cols="12">
          <div style="background: #00896c">
            <flip-countdown
              style="font-weight: bold; color: white"
              :deadline="deadline"
            ></flip-countdown>
          </div>

          <span style="font-size: 48px; font-weight: bold">
            GRASSLAND-WAR
          </span>
        </v-col>

        <v-col cols="12">
          <v-row>
            <v-col cols="0" md="1"></v-col>
            <v-col cols="12" md="5">
              <v-card elevation="0" :class="wolfClass">
                <br />
                <p style="font-size: 30px; font-weight: bold">Wolf Pool</p>

                <v-img
                  max-height="300px"
                  max-width="400px"
                  src="../assets/wolf2.png"
                  class="ml-auto mr-auto mt-auto mb-auto"
                ></v-img>
                <br />
                <p>total balance {{ wolfPoolBalance }} Ether</p>
                <br />

                <v-row>
                  <v-col cols="0" md="2"></v-col>
                  <v-col cols="12" md="8">
                    <v-row>
                      <v-text-field
                        class="mr-3"
                        :disabled="!connected"
                        v-model="wolfInputAmount"
                        outlined
                        label="Ether"
                        type="number"
                      ></v-text-field>

                      <v-btn
                        class="mr-2"
                        color="#00896c"
                        :disabled="!connected"
                        x-large
                        depressed
                        @click="joinWolfPool"
                        >Join
                      </v-btn>

                      <v-btn
                        color="error"
                        :disabled="!connected"
                        x-large
                        outlined
                        @click="leaveWolfPool"
                        >Leave
                      </v-btn>
                    </v-row>
                  </v-col>
                  <v-col cols="2"></v-col>
                </v-row>
                <v-btn
                  class="mr-3 mb-5"
                  :disabled="!connected"
                  fab
                  outlined
                  x-large
                  @click="getWolfBalance"
                >
                  check
                </v-btn>
                {{
                  userWolfBalance !== 0
                    ? "Balance: " + userWolfBalance + " ETH"
                    : null
                }}
              </v-card>
            </v-col>

            <v-col cols="12" md="5">
              <v-card elevation="0" :class="sheepClass">
                <br />
                <p style="font-size: 30px; font-weight: bold">Sheep Pool</p>
                <v-img
                  max-height="300px"
                  max-width="400px"
                  src="../assets/sheep2.png"
                  class="ml-auto mr-auto"
                ></v-img>
                <br />
                <p>total balance {{ sheepPoolBalance }} Ether</p>
                <br />

                <v-row>
                  <v-col cols="0" md="2"></v-col>
                  <v-col cols="12" md="8">
                    <v-row>
                      <v-text-field
                        class="mr-3"
                        :disabled="!connected"
                        v-model="sheepInputAmount"
                        outlined
                        label="Ether"
                        type="number"
                      ></v-text-field>

                      <v-btn
                        class="mr-2"
                        color="#00896c"
                        :disabled="!connected"
                        x-large
                        depressed
                        @click="joinSheepPool"
                        >Join
                      </v-btn>

                      <v-btn
                        color="error"
                        :disabled="!connected"
                        x-large
                        outlined
                        @click="leaveSheepPool"
                        >Leave
                      </v-btn>
                    </v-row>
                  </v-col>
                  <v-col cols="0" md="2"></v-col>
                </v-row>
                <v-btn
                  class="mr-3 mb-5"
                  :disabled="!connected"
                  fab
                  x-large
                  outlined
                  @click="getSheepBalance"
                >
                  check
                </v-btn>
                {{
                  userSheepBalance !== 0
                    ? "Balance: " + userSheepBalance + " ETH"
                    : null
                }}
              </v-card>
            </v-col>
            <v-col cols="0" md="1"></v-col>
          </v-row>

          <v-row>
            <v-col cols="12" style="font-weight: bold">
              Reward {{ userReward !== 0 ? userReward + " ETH" : null }}
            </v-col>
            <v-col cols="12">
              <v-row>
                <v-layout justify-center>
                  <v-btn
                    class="mr-3"
                    :disabled="!connected"
                    x-large
                    @click="getReward"
                  >
                    check
                  </v-btn>

                  <v-btn :disabled="!connected" x-large @click="claimReward">
                    claim
                  </v-btn>
                </v-layout>
              </v-row>
            </v-col>
          </v-row>
        </v-col>
      </v-row>

      <br />
    </v-card>
  </div>
</template>

<script>
import FlipCountdown from "vue2-flip-countdown";
import contractABI from "../lib/abi.json";
import Web3 from "web3";

export default {
  components: { FlipCountdown },
  props: ["connected", "userAccount"],
  data() {
    return {
      contractAddress: "0x7fD2932e6402BCA622B15842a3c434a56E6Fa037",
      web3: null,
      contractInstance: null,

      // get data
      sheepClass: "default-group",
      wolfClass: "default-group",
      deadline: "2023-01-01 00:00:00",
      sheepPoolBalance: 0,
      wolfPoolBalance: 0,

      userSheepBalance: 0,
      userWolfBalance: 0,
      userReward: 0,

      sheepInputAmount: 0,
      wolfInputAmount: 0,

      toETH: 1000000000000000000,
    };
  },
  methods: {
    async getWinner() {
      // Call the get function
      let result = await this.contractInstance.methods.getWinner().call();
      parseInt(result) === 1
        ? (this.sheepClass = "win-group")
        : parseInt(result) === 2
        ? (this.wolfClass = "win-group")
        : null;
    },

    async getEndTime() {
      // Call the get function
      let result = await this.contractInstance.methods.getEndTime().call();
      if (result !== 0n) {
        this.deadline = this.formatDateTime(new Date(parseInt(result) * 1000));
      }
      console.log(this.deadline);
    },

    async getSheepPoolBalance() {
      // Call the get function
      let result = await this.contractInstance.methods
        .getSheepPoolBalance()
        .call();
      this.sheepPoolBalance = parseInt(result) / this.toETH;
      console.log(parseInt(result));
    },

    async getWolfPoolBalance() {
      // Call the get function
      let result = await this.contractInstance.methods
        .getWolfPoolBalance()
        .call();
      this.wolfPoolBalance = parseInt(result) / this.toETH;
      console.log(parseInt(result));
    },

    async getSheepBalance() {
      // Call the get function
      let result = await this.contractInstance.methods.getSheepBalance().call({
        from: this.userAccount,
      });
      console.log(result);
      this.userSheepBalance = parseInt(result) / this.toETH;
    },

    async getWolfBalance() {
      // Call the get function
      let result = await this.contractInstance.methods.getWolfBalance().call({
        from: this.userAccount,
      });
      console.log(result);
      this.userWolfBalance = parseInt(result) / this.toETH;
    },

    async getReward() {
      // Call the get function
      let result = await this.contractInstance.methods.getReward().call({
        from: this.userAccount,
      });
      console.log(result);
      this.userReward = parseInt(result) / this.toETH;
    },

    async refreshData(group) {
      this.getWinner();
      this.getEndTime();
      this.getSheepPoolBalance();
      this.getWolfPoolBalance();

      group === 0 ? this.getSheepBalance() : this.getWolfBalance();
    },

    async joinSheepPool() {
      console.log(this.userAccount);
      // Set the amount of Ether to send
      let amountToSend = this.web3.utils.toWei(this.sheepInputAmount, "ether");
      let txHash = await this.contractInstance.methods.joinSheepPool().send({
        from: this.userAccount,
        value: amountToSend,
      });
      this.sheepInputAmount = 0;
      console.log(txHash);
      await this.refreshData(0);
    },

    async joinWolfPool() {
      console.log(this.userAccount);
      // Set the amount of Ether to send
      let amountToSend = this.web3.utils.toWei(this.wolfInputAmount, "ether");
      let txHash = await this.contractInstance.methods.joinWolfPool().send({
        from: this.userAccount,
        value: amountToSend,
      });
      this.wolfInputAmount = 0;
      console.log(txHash);
      await this.refreshData(1);
    },

    async leaveSheepPool() {
      console.log(this.userAccount);
      // Set the amount of Ether to send
      let amountToSend = this.web3.utils.toWei(this.sheepInputAmount, "ether");
      let txHash = await this.contractInstance.methods
        .leaveSheepPool(amountToSend)
        .send({
          from: this.userAccount,
        });
      this.sheepInputAmount = 0;
      console.log(txHash);
      await this.refreshData(0);
    },

    async leaveWolfPool() {
      console.log(this.userAccount);
      // Set the amount of Ether to send
      let amountToSend = this.web3.utils.toWei(this.wolfInputAmount, "ether");
      let txHash = await this.contractInstance.methods
        .leaveWolfPool(amountToSend)
        .send({
          from: this.userAccount,
        });
      this.wolfInputAmount = 0;
      console.log(txHash);
      await this.refreshData(1);
    },

    async claimReward() {
      console.log(this.userAccount);
      let txHash = await this.contractInstance.methods.claim().send({
        from: this.userAccount,
      });
      this.getReward();
      console.log(txHash);
    },

    formatDateTime(date_ob) {
      // current date
      // adjust 0 before single digit date
      let date = ("0" + date_ob.getDate()).slice(-2);
      // current month
      let month = ("0" + (date_ob.getMonth() + 1)).slice(-2);
      // current year
      let year = date_ob.getFullYear();
      // current hours
      let hours = date_ob.getHours();
      // current minutes
      let minutes = date_ob.getMinutes();
      // current seconds
      let seconds = date_ob.getSeconds();
      return (
        year +
        "-" +
        month +
        "-" +
        date +
        " " +
        hours +
        ":" +
        minutes +
        ":" +
        seconds
      );
    },
  },
  async created() {
    // Connect to the Ethereum network
    if (window.ethereum) {
      this.web3 = new Web3(window.ethereum);
      await window.ethereum.enable();
    } else {
      // Handle the case where the browser doesn't support MetaMask or a similar provider
      console.error(
        "Please install MetaMask or use a compatible Ethereum browser."
      );
    }

    // Load the smart contract
    const contract = new this.web3.eth.Contract(
      contractABI,
      this.contractAddress
    );
    this.contractInstance = contract;

    // call get functions
    this.getWinner();
    this.getEndTime();
    this.getSheepPoolBalance();
    this.getWolfPoolBalance();
  },
};
</script>

<style scoped>
#centering {
  display: flex;
  justify-content: center;
}

.card {
  color: #00896c;
  font-size: 20px;
}

.default-group {
  color: #00896c;
  font-size: 20px;
  background: #1c1c1c;

  /* border: 1px solid #e0e0e0; */
  border-radius: 8px;
  box-shadow: 0 2px 4px rgba(0, 0, 0, 0.1);
}

.default-group:hover {
  background-color: black;
  border-radius: 8px;
  box-shadow: 0 2px 4px rgba(0, 0, 0, 0.1);
}

.win-group {
  color: black;
  font-size: 20px;
  /* background: #dda52d; */

  background: linear-gradient(to bottom right, #ffffff, #dda52d);
  /* border: 1px solid #e0e0e0; */
  border-radius: 8px;
  box-shadow: 0 2px 4px rgba(0, 0, 0, 0.1);
}
.win-group:hover {
  background: linear-gradient(to bottom right, #dda52d, #ffffff);
  border-radius: 8px;
  box-shadow: 0 2px 4px rgba(0, 0, 0, 0.1);
}
</style>

