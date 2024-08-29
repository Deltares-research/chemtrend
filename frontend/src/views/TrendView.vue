<template>
  <div class="trend-view">
    <div v-for="trend in trends" :key="trend.name" class="trend-wrapper">
      <v-card :title="trend.name" class="trend">
        <v-chart class="chart" :option="trend.option" autoresize />
      </v-card>
    </div>
  </div>
</template>

<script>
import { use } from 'echarts/core'
import { CanvasRenderer } from 'echarts/renderers'
import { LineChart } from 'echarts/charts'
import { GridComponent } from 'echarts/components'
import VChart from 'vue-echarts'
import { mapGetters } from 'vuex'

use([
  CanvasRenderer,
  LineChart,
  GridComponent
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
  display: flex;
  flex-wrap: wrap;
  justify-content: center;
  align-items: center;
  height: 50vh;
}

.trend-wrapper {
  display: flex;
  justify-content: center;
  margin: 10px;
}

.trend {
  height: 400px;
  width: 450px;
}
</style>
