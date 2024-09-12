import { createStore } from 'vuex'

export default createStore({
  state: {
    substances: [{
      substance_id: '',
      substance_description: '',
      selectedCoordinates: [],
    }],
    trends: [],
    panelIsCollapsed: true
  },
  getters: {
    substances (state) {
      return state.substances
    },
    trends (state) {
      return state.trends
    },
    panelIsCollapsed: state => state.panelIsCollapsed
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
    },
    TOGGLE_PANEL_COLLAPSE (state) {
      state.panelIsCollapsed = !state.panelIsCollapsed
    },
    SET_SELECTED_COORDINATES (state, coords) {
      state.selectedCoordinates = coords
    },
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
    addTrend (store, { x, y, featureId }, name) {
      // TODO: Make an endpoint for this
      const url = `${process.env.VUE_APP_SERVER_URL}/trend/${x}/${y}/${featureId}`
      fetch(url)
        .then(res => {
          return res.json()
        })
        .then(response => {
          store.commit('ADD_TREND', response)
        })
      // TODO: VERY DUMMY THIS DATA
      store.commit('ADD_TREND', {
        name: name,
        option: {
          xAxis: {
            type: 'category',
            data: ['2000', '2001', '2002', '2003', '2004', '2005', '2006']
          },
          yAxis: {
            type: 'value'
          },
          series: [
            {
              name: 'Measurements',
              type: 'line',
              data: [
                10.0, 8, 8.07, 6.95, 13.0, 7.58, 9.05
              ],
              lineStyle: {
                color: '#000000'
              },
              symbol: 'circle',
              symbolSize: 10,
              itemStyle: {
                color: '#f8766d',
                borderColor: '#000000',
                borderWidth: 1
              }
            },
            {
              name: 'Trend',
              type: 'line',
              data: [
                8.5, 8.2, 8.25, 9, 8.75, 8, 8.5
              ],
              lineStyle: {
                color: '#0000ff'
              },
              showSymbol: false
            },
            {
              name: 'Something',
              type: 'line',
              data: [
                8.4, 8.3, 8.5, 8.8, 8.9, 8, 8.65
              ],
              lineStyle: {
                color: '#FFA500',
                type: 'dashed'
              },
              showSymbol: false
            }
          ]
        }
      })
    },
    togglePanelCollapse ({ commit }) {
      commit('TOGGLE_PANEL_COLLAPSE')
    }
  },
  modules: {
  }
})
