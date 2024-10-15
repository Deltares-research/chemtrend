<template>
  <div class="content-wrapper">
    <v-col>
      <v-row>
        <v-autocomplete
          label="Select substance"
          :items="substances"
          class="autocomplete-list"
          item-value="substance_id"
          item-title="substance_description"
          :return-object="true"
          v-model="substance"
        ></v-autocomplete>
        </v-row>
        <v-row>
        <v-switch
          v-model="region"
          v-for="reg in regions"
          :key="reg.name"
          :label="reg.name"
          :value="reg.name"
          :color="reg.color"
          width="100%"
          hide-details
          multiple
        ></v-switch>
        </v-row>
        <v-row>
          <point-layer-legend style="margin-bottom: 15px;" />
        </v-row>
    </v-col>
  </div>
</template>

<script>
import { mapGetters, mapActions } from 'vuex'
import _ from 'lodash'
import PointLayerLegend from '@/components/tabs/PointLayerLegend'

export default {
  name: 'SubstanceTab',
  components: {
    PointLayerLegend
  },
  methods: {
    ...mapActions(['loadSubstances', 'loadRegions', 'loadFilteredLocations', 'setSelectedSubstanceId'])
  },
  computed: {
    ...mapGetters(['substances', 'regions']),
    substance: {
      get () {
        const subId = parseInt(_.get(this.$route, 'query.substance'), 10) // Ensure it's an integer
        return this.substances.find(substance => substance.substance_id === subId) || null
      },
      set (substance) {
        const newQuery = {
          ...this.$route.query,
          substance: substance.substance_id
        }
        this.$router.push({ query: newQuery })
        this.setSelectedSubstanceId(substance.substance_id)
      }
    },
    region: {
      get () {
        const regions = _.get(this.$route, 'query.region', '')
        return regions.split(',')
      },
      set (region) {
        const newQuery = {
          ...this.$route.query,
          region: region.join(',')
        }
        this.$router.push({ query: newQuery })
      }
    }
  },
  created () {
    this.loadSubstances()
    this.loadRegions()
  }
}
</script>
