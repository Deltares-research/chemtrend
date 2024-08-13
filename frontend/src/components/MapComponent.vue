<template>
    <div class='map'>
      <mapbox-map
        ref='mapboxmap'
        class='map'
        :access-token='mapboxToken'
        map-style='mapbox://styles/mapbox/light-v11'
        :preserveDrawingBuffer='true'
        :center='[4.7, 52.2]'
        :zoom='7'
      >
      <MapboxNavigationControl :visualizePitch='true' />
    </mapbox-map>
    </div>
</template>

<script>
// import mapboxgl from 'mapbox-gl'
import { MapboxMap, MapboxNavigationControl } from '@studiometa/vue-mapbox-gl'

const testLocations = {
  type: 'FeatureCollection',
  features: [
    {
      type: 'Feature',
      properties: {},
      geometry: {
        coordinates: [
          5.145777368152608,
          52.05497715243345
        ],
        type: 'Point'
      }
    },
    {
      type: 'Feature',
      properties: {},
      geometry: {
        coordinates: [
          5.210791458255784,
          51.922306228142446
        ],
        type: 'Point'
      }
    },
    {
      type: 'Feature',
      properties: {},
      geometry: {
        coordinates: [
          5.055267556439617,
          52.00478114570629
        ],
        type: 'Point'
      }
    },
    {
      type: 'Feature',
      properties: {},
      geometry: {
        coordinates: [
          5.343369174823067,
          52.010273981845444
        ],
        type: 'Point'
      }
    }
  ]
}

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
    this.map = this.$refs.mapboxmap.map
    this.map.on('load', this.initializeData)
  },
  methods: {
    initializeData () {
      this.addLocations()
      this.interactionMap()
    },
    addLocations () {
      this.map.addLayer({
        id: 'locations',
        type: 'circle',
        source: {
          type: 'geojson',
          // data: `${process.env.VUE_APP_SERVER_URL}/locations_geojson/`
          data: testLocations
        },
        paint: {
          'circle-color': 'red',
          'circle-stroke-color': '#4F5759',
          'circle-stroke-width': 1,
          'circle-radius': 5
        }
      })
    },
    interactionMap () {
      this.map.on('click', e => {
        // TODO: do we want to ease to a polygon or specific zoom level?
        this.map.easeTo({
          center: e.lngLat,
          zoom: 12,
          duration: 800
        })
        this.$router.push('/trends')
      })
    }
  }
}

</script>

<style lang='css'>
.mapboxgl-map, .map {
  width: 100%;
  height: 100%;
}

</style>
