<template>
  <div>
    <v-tabs v-model="tab">
      <v-tab value="substances">
        <v-icon>mdi-flask</v-icon>
      </v-tab>
      <v-tab value="layers">
        <v-icon>mdi-layers</v-icon>
      </v-tab>
      <v-tab value="trends">
        <v-icon>mdi-chart-line</v-icon>
      </v-tab>
      <v-tab value="information">
        <v-icon>mdi-information</v-icon>
      </v-tab>
    </v-tabs>

    <v-card-text>
      <v-tabs-window v-model="tab">
        <v-tabs-window-item value="substances" class="tab-content">
          <div class="content-wrapper">
            <v-col>
              <v-row>
                <v-autocomplete
                  label="Select substance"
                  :items="substances"
                  class="autocomplete-list"
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
        </v-tabs-window-item>

        <v-tabs-window-item value="layers">
          Layers
        </v-tabs-window-item>

        <v-tabs-window-item value="trends">
          Trends
        </v-tabs-window-item>

        <v-tabs-window-item value="information">
          Information
        </v-tabs-window-item>
      </v-tabs-window>
    </v-card-text>
  </div>
</template>

<script>
import { mapGetters, mapActions } from 'vuex'

export default {
  name: 'NavigationDrawerTabs',

  data () {
    return {
      tab: null
    }
  },
  methods: {
    ...mapActions(['setSubstances'])
  },
  computed: {
    ...mapGetters(['substances'])
  },
  created () {
    this.setSubstances(this.substances)
  }
}
</script>

<style scoped>
.tab-content {
  display: flex;
  justify-content: center;
  margin-top: 20px;
}

.content-wrapper {
  display: flex;
  flex-direction: column;
  justify-content: center;
  align-items: center;
  width: 80%;
}
</style>
