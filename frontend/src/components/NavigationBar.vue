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
    <img :src=rwsImgPath alt="Rijkswaterstaat Logo" height="40" />
    <img :src=deltaresImgPath alt="Deltares Logo" height="40" />
  </v-app-bar>
</template>

<script>
import deltaresLogo from '../assets/Deltares_logo_D-blauw_RGB.png'
import rwsLogo from '../assets/Rijkswaterstaat.png'
export default {
  data () {
    return {
      deltaresImgPath: deltaresLogo,
      rwsImgPath: rwsLogo
    }
  },
  methods: {
    startTour () {
      // Placeholder for future functionality to start the tour
      console.log('Tour button clicked!')
    }
  }
}
</script>
