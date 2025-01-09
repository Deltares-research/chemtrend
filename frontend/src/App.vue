<template>
  <v-responsive>
    <v-app>
      <v-main>
        <navigation-bar @toggle-drawer="toggleDrawer" data-v-step="0" />
        <div class="d-flex flex-column content">
          <v-navigation-drawer v-model="drawer" persistent temporary disable-route-watcher :scrim="false" width="360">
            <navigation-drawer-tabs data-v-step="3" />
          </v-navigation-drawer>
          <map-component v-model:bottomPanel="bottomPanel" v-model:mapPanel="mapPanel" :class="toggleMapPanel ()" data-v-step="2" />
          <bottom-panel
            :class="toggleBottomPanel()"
            :drawer="drawer"
            v-model:bottomPanel="bottomPanel"
            v-model:mapPanel="mapPanel"
          />
      </div>
      </v-main>
    </v-app>
    <disclaimer v-if="showDisclaimer"/>
    <TourManager ref="tourManager" />
  </v-responsive>
</template>

<script>
import NavigationBar from '@/components/NavigationBar'
import MapComponent from '@/components/MapComponent.vue'
import NavigationDrawerTabs from '@/components/NavigationDrawerTabs.vue'
import BottomPanel from '@/components/BottomPanel'
import TourManager from '@/components/TourManager.vue'
import Disclaimer from '@/components/Disclaimer.vue'
import { mapActions, mapGetters } from 'vuex'

export default {
  name: 'App',
  components: {
    NavigationBar,
    MapComponent,
    NavigationDrawerTabs,
    BottomPanel,
    TourManager,
    Disclaimer
  },
  data () {
    return {
      drawer: true,
      tab: null,
      bottomPanel: false,
      mapPanel: true
    }
  },
  computed: {
    ...mapGetters(['disclaimerAcknowledged']),
    showDisclaimer () {
      return !this.disclaimerAcknowledged
    }
  },
  methods: {
    ...mapActions(['loadDisclaimerAcknowledgment']),
    toggleDrawer () {
      this.drawer = !this.drawer
    },
    startGlobalTour () {
      this.$refs.tourManager.addStep({
        target: '[data-v-step="0"]',
        content: 'Welkom op het CHEMtrend platform.',
        params: { placement: 'bottom' }
      })
      this.$refs.tourManager.addStep({
        target: '[data-v-step="1"]',
        content: 'Selecteer een stof.',
        params: {
          placement: 'right'
        }
      })
      this.$refs.tourManager.addStep({
        target: '[data-v-step="2"]',
        content: 'Klik op een locatie.',
        params: {
          placement: 'top',
          modifiers: [
            {
              name: 'offset',
              options: {
                offset: [0, -500]
              }
            }
          ]
        }
      })
      this.$refs.tourManager.addStep({
        target: '[data-v-step="3"]',
        content: 'Selecteer een regio.',
        params: {
          placement: 'right'
        }
      })
      this.$refs.tourManager.addStep({
        target: '[data-v-step="4"]',
        content: 'Kijk hier voor meer informatie.',
        params: {
          placement: 'bottom'
        }
      })
    },
    toggleMapPanel () {
      if (!this.mapPanel) {
        return 'h-0'
      }
      return this.bottomPanel ? 'h-40' : 'h-100-48'
    },
    toggleBottomPanel () {
      if (!this.bottomPanel) {
        return 'h-48'
      }
      return this.mapPanel ? 'h-60' : 'h-100-48'
    }
  },
  created () {
    this.loadDisclaimerAcknowledgment()
  },
  mounted () {
    this.startGlobalTour()
  }
}
</script>

<style>
.content {
  max-height: 100vh;
  height: 100%;
}

html {
  overflow-y: hidden !important;
}

.h-60 {
  height: 60% !important
}

.h-40 {
  height: 40% !important
}

.h-100-48 {
  height: calc(100% - 48px) !important
}

.h-48 {
  height: 48px !important
}
</style>
