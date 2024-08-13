<template>
    <div class="map">
      <mapbox-map
        ref="mapboxmap"
        class="map"
        :access-token="mapboxToken"
        map-style="mapbox://styles/mapbox/standard"
        :preserveDrawingBuffer="true"
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
      mapboxToken: process.env.VUE_APP_MAPBOX_TOKEN
    }
  },
  components: {
    MapboxMap,
    MapboxNavigationControl
  },
  mounted () {
    console.log(process.env.VUE_APP_MAPBOX_TOKEN)
  }
}

</script>

<style lang="css">
.mapboxgl-map, .map {
  width: 100%;
  height: 100%;
}

</style>
