<template>
  <v-responsive>
    <v-app>
      <v-main>
        <navigation-bar @toggle-drawer="toggleDrawer" data-v-step="0" />
        <div class="d-flex flex-column content">
          <v-navigation-drawer v-model="drawer" persistent temporary disable-route-watcher :scrim="false" width="360" data-v-step="1">
            <navigation-drawer-tabs />
          </v-navigation-drawer>
          <map-component
            v-model:bottomPanel="bottomPanel"
            :class="bottomPanel ? 'h-40' : 'h-100-48'"
            data-v-step="2"
          />
          <bottom-panel
            :class="bottomPanel ? 'h-60' : 'h-48'"
            :drawer="drawer"
            v-model:bottomPanel="bottomPanel"
          />
      </div>
      </v-main>
    </v-app>
    <v-tour name="myTour" :steps="steps"></v-tour>
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
      bottomPanel: false,
      steps: [
        {
          target: '[data-v-step="0"]',
          content: 'Welkom op het CHEMtrend platform!',
          params: { placement: 'bottom' }
        },
        {
          target: '[data-v-step="1"]',
          header: { title: 'Navigation Drawer' },
          content: 'This is your navigation drawer. Use it to navigate through the app.',
          params: { placement: 'right' }
        },
        {
          target: '[data-v-step="2"]',
          header: { title: 'Map Component' },
          content: 'This is the map component where you can view and interact with maps.'
        }
      ]
    }
  },
  methods: {
    toggleDrawer () {
      this.drawer = !this.drawer
    }
  },
  mounted () {
    this.$tours.myTour.start()
    console.log(this.$tours)
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
