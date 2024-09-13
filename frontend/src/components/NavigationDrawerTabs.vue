<template>
  <div>
    <v-tabs v-model="tab" grow >
      <v-tab value="substances">
        <v-icon>mdi-flask</v-icon>
      </v-tab>
      <v-tab value="layers">
        <v-icon>mdi-layers</v-icon>
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

        <v-tabs-window-item value="layers">
          Layers
        </v-tabs-window-item>

        <v-tabs-window-item value="information">
          Information
        </v-tabs-window-item>
      </v-tabs-window>
    </v-card-text>
  </div>
</template>

<script>
import SubstanceTab from '@/components/tabs/SubstanceTab.vue'

export default {
  name: 'NavigationDrawerTabs',

  data () {
    return {
      tab: null
    }
  },
  components: {
    SubstanceTab
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
