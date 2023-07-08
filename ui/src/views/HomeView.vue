<template>
  <div id="centering">
    <v-card :class="textClass" width="70vw" dark>
      <v-row
        align="center"
        justify="center"
        style="text-align: center"
        class="background-image"
      >
        <v-col cols="12">
          <div>
            <!-- <div style="background: #00896c"> -->
            <flip-countdown
              :class="[boldClass, colorClass]"
              :deadline="deadline"
            ></flip-countdown>
          </div>
          <span :class="[titleClass, boldClass, colorClass]">
            GRASSLAND WAR
          </span>
        </v-col>

        <v-col cols="12">
          <v-row>
            <v-col cols="0" md="1"></v-col>
            <v-col cols="12" md="5">
              <v-card elevation="0" :class="wolfClass">
                <br />
                <p :class="[subTitleClass, boldClass]">Wolf Pool</p>

                <v-img
                  max-height="300px"
                  max-width="400px"
                  src="../assets/wolf2.png"
                  class="ml-auto mr-auto mt-auto mb-auto"
                ></v-img>
                <br />

                <p>Total Balance {{ wolfPoolBalance }} Ether</p>

                <div class="mb-10">
                  <v-btn
                    :disabled="!connected"
                    outlined
                    small
                    @click="getWolfBalance"
                  >
                    check
                  </v-btn>
                  {{
                    userWolfBalance !== null
                      ? "Your Balance " + userWolfBalance + " Ether"
                      : null
                  }}
                </div>

                <v-row>
                  <v-col cols="0" md="2" sm="0"></v-col>
                  <v-col cols="12" md="8" sm="12">
                    <v-text-field
                      class="mb-3"
                      :disabled="!connected"
                      v-model="wolfInputAmount"
                      outlined
                      label="Ether"
                      type="number"
                      hide-details
                    ></v-text-field>

                    <v-btn
                      class="mb-3"
                      block
                      color="#00896c"
                      :disabled="!connected"
                      x-large
                      depressed
                      @click="joinWolfPool"
                      >Join
                    </v-btn>

                    <v-btn
                      block
                      color="error"
                      :disabled="!connected"
                      x-large
                      outlined
                      @click="leaveWolfPool"
                      >Leave
                    </v-btn>
                  </v-col>
                  <v-col cols="0" md="2" sm="0"></v-col>
                </v-row>
              </v-card>
            </v-col>

            <v-col cols="12" md="5">
              <v-card elevation="0" :class="sheepClass">
                <br />
                <p :class="[subTitleClass, boldClass]">Sheep Pool</p>
                <v-img
                  max-height="300px"
                  max-width="400px"
                  src="../assets/sheep2.png"
                  class="ml-auto mr-auto"
                ></v-img>
                <br />
                <p>Total Balance {{ sheepPoolBalance }} Ether</p>
                <div class="mb-10">
                  <v-btn
                    :disabled="!connected"
                    small
                    outlined
                    @click="getSheepBalance"
                  >
                    check
                  </v-btn>
                  {{
                    userSheepBalance !== null
                      ? "Your Balance " + userSheepBalance + " Ether"
                      : null
                  }}
                </div>

                <v-row>
                  <v-col cols="0" md="2" sm="0"></v-col>
                  <v-col cols="12" md="8" sm="12">
                    <v-text-field
                      class="mb-3"
                      :disabled="!connected"
                      v-model="sheepInputAmount"
                      outlined
                      label="Ether"
                      type="number"
                      hide-details
                    ></v-text-field>

                    <v-btn
                      class="mb-3"
                      block
                      color="#00896c"
                      :disabled="!connected"
                      x-large
                      depressed
                      @click="joinSheepPool"
                      >Join
                    </v-btn>

                    <v-btn
                      block
                      color="error"
                      :disabled="!connected"
                      x-large
                      outlined
                      @click="leaveSheepPool"
                      >Leave
                    </v-btn>
                  </v-col>
                  <v-col cols="0" md="2"></v-col>
                </v-row>
              </v-card>
            </v-col>
            <v-col cols="0" md="1"></v-col>
          </v-row>

          <v-row>
            <v-col cols="12" :class="[subTitleClass, boldClass, colorClass]">
              Reward {{ userReward !== null ? userReward + " Ether" : null }}
            </v-col>
            <v-col cols="12">
              <v-row>
                <v-layout justify-center>
                  <v-btn
                    class="mr-3 mb-5"
                    :disabled="!connected"
                    x-large
                    depressed
                    :color="colorClass"
                    @click="getReward"
                  >
                    check
                  </v-btn>

                  <v-btn
                    depressed
                    :disabled="!connected"
                    x-large
                    :color="colorClass"
                    @click="claimReward"
                  >
                    claim
                  </v-btn>
                </v-layout>
              </v-row>
            </v-col>
          </v-row>
        </v-col>
      </v-row>
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

      userSheepBalance: null,
      userWolfBalance: null,
      userReward: null,

      sheepInputAmount: 0,
      wolfInputAmount: 0,

      toETH: 1000000000000000000,

      // style
      colorClass: "colorClass",
      boldClass: "boldClass",
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
  computed: {
    titleClass() {
      if (this.$vuetify.breakpoint.width < 600) {
        return "smallTitle";
      } else if (this.$vuetify.breakpoint.width < 960) {
        return "mediumTitle";
      } else {
        return "largeTitle";
      }
    },
    subTitleClass() {
      if (this.$vuetify.breakpoint.width < 600) {
        return "smallSubTitle";
      } else if (this.$vuetify.breakpoint.width < 960) {
        return "mediumSubTitle";
      } else {
        return "largeSubTitle";
      }
    },
    textClass() {
      if (this.$vuetify.breakpoint.width < 600) {
        return "smallText";
      } else if (this.$vuetify.breakpoint.width < 960) {
        return "mediumText";
      } else {
        return "largeText";
      }
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

.background-image {
  background-image: url("../assets/banner.png");
  background-size: cover;
  background-position: center;
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

.smallTitle {
  font-size: 24px;
}

.mediumTitle {
  font-size: 48px;
}

.largeTitle {
  font-size: 80px;
}

.smallSubTitle {
  font-size: 18px;
}

.mediumSubTitle {
  font-size: 28px;
}

.largeSubTitle {
  font-size: 40px;
}

.smallText {
  font-size: 12px;
}

.mediumText {
  font-size: 16px;
}

.largeText {
  font-size: 20px;
}

.colorClass {
  color: #00896c;
}

.boldClass {
  font-weight: bold;
}
</style>

