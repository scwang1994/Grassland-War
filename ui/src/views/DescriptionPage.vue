<template>
  <div id="centering">
    <v-card class="card" width="75vw" dark>
      <v-row align="center" justify="center" style="text-align: center">
        <v-col cols="12">
          <span style="font-size: 80px; font-weight: bold">
            GRASSLAND-WAR
          </span>
        </v-col>

        <v-col cols="2"></v-col>
        <v-col cols="8" style="color: white; text-align: start">
          <p>
            * Players choose to join either the "Sheep Pool" or the "Wolf Pool"
            and deposit ETH.
          </p>
          <p>* The deposited ETH will be used in Compound to earn interest.</p>
          <p>
            * In both pools, the pool with the higher amount will become the
            dominant pool. The "Wolf Pool" has a 3x weight advantage in the
            calculation.
          </p>
          <p>
            * The game duration is 7 days. If the dominant pool doesn't change
            within 7 days, the dominant species wins. If the dominant pool
            changes within 7 days, the countdown restarts.
          </p>
          <p>
            * If the result is in favor of the "Sheep Pool," all "Sheep"
            participants will share the interest. The interest distribution will
            be weighted based on the amount invested, and "Wolves" will forfeit
            the interest.
          </p>
          <p>
            * If the result is in favor of the "Wolf Pool," the participant with
            the highest deposit amount will receive all the interest.
          </p>
          <p>
            * If, at the end of the game, the number of addresses in the "Wolf
            Pool" is 0, the protocol wins.
          </p>
          <p>
            * If, at the end of the game, the number of addresses in the "Wolf
            Pool" is 1, the "Wolf" will directly win.
          </p>
          <p>
            * The protocol will receive 2% of the revenue from each game result.
          </p>
          <p>
            * The second game will start immediately after the first game ends,
            and so on...
          </p>
        </v-col>
        <v-col cols="2"></v-col>
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

