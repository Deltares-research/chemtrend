import { createStore } from 'vuex'
import _ from 'lodash'

export default createStore({
  state: {
    substances: [],
    trends: [],
    regions: [],
    selectedColor: '#2de0e0'
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
    regions (state) {
      return state.regions
    },
    selectedColor (state) {
      return state.selectedColor
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
          if (t.loading) {
            trend.loading = false
            trend.state = 'open'
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
    SET_TREND_STATE (state, name) {
      state.trends.forEach(t => {
        if (t.name === name) {
          t.state = 'open'
        } else {
          t.state = 'closed'
        }
      })
    },
    REMOVE_TREND (state, name) {
      state.trends = state.trends.filter(t => t.name !== name)
    },
    ADD_LOADING_TREND (state, trend) {
      state.trends.unshift(trend)
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
          store.commit('SET_REGIONS', response)
        })
    },
    addTrend (store, { x, y, substanceId, name, currentLocation }) {
      const existingTrend = store.state.trends.find(t => t.name === name) || []
      if (existingTrend.length > 0) {
        store.commit('SET_TREND_STATE', name)
        if (!existingTrend[0].loading) {
          return
        }
      }
      const urlTrends = `${process.env.VUE_APP_SERVER_URL}/trends/?x=${x}&y=${y}&substance_id=${substanceId}`
      const urlRegions = `${process.env.VUE_APP_SERVER_URL}/trends_regions/?x=${x}&y=${y}&substance_id=${substanceId}`
      store.commit('ADD_LOADING_TREND', { name, loading: true })

      Promise.all([fetch(urlRegions), fetch(urlTrends)])
        .then((responses) => Promise.all(responses.map((r) => r.json())))
        .then((jsons) => {
          store.commit('ADD_TREND', { name, trendData: jsons.flat(), coordinates: [x, y], currentLocation, substanceId})
        })
        .catch(error => {
          console.error('Error fetching trend data:', error)
        })
    }
  },
  modules: {
  }
})
