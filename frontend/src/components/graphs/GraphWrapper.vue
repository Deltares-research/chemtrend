<template>
  <div class="trend">
    <v-card class="trend">
      <v-chart v-if="chartOptions" class="chart" :option="chartOptions" autoresize />
      <v-card v-else>
        No trend available
      </v-card>
    </v-card>
  </div>
</template>

<script>
import { use } from 'echarts/core'
import { CanvasRenderer } from 'echarts/renderers'
import { LineChart } from 'echarts/charts'
import { GridComponent, TitleComponent, TooltipComponent, LegendComponent, MarkLineComponent, DataZoomComponent, ToolboxComponent } from 'echarts/components'
import VChart from 'vue-echarts'
import { LocationTemplate } from './templates/LocationTrend.js'
import { RegionTemplate } from './templates/RegionTrend.js'

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
    },
    graphType: {
      type: String
    }
  },
  components: {
    VChart
  },
  computed: {
    chartOptions () {
      if (this.graphType === 'locations') {
        return LocationTemplate(this.trend)
      }
      return RegionTemplate(this.trend)
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
