<template>
  <v-app>
    <navigation-bar @toggle-drawer="toggleDrawer" />
    <v-main>
      <v-navigation-drawer v-model="drawer" persistent width="361">
        <navigation-drawer-tabs />
      </v-navigation-drawer>
      <div class="map-container">
        <map-component />
      </div>
    </v-main>
  </v-app>
</template>

<script>
import NavigationBar from '@/components/NavigationBar'
import MapComponent from '@/components/MapComponent.vue'
import NavigationDrawerTabs from '@/components/NavigationDrawerTabs.vue'
import { mapMutations, mapGetters, mapActions } from 'vuex'

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
  mounted() {
    // Load all data when website is mounted
    this.loadLocations()
  },
  methods: {
    ...mapActions([loadLocations]),
    toggleDrawer () {
      this.drawer = !this.drawer
    }
  }
}
</script>

<style>
.map-container {
  position: fixed;
  top: 64px;
  bottom: 0;
  left: 0;
  right: 0;
}
</style>
