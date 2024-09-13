<template>
  <v-app-bar :elevation="2">
    <template v-slot:prepend>
        <v-app-bar-nav-icon  @click="$emit('toggle-drawer')"></v-app-bar-nav-icon>
    </template>

    <v-app-bar-title>CHEMtrend</v-app-bar-title>
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
  }
}
</script>
