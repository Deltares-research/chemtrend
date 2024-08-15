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
          @update:model-value="setSubstance"
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

export default {
  name: 'SubstanceTab',
  methods: {
    ...mapActions(['loadSubstances', 'loadFilteredLocations']),
    setSubstance (substance) {
      this.$route.query = { substance: substance.substance_id }
      this.$router.push(this.$route)
    }
  },
  computed: {
    ...mapGetters(['substances'])
  },
  created () {
    this.loadSubstances()
  }
}
</script>
