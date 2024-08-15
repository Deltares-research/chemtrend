<template>
    <div class='map'>
      <mapbox-map
        ref='mapboxmap'
        class='map'
        :access-token='mapboxToken'
        map-style='mapbox://styles/mapbox/light-v11'
        :center='[4.7, 52.2]'
        :zoom='7'
      >
      <MapboxNavigationControl :visualizePitch='true' />
      <MapboxPopup v-if="popupItems.length != 0" :lng-lat="[popupLngLat.lng, popupLngLat.lat]" ref="popup">
        <data-table :tableHeaders="popupHeaders" :tableItems="popupItems" @mb-close="popupItems=[]"></data-table>
      </MapboxPopup>
    </mapbox-map>
    </div>
</template>

<script>
// import mapboxgl from 'mapbox-gl'
import { MapboxMap, MapboxNavigationControl, MapboxPopup } from '@studiometa/vue-mapbox-gl'
import DataTable from '@/components/DataTable.vue'

const initialData = {
  type: 'FeatureCollection',
  features: [
    {
      type: 'Feature',
      geometry: {
        type: 'Point',
        coordinates: []
      }
    }
  ]
}

export default {
  data () {
    return {
      mapboxToken: process.env.VUE_APP_MAPBOX_TOKEN,
      popupLngLat: { lng: 0, lat: 0 },
      popupHeaders: [
        {
          text: 'Properties',
          align: 'left',
          sortable: false,
          value: 'name',
          class: 'primary'
        },
        {
          style: 'font-color: blue',
          align: 'left',
          sortable: false,
          value: 'value',
          class: 'primary'
        }
      ],
      popupItems: []
    }
  },
  components: {
    MapboxMap,
    MapboxNavigationControl,
    MapboxPopup,
    DataTable
  },
  watch: {
    '$route.query.substance' (val, oldVal) {
      console.log(val, oldVal)
      this.updateFilteredLocations()
    }
  },
  mounted () {
    this.map = this.$refs.mapboxmap.map
    this.map.on('load', this.initializeData)
    console.log(this.$router, this.$route)
  },
  methods: {
    initializeData () {
      this.addLocations()
      this.addFilteredLocations()
      this.interactionMap()
    },
    addLocations () {
      this.map.addLayer({
        id: 'locations',
        type: 'circle',
        source: {
          type: 'geojson',
          data: `${process.env.VUE_APP_SERVER_URL}/locations/`
        },
        paint: {
          'circle-color': 'hsl(240, 3%, 94%)',
          'circle-stroke-color': '#4F5759',
          'circle-stroke-width': 1,
          'circle-radius': 5
        }
      })

      this.map.on('mouseenter', 'locations', (e) => {
        // Change the cursor style as a UI indicator.
        this.map.getCanvas().style.cursor = 'pointer'

        const properties = e.features[0].properties
        const tableItems = []
        Object.entries(properties).forEach(val => {
          tableItems.push({
            value: val[1],
            name: val[0]
          })
        })
        this.popupItems = tableItems

        this.popupLngLat = e.lngLat
      })

      this.map.on('mouseleave', 'locations', () => {
        this.popupItems = []
        this.map.getCanvas().style.cursor = ''
      })
    },

    addFilteredLocations () {
      this.map.addLayer({
        id: 'filtered-locations',
        type: 'circle',
        source: {
          type: 'geojson',
          data: initialData
        },
        paint: {
          'circle-color': [
            'case',
            [
              '<',
              ['get', 'trend'],
              0
            ],
            'hsl(0, 89%, 50%)',
            [
              '>',
              ['get', 'trend'],
              0
            ],
            'hsl(116, 88%, 59%)',
            [
              '==',
              ['get', 'trend'],
              0
            ],
            'black',
            'black'
          ],
          'circle-stroke-color': '#4F5759',
          'circle-stroke-width': 1,
          'circle-radius': 5
        }
      })
    },

    updateFilteredLocations () {
      console.log(this.$route.query.substance)
      this.map.getSource('filtered-locations')
        .setData(`${process.env.VUE_APP_SERVER_URL}/locations/${this.$route.query.substance}`)
    },
    interactionMap () {
      this.map.on('click', e => {
        // TODO: do we want to ease to a polygon or specific zoom level?
        this.map.easeTo({
          center: e.lngLat,
          zoom: 12,
          duration: 800
        })
        this.$route.path = '/trends'
        this.$router.push(this.$route)
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
