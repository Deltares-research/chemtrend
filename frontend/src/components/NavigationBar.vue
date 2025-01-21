<template>
  <v-app-bar :elevation="2">
    <template v-slot:prepend>
        <v-app-bar-nav-icon  @click="$emit('toggle-drawer')"></v-app-bar-nav-icon>
    </template>
    <v-btn
      icon
      class="tour-button"
      @click="startTour"
    >
      <v-icon>mdi-flag-outline</v-icon>
    </v-btn>
    <v-app-bar-title>
      <a href="/">CHEMtrend</a>
    </v-app-bar-title>
    <v-spacer></v-spacer>
    <a :href="rwsLink" target="_blank">
      <img :src=rwsImgPath alt="Rijkswaterstaat Logo" height="40" />
    </a>
    <a :href="deltaresLink" target="_blank">
      <img :src="deltaresImgPath" alt="Deltares Logo" height="40" />
    </a>
  </v-app-bar>
</template>

<script>
import deltaresLogo from '../assets/Deltares_logo_D-blauw_RGB.png'
import rwsLogo from '../assets/Rijkswaterstaat.png'
export default {
  data () {
    return {
      deltaresImgPath: deltaresLogo,
      deltaresLink: 'https://www.deltares.nl/over-ons',
      rwsImgPath: rwsLogo,
      rwsLink: 'https://www.rijkswaterstaat.nl/over-ons'
    }
  },
  methods: {
    startTour () {
      const tourManager = this.$root.$refs.tourManager
      if (tourManager) {
        tourManager.startTour()
      } else {
        console.error('TourManager not found. Ensure it is registered as a ref in App.vue.')
      }
    }
  }
}
</script>
