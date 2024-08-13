<template>
  <v-app>
    <navigation-bar />
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
  }
}
</script>
