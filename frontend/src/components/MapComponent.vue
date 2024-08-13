<template>
    <div class="map">
      <mapbox-map
        ref="mapboxmap"
        class="map"
        :access-token="mapboxToken"
        map-style="mapbox://styles/mapbox/light-v11"
        :preserveDrawingBuffer="true"
        :center="[4.7, 52.2]"
        :zoom="7"
      >
      <MapboxNavigationControl :visualizePitch="true" />
    </mapbox-map>
    </div>
</template>

<script>
// import mapboxgl from 'mapbox-gl'
import { MapboxMap, MapboxNavigationControl } from '@studiometa/vue-mapbox-gl'

export default {
  data () {
    return {
      mapboxToken: process.env.VUE_APP_MAPBOX_TOKEN,
    }
  },
  components: {
    MapboxMap,
    MapboxNavigationControl
  },
  mounted () {
    this.map = this.$refs.mapboxmap.map
    this.map.on('load', this.initializeData)
  },
  methods: {
    initializeData () {
      this.addLocations()
    },
    addLocations() {
      this.map.addLayer({
        id: 'locations',
        type: 'circle',
        source: {
          data: {
            type: 'geojson',
            data: `${process.env.VUE_APP_SERVER_URL}/locations_geojson/`
          }
        }
        paint: {
          'circle-color': '#4F5759',
          'circle-stroke-color': '#4F5759',
          'circle-radius': 2
        },
      })
    }
  }
}

</script>

<style lang="css">
.mapboxgl-map, .map {
  width: 100%;
  height: 100%;
}

</style>
