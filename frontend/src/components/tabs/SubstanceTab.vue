<template>
  <div class="content-wrapper">
    <v-col>
      <v-row>
        <h1>1. Trendperiode</h1>
      </v-row>
      <v-row>
        <v-slide-group
          show-arrows
          v-model="period"
          class="mb-5 mt-2"
          mandatory
          data-v-step="1"
          >
          <v-slide-group-item
            v-for="p in periods"
            :key="p.id"
            v-slot="{ isSelected, toggle }"
          >
            <v-btn
              :color="isSelected ? 'primary' : undefined"
              class="ma-1"
              rounded
              @click="toggle"
            >
              {{ p.name }}
            </v-btn>
          </v-slide-group-item>
        </v-slide-group>
      </v-row>
      <v-row>
        <h1>2. Chemische stoffen </h1>
      </v-row>
      <v-row v-model:selectedSubstance="selectedSubstance">
        <span :class="selectedSubstance ? 'd-none' : 'text-info'">
          Selecteer een chemische stof om de locaties te bekijken waar deze stof is gemeten.
        </span>
      </v-row>
      <v-row>
        <v-autocomplete
          label="Selecteer stof"
          :items="substances"
          class="autocomplete-list"
          item-value="substance_id"
          item-title="substance_description"
          :return-object="true"
          v-model="substance"
          data-v-step="2"
        ></v-autocomplete>
      </v-row>
      <v-row>
        <h1>3. Regio's </h1>
      </v-row>
      <v-row
        v-for="reg in regions"
        :key="reg.name"
        data-v-step="4">
        <v-switch
          v-model="region"
          :label="reg.name"
          :value="reg.name"
          :color="reg.color"
          hide-details
          multiple></v-switch>
        <v-spacer/>
        <v-tooltip text="Zoom naar deze regio" location="top">
          <template v-slot:activator="{ props }">
            <v-btn
              icon="mdi-magnify"
              flat size="x-small"
              :readonly="!region.includes(reg.name)"
              @click.stop="ZOOM_TO(reg.name)"
              v-bind="props"></v-btn>
          </template>
        </v-tooltip>
      </v-row>
      <v-row>
        <h1>  4. Kaartselectie </h1>
      </v-row>
      <v-row class="mb-3">
        <point-layer-legend data-v-step="5" @legend-click="handleLegendClick"></point-layer-legend>
      </v-row>
    </v-col>
  </div>
</template>

<script>
import { mapGetters, mapActions, mapMutations } from 'vuex'
import _ from 'lodash'
import PointLayerLegend from '@/components/tabs/PointLayerLegend'

export default {
  data () {
    return {
      selectedSubstance: false
    }
  },
  components: {
    PointLayerLegend
  },
  name: 'SubstanceTab',
  methods: {
    ...mapMutations(['ZOOM_TO', 'TOOGLE_VISIBLE_LAYERS']),
    ...mapActions(['loadPeriods', 'loadSubstances', 'loadRegions', 'loadFilteredLocations']),
    handleLegendClick (layerId) {
      this.TOOGLE_VISIBLE_LAYERS(layerId)
    }
  },
  computed: {
    ...mapGetters(['periods', 'substances', 'regions']),
    period: {
      get () {
        return parseInt(_.get(this.$route, 'query.period'), 10) // Ensure it's an integer
      },
      set (periodId) {
        const newQuery = {
          ...this.$route.query,
          period: periodId
        }
        this.$router.push({ query: newQuery })
      }
    },
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
        this.selectedSubstance = true
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
  watch: {
    // when no period trend is set in the URL, adding it by default the first period returned from the backend
    periods (newPeriods) {
      if (newPeriods.length > 0 && !this.period) {
        this.period = newPeriods[0].id
      }
    },
    '$route.query.substance' (newSubstance) {
      if (newSubstance) {
        this.selectedSubstance = true
      } else {
        this.selectedSubstance = false
      }
    }
  },
  created () {
    this.loadPeriods()
    this.loadSubstances()
    this.loadRegions()
  }
}
</script>
