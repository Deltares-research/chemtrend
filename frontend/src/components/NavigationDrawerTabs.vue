<template>
  <div>
    <v-tabs v-model="tab" grow >
      <v-tab value="substances">
        <v-icon>mdi-flask</v-icon>
      </v-tab>
      <v-tab value="information">
        <v-icon>mdi-information</v-icon>
      </v-tab>
    </v-tabs>

    <v-card-text>
      <v-tabs-window v-model="tab">

        <v-tabs-window-item value="substances" class="tab-content">
          <substance-tab />
        </v-tabs-window-item>

        <v-tabs-window-item value="information" class="tab-content">
          <information-tab />
        </v-tabs-window-item>

      </v-tabs-window>
    </v-card-text>
  </div>
</template>

<script>
import SubstanceTab from '@/components/SubstanceTab.vue'
import InformationTab from '@/components/tabs/InformationTab.vue'

export default {
  name: 'NavigationDrawerTabs',

  data () {
    return {
      tab: 'substances'
    }
  },
  components: {
    SubstanceTab,
    InformationTab
  }
}
</script>
