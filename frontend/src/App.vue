<template>
  <v-responsive>
    <v-app>
      <v-main>
        <navigation-bar @toggle-drawer="toggleDrawer" />
        <div class="d-flex flex-column content">
          <v-navigation-drawer  data-v-step="1" v-model="drawer" persistent temporary disable-route-watcher :scrim="false" width="360">
            <navigation-drawer-tabs />
          </v-navigation-drawer>
          <map-component
            v-model:bottomPanel="bottomPanel"
            :class="bottomPanel ? 'h-40' : 'h-100-48'"
          />
          <v-btn color="primary" @click="startTour">Start Tour</v-btn>
          <v-tour
            ref="tour"
            :steps="steps"
            name="introduction"
          />
          <bottom-panel
            :class="bottomPanel ? 'h-60' : 'h-48'"
            :drawer="drawer"
            v-model:bottomPanel="bottomPanel"
          />
      </div>
      </v-main>
    </v-app>
  </v-responsive>'
</template>

<script>
import { ref } from 'vue'
import VTour from 'vue-tour/dist/vue-tour.umd' // Import VueTour directly
import 'vue-tour/dist/vue-tour.css'
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
    BottomPanel,
    VTour
  },
  data () {
    return {
      drawer: true,
      tab: null,
      bottomPanel: false
    }
  },
  setup () {
    const tour = ref(null) // Tour reference
    const steps = [
      { target: '[data-v-step="1"]', content: 'This is step 1!', params: { placement: 'bottom' } },
      { target: '[data-v-step="2"]', content: 'This is step 2!', params: { placement: 'top' } }
    ]

    const startTour = () => {
      if (tour.value) {
        console.log('Tour is starting:', tour.value)
        tour.value.start()
      } else {
        console.warn('Tour reference is still null')
      }
    }

    return {
      tour,
      steps,
      startTour
    }
  },
  mounted () {
    console.log('Mounted - Tour:', this.tour)
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

.h-100-48 {
  height: calc(100% - 48px) !important
}

.h-48 {
  height: 48px !important
}
</style>
