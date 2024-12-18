<template>
  <div>
    <v-expansion-panels
      width="100%"
      v-model="panels"
      variant="accordion"
      density="compact"
      multiple="true"
    >
      <v-expansion-panel
        v-for="trend in trends" :key="trend.name"
      >
      <v-spacer/>
        <v-expansion-panel-title>
          {{ trend.name }}
          <v-spacer />
          <v-progress-circular
            class="mx-1"
            v-if="trend.loading"
            color="primary"
            indeterminate
          ></v-progress-circular>
          <v-btn icon="mdi-delete" size="x-small" @click.stop="REMOVE_TREND(trend.name)">
          </v-btn>
        </v-expansion-panel-title>
        <v-expansion-panel-text v-if="!trend.loading" class="panel-text">
          <v-row v-for="row in graphRows(trend)" :key="row" no-gutters>
            <v-col
            v-for="graph in row"
            :key="graph.name">
              <graph-wrapper
              :id="graph.name"
              :trend="graph"
              :graphType="graph.region_type || 'locations'"
              :currentLocation="trend.currentLocation"
              />
          </v-col>
        </v-row>
        <v-alert
          v-if="trend.error"
          type="info"
          variant="outlined"
          density="compact"
        >
          {{ trend.error }}
        </v-alert>
        </v-expansion-panel-text>
      </v-expansion-panel>
    </v-expansion-panels>
  </div>
</template>

<script>
import { mapGetters, mapMutations } from 'vuex'
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
    },
    panelTrigger () {
      let newPanels = this.trends.map((trend, index) => {
        return trend.state === 'open' ? index : -1
      }).filter(i => i >= 0)
      if (newPanels === undefined || newPanels.length === 0) {
        newPanels = [0]
      }
      this.panels = newPanels
    },
    panels () {
      // TODO: clean up if statements
      if (!this.panels) {
        return
      }
      const openTrend = this.trends[this.panels]
      if (!openTrend) {
        return
      }
      if (openTrend.loading || openTrend.error) {
        return
      }
      const newQuery = {
        ...this.$route.query, // Keep all existing query parameters, including 'substance'
        longitude: openTrend.coordinates[0],
        latitude: openTrend.coordinates[1],
        substance: openTrend.substanceId
      }
      this.$router.push({
        path: '/trends',
        query: newQuery
      })
    }
  },
  computed: {
    ...mapGetters(['panelTrigger', 'trends', 'regions'])
  },
  components: {
    GraphWrapper
  },
  methods: {
    ...mapMutations(['REMOVE_TREND']),
    graphRows (trend) {
      const rows = []
      const trendData = trend.trendData || []
      const regions = _.get(this.$route, 'query.region', '').split(',')
      const regionNames = this.regions.map(region => region.name)
      const data = trendData.filter(d => {
        return regions.includes(d.region_type) || !_.has(d, 'region_type')
      }).sort((a, b) => {
        return regionNames.indexOf(a.region_type) - regionNames.indexOf(b.region_type)
      })
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
