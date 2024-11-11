<template>
  <div>
    <v-expansion-panels
      width="100%"
      v-model="panels"
      multiple
      variant="accordion"
    >
      <v-expansion-panel
        v-for="trend in trends" :key="trend.name"
      >
        <v-expansion-panel-title>{{ trend.name }}</v-expansion-panel-title>
        <v-expansion-panel-text class="panel-text">
          <v-row v-for="row in graphRows(trend)" :key="row" no-gutters>
            <v-col
              v-for="graph in row"
              :key="graph.name">
              <graph-wrapper
                :trend="graph"
                :graphType="graph.region_type || 'locations'"
              />
            </v-col>
          </v-row>

        </v-expansion-panel-text>
      </v-expansion-panel>
    </v-expansion-panels>
  </div>
</template>

<script>
import { mapGetters } from 'vuex'
import GraphWrapper from '@/components/graphs/GraphWrapper.vue'
import _ from 'lodash'

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
  watch: {
    trends () {
      this.panels = [0]
    }
  },
  computed: {
    ...mapGetters(['trends'])
  },
  components: {
    GraphWrapper
  },
  methods: {
    graphRows (trend) {
      console.log('hallo?')
      const rows = []
      const trendData = trend.trendData
      const regions = _.get(this.$route, 'query.region', '').split(',')
      console.log('regions', regions)
      console.log('data', trendData)

      const data = trendData.filter(d => {
        console.log('test', d.region_type, regions, d.region_type in regions, !_.has(d, 'region_type'))
        return regions.includes(d.region_type) || !_.has(d, 'region_type')
      })
      console.log('data', data)
      if (data) {
        for (let i = 0; i < data.length; i += 2) {
          if (data[i + 1]) {
            rows.push([data[i], data[i + 1]])
          } else {
            rows.push([data[i]])
          }
        }
      }
      return rows
    }
  }
}
</script>

<style>
.panel-text {
  height: 400px;
  overflow-y: auto;
}
</style>
