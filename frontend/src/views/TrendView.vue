<template>
  <div class="trend-view">
    <div class="trend-wrapper">

      <v-card v-if="trends[0]" flat>
        <v-card class="expansible-card">
          <v-row align="center" no-gutters>
            <v-col cols="auto">
              <v-btn @click="toggleExpand(0, 0)" icon flat>
                <v-icon>{{ expandedTrends[0][0] ? 'mdi-chevron-down' : 'mdi-chevron-right' }}</v-icon>
              </v-btn>
            </v-col>
            <v-col>
              <span class="card-title">{{ getChartOptions(trends[0]).title.text }}</span>
            </v-col>
          </v-row>
          <v-expand-transition>
            <div v-show="expandedTrends[0][0]">
              <v-card class="trend">
                <v-chart class="chart" :option="getChartOptions(trends[0])" autoresize />
              </v-card>
            </div>
          </v-expand-transition>
        </v-card>
      </v-card>

      <v-card v-if="trends[1]" flat>
        <v-card class="expansible-card">
          <v-row align="center" no-gutters>
            <v-col cols="auto">
              <v-btn @click="toggleExpand(1, 1)" icon flat>
                <v-icon>{{ expandedTrends[1][1] ? 'mdi-chevron-down' : 'mdi-chevron-right' }}</v-icon>
              </v-btn>
            </v-col>
            <v-col>
              <span class="card-title">{{ getChartOptions(trends[1]).title.text }}</span>
            </v-col>
          </v-row>
          <v-expand-transition>
            <div v-show="expandedTrends[1][1]">
              <v-card class="trend">
                <v-chart class="chart" :option="getChartOptions(trends[1])" autoresize />
              </v-card>
            </div>
          </v-expand-transition>
        </v-card>
      </v-card>
    </div>
  </div>
</template>

<script>
import { use } from 'echarts/core'
import { CanvasRenderer } from 'echarts/renderers'
import { LineChart } from 'echarts/charts'
import { GridComponent, TitleComponent, TooltipComponent, LegendComponent, MarkLineComponent } from 'echarts/components'
import VChart from 'vue-echarts'
import { mapGetters } from 'vuex'

use([
  CanvasRenderer,
  LineChart,
  GridComponent,
  TitleComponent,
  TooltipComponent,
  LegendComponent,
  MarkLineComponent
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
      expandedTrends: [[true, true], [true, true]]
    }
  },
  methods: {
    toggleExpand (trendIndex, cardIndex) {
      if (this.expandedTrends[trendIndex]) {
        this.expandedTrends[trendIndex][cardIndex] = !this.expandedTrends[trendIndex][cardIndex]
      }
    },
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
.trend-view {
  display: flex;
  flex-wrap: wrap;
  flex-direction: column;
  justify-content: right;
  align-items: end;
  height: 50vh;
  overflow-y: auto;
}

.trend-wrapper {
  justify-content: center;
  margin-bottom: 10px;
  height: fit-content;
}

.trend {
  height: 45vh;
  width: 70vw;
}

.expansible-card {
  width: 70vw;
  margin-bottom: 10px;
}

.card-title {
  font-size: 22px;
  font-weight: 500;
  padding: 18px;
}
</style>
