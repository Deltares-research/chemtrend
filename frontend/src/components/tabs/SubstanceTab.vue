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
        <v-expansion-panels flat>
          <v-expansion-panel>
          <v-expansion-panel-title>All substances</v-expansion-panel-title>
          <v-expansion-panel-text>
              <v-list :items="substances"></v-list>
          </v-expansion-panel-text>
          </v-expansion-panel>
        </v-expansion-panels>
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
    ...mapActions(['loadSubstances', 'loadFilteredLocations', 'setSelectedSubstanceId'])
  },
  computed: {
    ...mapGetters(['substances']),
    substance: {
      get () {
        const subId = _.get(this.$route, 'query.substance')
        return this.substances.find(substance => substance.substance_id === subId)
      },
      set (substance) {
        console.log('substance', substance)
        this.$route.query = { substance: substance.substance_id }
        this.$router.push(this.$route)
        this.setSelectedSubstanceId(substance.substance_id)
      }
    }
  },
  created () {
    this.loadSubstances()
  }
}
</script>
