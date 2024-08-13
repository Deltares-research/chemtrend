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
                  :items="substanceList"
                  class="autocomplete-list"
                ></v-autocomplete>
              </v-row>
              <v-row>
                <v-expansion-panels flat>
                  <v-expansion-panel>
                    <v-expansion-panel-title>All substances</v-expansion-panel-title>
                    <v-expansion-panel-text>
                      <v-list :items="substanceList"></v-list>
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
export default {
  name: 'NavigationDrawerTabs',

  data () {
    return {
      tab: null,
      substanceList: ['Substance A', 'Substance B', 'Substance C', 'Substance D', 'Substance E', 'Substance F']
    }
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
