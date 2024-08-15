<template>
  <div class="trend-view">
    <!-- TODO: need some flex here -->
    <div v-for="trend in trends" :key="trend.name">
      <v-card :title="trend.name" class="trend">
        <v-chart class="chart" :option="trend.option" autoresize />
      </v-card>
    </div>
  </div>
</template>

<script>
import { use } from 'echarts/core'
import { CanvasRenderer } from 'echarts/renderers'
import { ScatterChart } from 'echarts/charts'
import VChart from 'vue-echarts'
import { mapGetters } from 'vuex'

use([
  CanvasRenderer,
  ScatterChart
])

export default {
  computed: {
    ...mapGetters(['trends'])
  },
  components: {
    VChart
  },
  data () {
    return {
    }
  }
}
</script>

<style>
.trend-view {
  height: 50vh;
}

.trend {
  height: 400px;
  width: 450px;
}
</style>
