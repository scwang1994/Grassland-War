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
      <v-btn large outlined :color="connectedColor" dark @click="connect">
        {{ connected === true ? "launched" : "launch app" }}
      </v-btn>
    </v-app-bar>

    <v-container class="setting" fill-height fluid>
      <v-main>
        <router-view :connected="connected" :userAccount="account" />
      </v-main>
    </v-container>
  </v-app>
</template>

<script>
export default {
  name: "App",

  data() {
    return {
      connected: false,
      account: null,
    };
  },
  methods: {
    render(_pathUrl) {
      this.$router.push({ name: _pathUrl });
    },

    connect() {
      let ethereum = window.ethereum;

      if (ethereum) {
        ethereum.request({ method: "eth_requestAccounts" }).then((accounts) => {
          if (accounts.length > 0) {
            this.connected = true;
            // console.log(accounts);
            this.account = accounts[0];
          }
        });
      }
    },
  },
  computed: {
    connectedColor() {
      return this.connected === true ? "#CB4042" : "#00896c";
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