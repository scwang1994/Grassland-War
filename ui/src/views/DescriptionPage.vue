<template>
  <div id="centering">
    <v-card class="card" width="75vw" height="75vh" dark>
      <v-row align="center" justify="center" style="text-align: center">
        <v-col cols="12">
          <flip-countdown
            style="font-weight: bold; background: #00896c; color: white"
            deadline="2023-12-25 00:00:00"
          ></flip-countdown>
          <span style="font-size: 80px; font-weight: bold">
            GRASSLAND-WAR
          </span>
        </v-col>

        <v-col cols="12">
          <p>WINNER： {{ winner }}</p>
          <v-row>
            <v-col cols="6">
              <p>SHEEP POOL</p>
              <v-btn v-if="connected" x-large rounded outlined
                >Join Sheep Pool</v-btn
              >
            </v-col>
            <v-col cols="6">
              <p>WOLF POOL</p>
              <v-btn v-if="connected" x-large rounded outlined
                >Join Wolf Pool</v-btn
              >
            </v-col>
          </v-row>
        </v-col>

        <!-- <v-col cols="12">
          <v-btn x-large rounded color="#00896c" dark> Connect wallet </v-btn>
        </v-col> -->
      </v-row>
    </v-card>
  </div>
</template>

<script>
export default {
  data() {
    return {
      winner: "SHEEP POOL",
      connected: true,
    };
  },
  methods: {},
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
</style>

