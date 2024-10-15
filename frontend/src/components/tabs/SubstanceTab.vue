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
          <v-radio-group v-model="region">
            <v-radio v-for="region in regions" :key="region" :label="region" :value="region"></v-radio>
          </v-radio-group>
        </v-row>
    </v-col>
  </div>
</template>

<script>
import { mapGetters, mapActions } from 'vuex'
import _ from 'lodash'

export default {
  name: 'SubstanceTab',
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
        console.log('substance', substance)
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
        return _.get(this.$route, 'query.region', null) // Ensure it's an integer
      },
      set (region) {
        console.log('region', region)
        const newQuery = {
          ...this.$route.query,
          region: region
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
