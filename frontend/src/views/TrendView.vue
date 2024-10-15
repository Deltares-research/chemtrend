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
              <span class="card-title">{{ trends[0].option?.title?.text }}</span>
            </v-col>
          </v-row>
          <v-expand-transition>
            <div v-show="expandedTrends[0][0]">
              <v-card class="trend">
                <v-chart class="chart" :option="trends[0]?.option" autoresize />
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
              <span class="card-title">{{ trends[1].option?.title?.text }}</span>
            </v-col>
          </v-row>
          <v-expand-transition>
            <div v-show="expandedTrends[1][1]">
              <v-card class="trend">
                <v-chart class="chart" :option="trends[1]?.option" autoresize />
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
  watch: {
    trends: {
      handler (newTrends) {
        if (newTrends.length >= 2) {
          this.expandedTrends = newTrends.map(() => [true, true])
        }
      },
      immediate: true // Run the watcher immediately on first render
    }
  },
  methods: {
    toggleExpand (trendIndex, cardIndex) {
      if (this.expandedTrends[trendIndex]) {
        this.expandedTrends[trendIndex][cardIndex] = !this.expandedTrends[trendIndex][cardIndex]
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
