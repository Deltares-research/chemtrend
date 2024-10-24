<template>
  <div class="trend">
    <v-card class="trend">
      <v-chart class="chart" :option="chartOptions" autoresize />
    </v-card>
  </div>
</template>

<script>
import { use } from 'echarts/core'
import { CanvasRenderer } from 'echarts/renderers'
import { LineChart } from 'echarts/charts'
import { GridComponent, TitleComponent, TooltipComponent, LegendComponent, MarkLineComponent, DataZoomComponent, ToolboxComponent } from 'echarts/components'
import VChart from 'vue-echarts'
import { template } from './templates/LocationTrend.js'

use([
  CanvasRenderer,
  LineChart,
  GridComponent,
  TitleComponent,
  TooltipComponent,
  LegendComponent,
  MarkLineComponent,
  DataZoomComponent,
  ToolboxComponent
])

export default {
  props: {
    trend: {
      type: Object
    }
  },
  components: {
    VChart
  },
  computed: {
    chartOptions () {
      return template(this.trend)
    }
  }
}
</script>

<style>
.trend {
  height: 45vh;
  max-width: 70vw;
}
</style>
