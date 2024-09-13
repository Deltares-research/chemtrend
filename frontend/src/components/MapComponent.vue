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
import { mapActions, mapGetters } from 'vuex'
import { MapboxMap, MapboxNavigationControl, MapboxPopup } from '@studiometa/vue-mapbox-gl'
import DataTable from '@/components/DataTable.vue'
import _ from 'lodash'

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
      popupItems: [],
      map: null
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
      this.updateFilteredLocations()
    }
  },
  mounted () {
    this.map = this.$refs.mapboxmap.map
    this.map.on('load', this.initializeData)
  },
  computed: {
    ...mapGetters(['panelIsCollapsed', 'selectedSubstanceId'])
  },
  methods: {
    ...mapActions(['addTrend', 'togglePanelCollapse']),

    initializeData () {
      this.addLocations()
      this.addWaterbodies()
      this.addFilteredLocations()
      this.interactionMap()
      this.addSelectionLayers()
      this.updateFilteredLocations()
      const lat = _.get(this.$route, 'query.latitude')
      const lng = _.get(this.$route, 'query.longitude')
      if (lat && lng) {
        this.map.fire('click', {
          lngLat: { lat: lat, lng: lng }, originalEvent: { target: this.map }
        })
      }
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
          // 'circle-color': 'rgba(239, 239, 240, 1)',
          'circle-color': 'black',
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

    addWaterbodies () {
      this.map.addLayer({
        id: 'waterbodies',
        type: 'fill',
        source: {
          type: 'geojson',
          data: `${process.env.VUE_APP_SERVER_URL}/waterbodies/`
        },
        paint: {
          'fill-color': 'rgba(239, 239, 240, 0)'
        }
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
          'circle-color': '#57b146',
          // TODO: colour based on trend value, based on code below
          // [
          //   'case',
          //   [
          //     '<',
          //     ['get', 'trend'],
          //     0
          //   ],
          //   'hsl(0, 89%, 50%)',
          //   [
          //     '>',
          //     ['get', 'trend'],
          //     0
          //   ],
          //   'hsl(116, 88%, 59%)',
          //   [
          //     '==',
          //     ['get', 'trend'],
          //     0
          //   ],
          //   'black',
          //   'black'
          // ],
          'circle-stroke-color': '#4F5759',
          'circle-stroke-width': 1,
          'circle-radius': 5
        }
      })
    },
    addSelectionLayers () {
      this.map.addLayer({
        id: 'selected-locations',
        type: 'circle',
        source: {
          type: 'geojson',
          data: initialData
        },
        paint: {
          'circle-color': 'rgba(239, 239, 240, 0)',
          'circle-stroke-color': 'hsl(188, 59%, 50%)',
          'circle-stroke-width': 3,
          'circle-radius': 4
        }
      })
      this.map.addLayer({
        id: 'selected-waterbodies',
        type: 'line',
        source: {
          type: 'geojson',
          data: initialData
        },
        paint: {
          'line-color': 'hsl(188, 59%, 50%)',
          'line-width': 3
        }
      })
    },

    updateFilteredLocations () {
      if (_.get(this.$route, 'query.substance') && this.map.getSource('filtered-locations')) {
        this.map.getSource('filtered-locations')
          .setData(`${process.env.VUE_APP_SERVER_URL}/locations/${this.$route.query.substance}`)
      }
    },
    interactionMap () {
      this.map.on('click', e => {
        if (this.panelIsCollapsed) {
          this.togglePanelCollapse()
        }
        const newQuery = {
          ...this.$route.query, // Keep all existing query parameters, including 'substance'
          latitude: e.lngLat.lat,
          longitude: e.lngLat.lng
        }
        // TODO: implement clearTrends
        // this.clearTrends()
        // TODO: do we want to ease to a polygon or specific zoom level?
        this.map.easeTo({
          center: e.lngLat,
          zoom: 12,
          duration: 800
        })

        this.$router.push({
          path: '/trends',
          query: newQuery
        })

        const shapes = ['waterbodies', 'locations']

        shapes.forEach(shape => {
          const features = this.map.queryRenderedFeatures(e.point, { layers: [shape] })
          this.map.getSource(`selected-${shape}`)
            .setData({
              type: 'FeatureCollection',
              features: features
            })
          features.forEach(feature => {
            const x = feature._geometry.coordinates[0]
            const y = feature._geometry.coordinates[1]
            const substanceId = this.selectedSubstanceId

            this.addTrend({ x, y, substanceId }, shape)
          })
        })
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
