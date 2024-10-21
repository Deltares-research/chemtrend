<template>
  <div class="trend">
    <v-card class="trend">
      <v-chart class="chart" :option="getChartOptions(trend)" autoresize />
    </v-card>
  </div>
</template>

<script>
import { use } from 'echarts/core'
import { CanvasRenderer } from 'echarts/renderers'
import { LineChart } from 'echarts/charts'
import { GridComponent, TitleComponent, TooltipComponent, LegendComponent, MarkLineComponent, DataZoomComponent } from 'echarts/components'
import VChart from 'vue-echarts'
import { mapGetters } from 'vuex'
import { template } from './templates/LocationTrend.js'

use([
  CanvasRenderer,
  LineChart,
  GridComponent,
  TitleComponent,
  TooltipComponent,
  LegendComponent,
  MarkLineComponent,
  DataZoomComponent
])

export default {
  props: {
    trend: {
      type: Object
    }
  },
  computed: {
    ...mapGetters(['trends'])
  },
  components: {
    VChart
  },
  methods: {
    getChartOptions (trend) {
      console.log(trend)
      const trendData = {
          title: "chloride NL02_0067",
          h1_label: "MKN",
          h1_value: 2.8,
          h2_label: "MAC",
          h2_value: 0.15,
          subtitle_1: "Trendresultaat: trend neerwaarts (p=0.000000477436367329886)",
          subtitle_2: "Trendhelling: -3.69059656218401600 ug/l per decennium",

          x_value: ["1990-01-08", "1990-02-07", "1990-03-07"],
          y_value_lowess: [60.7822759909189, 60.6584567903033, 60.5431042527501],
          y_value_meting: [92, 68, 68],
          y_value_theil_sen: [58.5475227502528, 58.5475227502528, 58.5475227502528]
        }
      return template(trendData)
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
