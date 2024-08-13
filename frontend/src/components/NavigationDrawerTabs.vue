<template>
  <div>
    <v-tabs v-model="tab" >
      <v-tab value="substances"> <v-icon> mdi-flask </v-icon> </v-tab>
      <v-tab value="layers"> <v-icon> mdi-layers </v-icon> </v-tab>
      <v-tab value="trends"> <v-icon> mdi-chart-line </v-icon> </v-tab>
      <v-tab value="information"> <v-icon> mdi-information </v-icon> </v-tab>
    </v-tabs>

    <v-card-text>
      <v-tabs-window v-model="tab">
        <v-tabs-window-item value="substances">
          Substances
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
      tab: null
    }
  }
}
</script>
