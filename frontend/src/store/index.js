import { createStore } from 'vuex'
import _ from 'lodash'
import { toRaw } from 'vue'

export default createStore({
  state: {
    substances: [],
    trends: [],
    regions: [],
    panelTrigger: false,
    selectedColor: '#9f4a96',
    zoomTo: '',
    disclaimerAcknowledged: false
  },
  getters: {
    substances (state) {
      return state.substances
    },
    selectedSubstanceName: (state) => (id) => {
      const substance = state.substances.find(sub => sub.substance_id === id)
      const substanceName = _.upperFirst(substance.substance_description)
      return substanceName
    },
    trends (state) {
      return state.trends
    },
    panelTrigger (state) {
      return state.panelTrigger
    },
    regions (state) {
      return state.regions
    },
    selectedColor (state) {
      return state.selectedColor
    },
    disclaimerAcknowledged (state) {
      return state.disclaimerAcknowledged
    }
  },
  mutations: {
    SET_SUBSTANCES (state, data) {
      state.substances = data
    },
    SET_REGIONS (state, regions) {
      state.regions = regions
    },
    CLEAR_TRENDS (state) {
      state.trends = []
    },
    ADD_TREND (state, trend) {
      let existingTrend = false
      state.trends = state.trends.map(t => {
        if (t.name === trend.name) {
          existingTrend = true
          if (t.loading || t.error) {
            trend.loading = false
            trend.state = 'open'
            trend.error = t.error
            return trend
          } else {
            t.state = 'open'
            return t
          }
        } else {
          t.state = 'closed'
          return t
        }
      })
      if (!existingTrend) {
        trend.state = 'open'
        state.trends.unshift(trend)
      }
    },
    ADD_ERROR_TREND (state, props) {
      state.trends = state.trends.map(trend => {
        if (trend.name === props.name) {
          trend.loading = false
          trend.error = props.message
        }
        return trend
      })
    },
    SET_TREND_STATE (state, name) {
      state.trends.forEach(t => {
        if (t.name === name) {
          t.state = 'open'
        } else {
          t.state = 'closed'
        }
      })
      state.panelTrigger = !state.panelTrigger
    },
    REMOVE_TREND (state, name) {
      state.trends = state.trends.filter(t => t.name !== name)
    },
    ADD_LOADING_TREND (state, trend) {
      console.log('loading trend')
      state.trends.unshift(trend)
    },
    ZOOM_TO (state, zoomLayerName) {
      state.zoomTo = zoomLayerName
    },
    SET_DISCLAIMER_ACKNOWLEDGED (state, value) {
      state.disclaimerAcknowledged = value
    }
  },
  actions: {
    loadSubstances (store) {
      const url = `${process.env.VUE_APP_SERVER_URL}/substances/`
      fetch(url)
        .then(res => {
          return res.json()
        })
        .then(response => {
          store.commit('SET_SUBSTANCES', response)
        })
    },
    loadRegions (store) {
      const url = `${process.env.VUE_APP_SERVER_URL}/list_regions/`
      fetch(url)
        .then(res => {
          return res.json()
        })
        .then(response => {
          const colorsForColorBlindness = ['#dccd7d', '#7e2954', '#5da899', '#2e2585']
          response.forEach((region, index) => {
            region.color = colorsForColorBlindness[index % colorsForColorBlindness.length]
          })
          store.commit('SET_REGIONS', response)
        })
    },
    addTrend (store, { x, y, substanceId, name, currentLocation }) {
      const existingTrend = store.state.trends.find(t => {
        return toRaw(t).name === name
      })
      if (existingTrend !== undefined) {
        store.commit('SET_TREND_STATE', name)
        if (!existingTrend.loading) {
          return
        }
      }

      if (store.state.trends.length >= 10) {
        return
      }

      const urlTrends = `${process.env.VUE_APP_SERVER_URL}/trends/?x=${x}&y=${y}&substance_id=${substanceId}`
      const urlRegions = `${process.env.VUE_APP_SERVER_URL}/trends_regions/?x=${x}&y=${y}&substance_id=${substanceId}`
      store.commit('ADD_LOADING_TREND', { name, loading: true })

      Promise.allSettled([
        fetch(urlRegions)
          .then(r => {
            try {
              return r.json()
            } catch (e) {
              // The request gave a response, but no json body to be parsed
              store.commit('ADD_ERROR_TREND', { name, message: 'Geen regiotrend beschikbaar.' })
            }
          })
          .catch(() => {
            // The request gave an error
            store.commit('ADD_ERROR_TREND', { name, message: 'De regiotrend kan niet worden opgehaald.' })
          }),
        fetch(urlTrends)
          .then(r => {
            try {
              return r.json()
            } catch (e) {
              // The request gave a response, but no json body to be parsed
              store.commit('ADD_ERROR_TREND', { name, message: 'Geen locatietrend beschikbaar.' })
            }
          })
          .catch(() => {
            // The request gave an error
            store.commit('ADD_ERROR_TREND', { name, message: 'De locatietrend kan niet worden opgehaald.' })
          })
      ])
        .then((jsons) => {
          jsons = jsons.map(j => j.value)
          jsons = jsons.filter(j => j)
          if (jsons) {
            store.commit('ADD_TREND', { name, trendData: jsons.flat(), coordinates: [x, y], currentLocation, substanceId })
          }
        })
        .catch(() => {
          // Both requests failed to be retrieved.
          store.commit('ADD_ERROR_TREND', { name, message: 'Zowel de locatie als de regiotrend kunnen niet worden berekend.' })
        })
    },
    saveDisclaimerAcknowledgment (store, value) {
      localStorage.setItem('disclaimerAcknowledged', value)
      store.commit('SET_DISCLAIMER_ACKNOWLEDGED', value)
    },
    loadDisclaimerAcknowledgment (store) {
      const value = localStorage.getItem('disclaimerAcknowledged') === 'true'
      store.commit('SET_DISCLAIMER_ACKNOWLEDGED', value)
    }
  },
  modules: {
  }
})
