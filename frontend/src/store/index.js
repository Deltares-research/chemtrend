import { createStore } from 'vuex'
import _ from 'lodash'

export default createStore({
  state: {
    substances: [],
    trends: [],
    regions: []
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
      state.trends.unshift(trend)
    },
    SET_SELECTED_COORDINATES (state, coords) {
      state.selectedCoordinates = coords
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
    addTrend (store, { x, y, substanceId, name }) {
      const urlTrends = `${process.env.VUE_APP_SERVER_URL}/trends/?x=${x}&y=${y}&substance_id=${substanceId}`
      substanceId = 517
      x = 5.019
      y = 52.325
      const urlRegions = `${process.env.VUE_APP_SERVER_URL}/trends_regions/?x=${x}&y=${y}&substance_id=${substanceId}`

      Promise.all([fetch(urlRegions), fetch(urlTrends)])
        .then((responses) => Promise.all(responses.map((r) => r.json())))
        .then((jsons) => {
          console.log(jsons.flat())
          store.commit('ADD_TREND', { name, trendData: jsons.flat(), coordinates: [x, y] })
        })
        .catch(error => {
          console.error('Error fetching trend data:', error)
        })
    }
  },
  modules: {
  }
})
