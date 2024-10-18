<template>
  <div>
    <v-expansion-panels
      width="100%"
      v-model="panels"
      multiple
    >
      <v-expansion-panel
        v-for="trend in trends" :key="trend.trendData.title"
      >
        <v-expansion-panel-title>{{ trend.trendData.title }}</v-expansion-panel-title>
        <v-expansion-panel-text>
          <v-card class="trend">
              <v-chart class="chart" :option="getChartOptions(trend)" autoresize />
            </v-card>
        </v-expansion-panel-text>
      </v-expansion-panel>
    </v-expansion-panels>
  </div>
</template>

<script>
import { use } from 'echarts/core'
import { CanvasRenderer } from 'echarts/renderers'
import { LineChart } from 'echarts/charts'
import { GridComponent, TitleComponent, TooltipComponent, LegendComponent, MarkLineComponent, DataZoomComponent } from 'echarts/components'
import VChart from 'vue-echarts'
import { mapGetters } from 'vuex'

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
    drawer: {
      type: Boolean
    }
  },
  data () {
    return {
      panels: [0]
    }
  },
  computed: {
    ...mapGetters(['trends'])
  },
  components: {
    VChart
  },
  watch: {
    trends () {
      this.panels = [0]
    }
  },
  methods: {
    getChartOptions (trend) {
      if (!trend || !trend.trendData) return {}

      const trendData = trend.trendData
      const timeseries = trendData.timeseries

      const xAxisData = timeseries.map(item => item.x_value)
      const yValueLowess = timeseries.map(item => item.y_value_lowess)
      const yValueMeting = timeseries.map(item => item.y_value_meting)
      const yValueTheilSen = timeseries.map(item => item.y_value_theil_sen)

      return {
        title: {
          text: trendData.title,
          subtext: `${trendData.subtitle_1}\n${trendData.subtitle_2}`,
          left: 'center',
          top: 10,
          textStyle: {
            fontSize: 25
          },
          subtextStyle: {
            fontSize: 15
          }
        },
        grid: {
          top: 100,
          bottom: 50,
          right: 50,
          left: 50
        },
        tooltip: {
          show: true
        },
        legend: {
          show: true,
          bottom: 5,
          lineStyle: {
            symbol: 'none'
          },
          itemWidth: 70
        },
        xAxis: {
          type: 'category',
          data: xAxisData
        },
        yAxis: {
          type: 'value'
        },
        series: [
          {
            name: 'Meting',
            type: 'line',
            data: yValueMeting,
            lineStyle: {
              color: '#000000'
            },
            symbol: 'circle',
            symbolSize: 8,
            showAllSymbol: true,
            itemStyle: {
              color: '#f8766d',
              borderColor: '#000000',
              borderWidth: 1
            },
            markLine: {
              data: [
                {
                  yAxis: trendData.h1_value,
                  name: trendData.h1_label,
                  label: {
                    show: true,
                    position: 'insideStart',
                    formatter: function (params) {
                      return params.data.name
                    }
                  }
                },
                {
                  yAxis: trendData.h2_value,
                  name: trendData.h2_label,
                  label: {
                    show: true,
                    position: 'insideEnd',
                    formatter: function (params) {
                      return params.data.name
                    }
                  }
                }
              ],
              emphasis: {
                disabled: true
              },
              lineStyle: {
                color: '#373737'
              },
              symbol: ['none', 'none'],
              tooltip: {
                show: true,
                formatter: function (params) {
                  return `${params.data.name}  ${params.data.yAxis}`
                }
              }
            }
          },
          {
            name: 'Lowess',
            type: 'line',
            data: yValueLowess,
            lineStyle: {
              color: '#0000ff'
            },
            symbol: 'none',
            showSymbol: false
          },
          {
            name: 'Theil Sen',
            type: 'line',
            data: yValueTheilSen,
            lineStyle: {
              color: '#FFA500',
              type: 'dashed'
            },
            symbol: 'none',
            showSymbol: false,
            itemStyle: {
              color: '#FFA500'
            }
          }
        ]
      }
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
