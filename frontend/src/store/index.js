import { createStore } from 'vuex'

export default createStore({
  state: {
    substances: [],
    selectedSubstanceId: null,
    trends: [],
    regions: []
  },
  getters: {
    substances (state) {
      return state.substances
    },
    selectedSubstanceId (state) {
      return state.selectedSubstanceId
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
    SET_SELECTED_SUBSTANCE_ID (state, id) {
      console.log('mutation', id)
      state.selectedSubstanceId = id
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
    setSelectedSubstanceId ({ commit }, id) {
      commit('SET_SELECTED_SUBSTANCE_ID', id)
    },
    addTrend (store, { x, y, substanceId }, name) {
      const url = `${process.env.VUE_APP_SERVER_URL}/trends/?x=${x}&y=${y}&substance_id=${substanceId}`

      fetch(url)
        .then(res => res.json())
        .then(response => {
          if (Array.isArray(response) && response.length > 0 && response[0].timeseries) {
            const trendData = response[0]
            store.commit('ADD_TREND', { name, trendData })
            console.log('trends', this.state.trends)
          } else {
            console.error('Invalid response structure:', response)
          }
        })
        .catch(error => {
          console.error('Error fetching trend data:', error)
        })
    }
  },
  modules: {
  }
})
