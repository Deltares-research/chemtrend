<template>
  <v-responsive>
    <v-app>
      <v-main>
        <navigation-bar @toggle-drawer="toggleDrawer" />
        <div class="d-flex flex-column content">
          <v-navigation-drawer v-model="drawer" persistent temporary disable-route-watcher :scrim="false" width="360">
            <navigation-drawer-tabs />
          </v-navigation-drawer>
          <map-component v-model:bottomPanel="bottomPanel" :class="bottomPanel ? 'h-40' : 'h-100'" />
          <bottom-panel
            :class="bottomPanel ? 'h-60' : 'h-0'"
            :drawer="drawer"
            v-model:bottomPanel="bottomPanel"
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
      bottomPanel: false
    }
  },
  methods: {
    toggleDrawer () {
      this.drawer = !this.drawer
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
</style>
