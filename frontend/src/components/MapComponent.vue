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
      map: null,
      mapLocation: null
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
    },
    '$route.query.region' (val, oldVal) {
      this.filterRegions()
    }
  },
  mounted () {
    this.map = this.$refs.mapboxmap.map
    this.map.on('load', this.initializeData)
  },
  computed: {
    ...mapGetters(['selectedSubstanceId', 'regions']),
    bottomPanel: {
      type: Boolean
    }
  },
  methods: {
    ...mapActions(['addTrend']),

    initializeData () {
      this.addLocations()
      this.addFilteredLocations()
      this.addRegions()
      this.interactionMap()
      this.addSelectionLayers()
      this.updateFilteredLocations()
      this.initializeMapWithLatLon()
    },
    addLocations () {
      const name = 'locations'
      this.map.addLayer({
        id: name,
        type: 'circle',
        source: {
          type: 'geojson',
          data: `${process.env.VUE_APP_SERVER_URL}/locations/`
        },
        paint: {
          // 'circle-color': 'rgba(239, 239, 240, 1)',
          'circle-color': 'white',
          'circle-stroke-color': '#000000',
          'circle-stroke-width': 1,
          'circle-radius': 5
        }
      }).on('load', () => {
        this.checkSelection(name)
      })

      this.map.on('mouseenter', name, (e) => {
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

      this.map.on('mouseleave', name, () => {
        this.popupItems = []
        this.map.getCanvas().style.cursor = ''
      })
    },

    addRegions () {
      const name = 'regions'
      const paintColor = ['match']
      paintColor.push(['get', 'region_type'])
      this.regions.forEach(region => {
        paintColor.push(region.name)
        paintColor.push(region.color)
      })
      paintColor.push('#000000')
      this.map.addLayer({
        id: `selected-${name}`,
        type: 'line',
        source: {
          type: 'geojson',
          data: initialData
        },
        paint: {
          'line-color': paintColor,
          'line-width': 3
        }
      })
      this.filterRegions()
    },
    filterRegions () {
      this.map.setFilter(
        'selected-regions', [
          'match',
          ['get', 'region_type'],
          _.get(this.$route, 'query.region', '').split(','),
          true,
          false
        ]
      )
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
          'circle-color': ['get', 'color'],
          'circle-stroke-color': '#000000',
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
    },

    updateFilteredLocations () {
      if (_.get(this.$route, 'query.substance') && this.map.getSource('filtered-locations')) {
        this.map.getSource('filtered-locations')
          .setData(`${process.env.VUE_APP_SERVER_URL}/locations/${this.$route.query.substance}`)
      }
    },
    updateRegion (lat, lng) {
      const url = `${process.env.VUE_APP_SERVER_URL}/regions/?x=${lng}&y=${lat}`
      if (this.map.getSource('selected-regions')) {
        this.map.getSource('selected-regions')
          .setData(url)
      }
    },
    initializeMapWithLatLon () {
      const lat = _.get(this.$route, 'query.latitude')
      const lng = _.get(this.$route, 'query.longitude')
      if (lat && lng) {
        this.map.fire('click', {
          lngLat: { lat, lng }, originalEvent: { target: this.map }
        })
      }
    },
    interactionMap () {
      this.map.on('click', e => {
        this.mapLocation = e
        this.map.easeTo({
          center: e.lngLat,
          zoom: 10,
          duration: 800
        })
        this.map.once('moveend', () => {
          e.point = this.map.project([e.lngLat.lng, e.lngLat.lat])
          const newQuery = {
            ...this.$route.query, // Keep all existing query parameters, including 'substance'
            latitude: e.lngLat.lat,
            longitude: e.lngLat.lng
          }
          this.$router.push({
            path: '/trends',
            query: newQuery
          })
          this.checkSelection('locations')
          this.updateRegion(e.lngLat.lat, e.lngLat.lng)
          this.$emit('update:bottomPanel', true)
        })
      })
    },
    checkSelection (shape) {
      const features = this.map.queryRenderedFeatures(this.mapLocation.point, { layers: [shape] })
      this.map.getSource(`selected-${shape}`)
        .setData({
          type: 'FeatureCollection',
          features: features
        })

      console.log(features)
      features.forEach(feature => {
        const x = feature._geometry.coordinates[0]
        const y = feature._geometry.coordinates[1]
        const substanceId = _.get(this.$route, 'query.substance')

        if (substanceId) {
          this.addTrend({ x, y, substanceId })
        }
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
