<template>
  <v-app>
    <navigation-bar @toggle-drawer="drawer = !drawer"  />
    <v-navigation-drawer  v-model="drawer" app />
    <v-main>
      <map-component />
    </v-main>
  </v-app>
</template>

<script>
import NavigationBar from '@/components/NavigationBar'
import MapComponent from '@/components/MapComponent.vue'

export default {
  name: 'App',
  components: {
    NavigationBar,
    MapComponent
  },
  data () {
    return {
      drawer: false
    }
  }
}
</script>
