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
          <span>Er mogen maximaal 10 trends tegelijkertijd openstaan</span>
        </v-tooltip>
        <v-spacer></v-spacer>

        <graph-info></graph-info>

        <v-dialog max-width="500">
          <template v-slot:activator="{ props: dialog }">
            <v-tooltip text="Verwijder alle trends" location="top">
              <template v-slot:activator="{ props: tooltip }">
                <v-btn icon="mdi-delete-outline" v-bind="mergeProps(dialog, tooltip)"></v-btn>
              </template>
            </v-tooltip>
          </template>
          <template v-slot:default="{ isActive }">
            <v-card title="Verwijder alle trends">
              <v-card-text>
                Weet u zeker dat u alle open trends wilt verwijderen?
              </v-card-text>

              <v-card-actions>
                <v-spacer></v-spacer>
                <v-btn text="Verwijder trends" @click.stop="CLEAR_TRENDS() ; isActive.value = false" variant="flat" color="red"></v-btn>
                <v-btn text="Annuleren" @click="isActive.value = false"></v-btn>
              </v-card-actions>
            </v-card>
          </template>
        </v-dialog>

        <v-tooltip  :text="mapPanel ? 'Verberg kaart' : 'Kaart weergeven'" location="top">
          <template #activator="{ props }">
            <v-btn
              @click="$emit('update:mapPanel', !mapPanel )"
              flat
              :icon="mapPanel ? 'mdi-earth-off' : 'mdi-earth'"
              v-bind="props">
            </v-btn>
          </template>
        </v-tooltip>
        <v-tooltip :text="bottomPanel ? 'Paneel uitvouwen' : 'Paneel samenvouwen'" location="top">
          <template #activator="{ props }">
            <v-btn
              @click="$emit('update:bottomPanel', !bottomPanel )"
              flat
              :icon="bottomPanel ? 'mdi-arrow-expand-down' : 'mdi-arrow-expand-up'"
              v-bind="props">
            </v-btn>
          </template>
        </v-tooltip>
      </v-toolbar>
      <v-card height="100%" class="bottom-panel" :max-height="mapPanel ? '50vh' : '83vh'">
        <v-card-text class="bottom-panel ma-0 pa-0">
          <v-alert v-if="trends.length===0" color="info" variant="outlined" density="compact">
            Selecteer een stof en een locatie op de kaart om de trends te zien.
          </v-alert>
          <router-view></router-view>
        </v-card-text>
      </v-card>
    </v-card>
  </v-sheet>
</template>

<script>
import { mapGetters, mapMutations } from 'vuex'
import { mergeProps } from 'vue'
import GraphInfo from './graphs/GraphInfo'

export default {
  components: {
    GraphInfo
  },
  props: {
    drawer: {
      type: Boolean
    },
    bottomPanel: {
      type: Boolean
    },
    mapPanel: {
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
    ...mapMutations(['CLEAR_TRENDS']),
    mergeProps,
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
