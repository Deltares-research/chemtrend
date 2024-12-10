<template>
  <v-responsive>
    <v-app>
      <v-main>
        <navigation-bar @toggle-drawer="toggleDrawer" />
        <div class="d-flex flex-column content">
          <v-navigation-drawer v-model="drawer" persistent temporary disable-route-watcher :scrim="false" width="360">
            <navigation-drawer-tabs />
          </v-navigation-drawer>
          <map-component v-model:bottomPanel="bottomPanel" v-model:mapPanel="mapPanel" :class="toggleMapPanel ()" />
          <bottom-panel
            :class="toggleBottomPanel()"
            :drawer="drawer"
            v-model:bottomPanel="bottomPanel"
            v-model:mapPanel="mapPanel"
          />
      </div>
      </v-main>
    </v-app>
  </v-responsive>'
</template>

<script>
import NavigationBar from '@/components/NavigationBar'
import MapComponent from '@/components/MapComponent.vue'
import NavigationDrawerTabs from '@/components/NavigationDrawerTabs.vue'
import BottomPanel from '@/components/BottomPanel'

export default {
  name: 'App',
  components: {
    NavigationBar,
    MapComponent,
    NavigationDrawerTabs,
    BottomPanel
  },
  data () {
    return {
      drawer: true,
      tab: null,
      bottomPanel: false,
      mapPanel: true
    }
  },
  methods: {
    toggleDrawer () {
      this.drawer = !this.drawer
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
