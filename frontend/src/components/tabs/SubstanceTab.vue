<template>
  <div class="content-wrapper">
    <v-col>
      <v-row>
        <h1>1. Substanties </h1>
      </v-row>
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
        <h1>2. Regio's </h1>
      </v-row>
      <v-row
        v-for="reg in regions"
        :key="reg.name">
        <v-switch
          v-model="region"
          :label="reg.name"
          :value="reg.name"
          :color="reg.color"
          hide-details
          multiple
        ></v-switch>
        <v-spacer/>
        <v-btn icon="mdi-magnify" flat size="x-small" @click.stop="ZOOM_TO(reg.name)">
        </v-btn>
      </v-row>
        <v-row class="align-end">
          <point-layer-legend style="margin-bottom: 20px;" />
        </v-row>
    </v-col>
  </div>
</template>

<script>
import { mapGetters, mapActions, mapMutations } from 'vuex'
import _ from 'lodash'
import PointLayerLegend from '@/components/tabs/PointLayerLegend'

export default {
  name: 'SubstanceTab',
  components: {
    PointLayerLegend
  },
  methods: {
    ...mapMutations(['ZOOM_TO']),
    ...mapActions(['loadSubstances', 'loadRegions', 'loadFilteredLocations'])
  },
  computed: {
    ...mapGetters(['substances', 'regions']),
    substance: {
      get () {
        const subId = parseInt(_.get(this.$route, 'query.substance'), 10) // Ensure it's an integer
        return this.substances.find(substance => parseInt(substance.substance_id) === subId) || null
      },
      set (substance) {
        const newQuery = {
          ...this.$route.query,
          substance: substance.substance_id
        }
        this.$router.push({ query: newQuery })
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
