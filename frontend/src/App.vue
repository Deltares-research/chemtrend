<template>
  <v-app>
    <v-main>
      <navigation-bar @toggle-drawer="toggleDrawer" />
        <div class="d-flex flex-column content">
          <v-navigation-drawer v-model="drawer" persistent temporary disable-route-watcher :scrim="false" width="361">
            <navigation-drawer-tabs />
          </v-navigation-drawer>
          <map-component class="flex-grow-1" />
          <bottom-panel />
      </div>
    </v-main>
  </v-app>
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
      tab: null
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
</style>
