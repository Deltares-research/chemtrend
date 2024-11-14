<template>
  <div>
    <v-expansion-panels
      width="100%"
      v-model="panels"
      multiple
      variant="accordion"
      density="compact"
    >
      <v-expansion-panel
        v-for="trend in trends" :key="trend.name"
      >
      <v-spacer/>
        <v-expansion-panel-title>
          {{ trend.name }}
          <v-spacer />
          <v-progress-circular
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
                :trend="graph"
                :graphType="graph.region_type || 'locations'"
                :currentLocation="trend.currentLocation"
              />
            </v-col>
          </v-row>

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
    }
  },
  computed: {
    ...mapGetters(['trends', 'regions'])
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
      const data = trendData.filter(d => {
        return regions.includes(d.region_type) || !_.has(d, 'region_type')
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
