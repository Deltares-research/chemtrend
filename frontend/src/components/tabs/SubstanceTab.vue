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
        <!-- <v-row>
        <v-expansion-panels flat>
          <v-expansion-panel>
          <v-expansion-panel-title>All substances</v-expansion-panel-title>
          <v-expansion-panel-text>
              <v-list :items="substances"></v-list>
          </v-expansion-panel-text>
          </v-expansion-panel>
        </v-expansion-panels>
      </v-row> -->
    </v-col>
  </div>
</template>

<script>
import { mapGetters, mapActions } from 'vuex'
import _ from 'lodash'

export default {
  name: 'SubstanceTab',
  methods: {
    ...mapActions(['loadSubstances', 'loadFilteredLocations', 'setSelectedSubstanceId'])
  },
  computed: {
    ...mapGetters(['substances']),
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
    }
  },
  created () {
    this.loadSubstances()
  }
}
</script>
