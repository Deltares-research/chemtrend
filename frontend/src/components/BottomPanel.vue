<template>
  <v-sheet
    :class="drawer ? 'nav-open' : ''"
    height="100%"
    >
    <v-card height="100%">
      <v-toolbar density="compact" :color="showTooltip ? 'red' : ''">
        <v-tooltip v-model="warningColor" location="top">
          <template v-slot:activator="{ props }">
            <v-toolbar-title v-bind="props" >
              {{ writeNumberTrends() }}
            </v-toolbar-title>
          </template>
          <span>Er mogen maximaal 10 trends tegelijkertijd openstaan.</span>
        </v-tooltip>
        <v-spacer></v-spacer>
        <v-btn @click="$emit('update:bottomPanel', !bottomPanel )" flat :icon="bottomPanel ? 'mdi-arrow-expand-down' : 'mdi-arrow-expand-up'"></v-btn>
      </v-toolbar>
      <v-card-text class="bottom-panel ma-0 pa-0">
        <router-view></router-view>
      </v-card-text>
    </v-card>
  </v-sheet>
</template>

<script>
import { mapGetters } from 'vuex'

export default {
  props: {
    drawer: {
      type: Boolean
    },
    bottomPanel: {
      type: Boolean
    }
  },
  data () {
    return {
      showTooltip: false,
      warningColor: false
    }
  },
  watch: {
    trends () {
      if (this.trends.length >= 10) {
        this.showTooltip = true
        this.warningColor = true
        return
      }
      if (this.showTooltip !== false) {
        this.showTooltip = false
      }
      this.warningColor = false
    }
  },
  computed: {
    ...mapGetters(['trends'])
  },
  methods: {
    writeNumberTrends () {
      return 'Trendresultaten ' + this.trends.length + '/10'
    }
  }
}
</script>

<style scoped>
.nav-open {
  padding-left: 360px;
}

.bottom-panel {
  overflow-y: auto;
}
</style>
