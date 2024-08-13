<template>
  <v-app>
    <v-main>
    <navigation-bar @toggle-drawer="toggleDrawer" />
      <v-navigation-drawer v-model="drawer" persistent width="361">
        <navigation-drawer-tabs />
      </v-navigation-drawer>
      <div class="d-flex flex-column mb-6 content">
        <map-component class="flex-grow-1"/>
        <router-view></router-view>
      </div>
    </v-main>
  </v-app>
</template>

<script>
import NavigationBar from '@/components/NavigationBar'
import MapComponent from '@/components/MapComponent.vue'
import NavigationDrawerTabs from '@/components/NavigationDrawerTabs.vue'
import { mapActions } from 'vuex'

export default {
  name: 'App',
  components: {
    NavigationBar,
    MapComponent,
    NavigationDrawerTabs
  },
  data () {
    return {
      drawer: true,
      tab: null
    }
  },
  mounted () {
    // Load all data when website is mounted
    this.loadLocations()
  },
  methods: {
    ...mapActions(['loadLocations']),
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
