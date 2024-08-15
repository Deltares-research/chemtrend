import { createStore } from 'vuex'

export default createStore({
  state: {
    substances: [{
      substance_id: '',
      substance_description: ''
    }],
    trends: []
  },
  getters: {
    substances (state) {
      return state.substances
    },
    trends (state) {
      return state.trends
    }
  },
  mutations: {
    SET_SUBSTANCES (state, data) {
      state.substances = data
    },
    CLEAR_TRENDS (state) {
      state.trends = []
    },
    ADD_TREND (state, trend) {
      console.log('hoi', state)
      state.trends.push(trend)
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
    addTrend (store, featureId, name) {
      // TODO: Make an endpoint for this
      // const url = `${process.env.VUE_APP_SERVER_URL}/trend/${featureId}`
      // fetch(url)
      //   .then(res => {
      //     return res.json()
      //   })
      //   .then(response => {
      //     store.commit('ADD_TREND', response)
      //   })
      // TODO: VERY DUMMY THIS DATA
      store.commit('ADD_TREND', {
        name: name,
        option: {
          xAxis: {},
          yAxis: {},
          series: [
            {
              symbolSize: 20,
              data: [
                [10.0, 8.04],
                [8.07, 6.95],
                [13.0, 7.58],
                [9.05, 8.81],
                [11.0, 8.33],
                [14.0, 7.66],
                [13.4, 6.81],
                [10.0, 6.33],
                [14.0, 8.96],
                [12.5, 6.82],
                [9.15, 7.2],
                [11.5, 7.2],
                [3.03, 4.23],
                [12.2, 7.83],
                [2.02, 4.47],
                [1.05, 3.33],
                [4.05, 4.96],
                [6.03, 7.24],
                [12.0, 6.26],
                [12.0, 8.84],
                [7.08, 5.82],
                [5.02, 5.68]
              ],
              type: 'scatter'
            }
          ]
        }
      })
    }
  },
  modules: {
  }
})
