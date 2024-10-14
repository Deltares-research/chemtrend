<template>
  <div class="trend-view">
    <div v-for="(trend, index) in trends" :key="trend.name" class="trend-wrapper">
      <v-card v-show="expandedTrends[index]" flat>
        <v-card class="expansible-card">
          <v-row align="center" no-gutters>
            <v-col cols="auto">
              <v-btn @click="toggleExpand(index, 0)" icon flat>
                <v-icon>{{ expandedTrends[index][0] ? 'mdi-chevron-down' : 'mdi-chevron-right' }}</v-icon>
              </v-btn>
            </v-col>
            <v-col>
              <span class="card-title">{{ trend.option.title.text }}</span>
            </v-col>
          </v-row>
          <v-expand-transition>
            <div v-show="expandedTrends[index][0]">
              <v-card :title="trend.name" class="trend">
                <v-chart class="chart" :option="trend.option" autoresize />
              </v-card>
            </div>
          </v-expand-transition>
        </v-card>
        <v-card class="expansible-card">
          <v-row align="center" no-gutters>
            <v-col cols="auto">
              <v-btn @click="toggleExpand(index, 1)" icon flat>
                <v-icon>{{ expandedTrends[index][1] ? 'mdi-chevron-down' : 'mdi-chevron-right' }}</v-icon>
              </v-btn>
            </v-col>
            <v-col>
              <span class="card-title">{{ trend.option.title.text }}</span>
            </v-col>
          </v-row>
          <v-expand-transition>
            <div v-show="expandedTrends[index][1]">
              <v-card :title="trend.name" class="trend">
                <v-chart class="chart" :option="trend.option" autoresize />
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
      expandedTrends: []
    }
  },
  watch: {
    trends: {
      handler (newTrends) {
        this.expandedTrends = newTrends.map(() => [true, true])
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
  justify-content: right;
  align-items: right;
  height: 50vh;
}

.trend-wrapper {
  display: flex;
  justify-content: center;
  margin: 10px;
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
