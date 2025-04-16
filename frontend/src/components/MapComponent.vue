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
      <MapboxPopup v-if="popupItems.length != 0" :lng-lat="[popupLngLat.lng, popupLngLat.lat]" ref="popup" max-width="500px" :closeButton="false">
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
import { visualizationComponents } from '@/utils/colors'

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
  props: {
    mapPanel: {
      type: Boolean
    }
  },
  data () {
    return {
      mapboxToken: process.env.VUE_APP_MAPBOX_TOKEN,
      popupLngLat: { lng: 0, lat: 0 },
      popupHeaders: [
        {
          text: 'Eigenschappen',
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
      mapLocation: null,
      regionsGeojson: {},
      locationsLayerIds: []
    }
  },
  components: {
    MapboxMap,
    MapboxNavigationControl,
    MapboxPopup,
    DataTable
  },
  watch: {
    '$route.query.period' (val, oldVal) {
      this.updateFilteredLocations()
      this.checkSelection('locations')
    },
    '$route.query.substance' (val, oldVal) {
      this.updateFilteredLocations()
      this.checkSelection('locations')
    },
    '$route.query.region' (val, oldVal) {
      this.filterRegions()
    },
    '$store.state.zoomTo' (val) {
      if (val && this.mapLocation) {
        this.zoomToRegion(val)
      }
    },
    '$store.state.invisibleLayers': {
      handler (invisibleLayers) {
        (this.locationsLayerIds.concat('locations')).forEach(id => {
          if (invisibleLayers.indexOf(id) > -1) {
            this.map.setLayoutProperty(id, 'visibility', 'none')
          } else {
            this.map.setLayoutProperty(id, 'visibility', 'visible')
          }
        })
      },
      deep: true
    }
  },
  mounted () {
    this.map = this.$refs.mapboxmap.map
    this.map.on('load', this.initializeData)
  },
  computed: {
    ...mapGetters(['selectedSubstanceName', 'regions', 'selectedColor'])
  },
  methods: {
    ...mapActions(['addTrend']),
    initializeData () {
      this.loadMapSymbols()
      this.addLocations()
      this.addFilteredLayers()
      this.addRegions()
      this.interactionMap()
      this.addSelectionLayers()
      this.updateFilteredLocations()
      this.initializeMapWithLatLon()
    },
    addFilteredLayers () {
      Object.keys(visualizationComponents).forEach(direction => {
        const layerId = this.addFilteredLayer(direction, visualizationComponents[direction].shape)
        this.map.on('mouseenter', layerId, () => {
          this.map.getCanvas().style.cursor = 'pointer'
        })

        this.map.on('mouseleave', layerId, () => {
          this.map.getCanvas().style.cursor = ''
        })
        this.locationsLayerIds.push(layerId)
      })
    },
    loadMapSymbols () {
      Object.values(visualizationComponents).map(c => c.shape).forEach(shape => {
        this.map.loadImage(`./img/icons/${shape}.png`, (error, image) => {
          if (error) throw error
          this.map.addImage(shape, image)
        })
      })
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
      if (!this.map.getSource('selected-regions')) {
        return
      }
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
    addFilteredLayer (trendDirection, shape) {
      const layerId = `filtered-locations-${trendDirection}`
      this.map.addLayer({
        id: layerId,
        type: 'symbol',
        source: {
          type: 'geojson',
          data: initialData
        },
        layout: {
          'icon-image': shape,
          'icon-allow-overlap': true,
          'icon-ignore-placement': true
        },
        filter: ['==', 'trend_direction', trendDirection]
      })
      return layerId
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
          'circle-stroke-color': this.selectedColor,
          'circle-stroke-width': 3,
          'circle-radius': 4
        }
      })
    },

    updateFilteredLocations () {
      const substanceId = this.$route.query.substance || ''
      let url = `${process.env.VUE_APP_SERVER_URL}/locations/${substanceId}`
      const period = _.get(this.$route, 'query.period')
      if (period) {
        url += `?trend_period=${period}`
      }
      fetch(url)
        .then(res => {
          return res.json()
        })
        .then(response => {
          this.locationsLayerIds.forEach(layerId => {
            if (_.get(this.$route, 'query.substance') && this.map.getSource(layerId)) {
              this.map.getSource(layerId)
                .setData(response)
            }
          })
        })
    },
    updateRegion (lat, lng) {
      let url = `${process.env.VUE_APP_SERVER_URL}/regions/?x=${lng}&y=${lat}`
      const period = _.get(this.$route, 'query.period')
      if (period) {
        url += `&trend_period=${period}`
      }
      fetch(url)
        .then(res => {
          return res.json()
        })
        .then(response => {
          if (this.map.getSource('selected-regions')) {
            this.map.getSource('selected-regions')
              .setData(response)
          }
          this.regionsGeojson = response
        })
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
        // If zoomed in further than 10, don't zoom out on click
        let zoom = this.map.getZoom()
        if (zoom <= 10) {
          zoom = 10
        }
        this.map.easeTo({
          center: e.lngLat,
          zoom: zoom,
          duration: 800
        })
        this.map.once('moveend', () => {
          e.point = this.map.project([e.lngLat.lng, e.lngLat.lat])
          const newQuery = {
            ...this.$route.query, // Keep all existing query parameters, including 'substance'
            longitude: e.lngLat.lng,
            latitude: e.lngLat.lat
          }
          this.$router.push({
            path: '/trends',
            query: newQuery
          })
          this.checkSelection('locations')
          this.updateRegion(e.lngLat.lat, e.lngLat.lng)
        })
      })
    },
    checkSelection (shape) {
      if (!this.mapLocation) {
        return
      }

      // TODO: check layers and their names, to make it consistent so you can just use shape here
      let layer = shape
      if (shape === 'locations') {
        layer = this.locationsLayerIds
      } else {
        layer = [layer]
      }
      // changing the data from a period to another causes the projection to change
      // to be safe, we recompute every time
      const projectedCoordinates = this.map.project([this.mapLocation.lngLat.lng, this.mapLocation.lngLat.lat])
      const features = this.map.queryRenderedFeatures(projectedCoordinates, { layers: layer })
      this.map.getSource(`selected-${shape}`)
        .setData({
          type: 'FeatureCollection',
          features: features
        })

      features.forEach(feature => {
        const x = feature._geometry.coordinates[0]
        const y = feature._geometry.coordinates[1]
        const substanceId = parseInt(_.get(this.$route, 'query.substance'))
        const location = _.get(feature, 'properties.location_code', `longitude: ${x} & latitude: ${y}`)
        const periodId = parseInt(_.get(this.$route, 'query.period', 0))
        const periodName = _.get(this.$store.state, 'periods', []).find(p => p.id === periodId).name
        const name = `${this.selectedSubstanceName(substanceId)} op locatie ${location} (${periodName})`

        if (substanceId) {
          this.addTrend({ x, y, substanceId, name, currentLocation: location, periodId })
          this.$emit('update:bottomPanel', true)
        }
      })
    },
    zoomToRegion (name) {
      // const features = this.map.querySourceFeatures('selected-regions', { filter: ['match', ['get', 'region_type'], [name], true, false] })
      // Not all coordinates in geometries have the same depth.. Multipolygon vs polygon
      // for example, therefore I flatten the whole thing to 1D array and then get the lat lon
      // from there.
      if (!_.has(this.regionsGeojson, 'features')) {
        return
      }
      const feature = this.regionsGeojson.features.filter(feat => feat.properties.region_type === name)
      if (feature.length === 0) {
        return
      }
      const rawCoords = feature[0].geometry.coordinates.flat(Infinity)
      const lat = []
      const lon = []
      rawCoords.forEach((c, i) => {
        if ((i % 2) === 0) {
          lon.push(c)
        } else {
          lat.push(c)
        }
      })
      const bounds = [[
        Math.min(...lon), Math.min(...lat)
      ], [
        Math.max(...lon), Math.max(...lat)
      ]]
      this.map.fitBounds(bounds, { padding: { top: 10, bottom: 10, left: 40, right: 10 } })
      this.$store.state.zoomTo = null
    }
  }
}

</script>

<style lang='css'>
.mapboxgl-map, .map {
  width: 100%;
  height: 100%;
}

.point-layer-legend-container {
  position: absolute;
  top: 59px;
  right: 34px;
}
</style>
