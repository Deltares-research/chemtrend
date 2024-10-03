import { createStore } from 'vuex'

export default createStore({
  state: {
    substances: [],
    selectedSubstanceId: null,
    trends: [],
    panelIsCollapsed: true
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
    panelIsCollapsed: state => state.panelIsCollapsed

  },
  mutations: {
    SET_SUBSTANCES (state, data) {
      state.substances = data
    },
    SET_SELECTED_SUBSTANCE_ID (state, id) {
      console.log('mutation', id)
      state.selectedSubstanceId = id
    },
    CLEAR_TRENDS (state) {
      state.trends = []
    },
    ADD_TREND (state, trend) {
      state.trends.push(trend)
    },
    TOGGLE_PANEL_COLLAPSE (state) {
      state.panelIsCollapsed = !state.panelIsCollapsed
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
    setSelectedSubstanceId ({ commit }, id) {
      commit('SET_SELECTED_SUBSTANCE_ID', id)
    },
    addTrend (store, { x, y, substanceId }, name) {
      const url = `${process.env.VUE_APP_SERVER_URL}/trends/?x=${x}&y=${y}&substance_id=${substanceId}`

      fetch(url)
        .then(res => res.json())
        .then(response => {
          if (Array.isArray(response) && response.length > 0 && response[0].timeseries) {
            const title = response[0].title
            const subtitle1 = response[0].subtitle_1
            const subtitle2 = response[0].subtitle_2

            const h1Value = response[0].h1_value
            const h1Label = response[0].h1_label
            const h2Value = response[0].h2_value
            const h2Label = response[0].h2_label

            console.log(h1Value, h1Label, h2Value, h2Label)

            const timeseries = response[0].timeseries

            const xAxisData = timeseries.map(item => item.x_value)
            const yValueLowess = timeseries.map(item => item.y_value_lowess)
            const yValueMeting = timeseries.map(item => item.y_value_meting)
            const yValueTheilSen = timeseries.map(item => item.y_value_theil_sen)

            const trend = {
              name: name,
              option: {
                title: {
                  text: title,
                  subtext: subtitle1 + '\n' + subtitle2,
                  left: 'center',
                  top: 10,
                  textStyle: {
                    fontSize: 25
                  },
                  subtextStyle: {
                    fontSize: 15
                  }
                },
                grid: {
                  top: 100,
                  bottom: 50,
                  right: 50,
                  left: 50
                },
                tooltip: {
                  show: true
                },
                legend: {
                  show: true,
                  bottom: 5,
                  lineStyle: {
                    symbol: 'none'
                  },
                  itemWidth: 70
                },
                xAxis: {
                  type: 'category',
                  data: xAxisData
                },
                yAxis: {
                  type: 'value'
                },
                series: [
                  {
                    name: 'Meting',
                    type: 'line',
                    data: yValueMeting,
                    lineStyle: {
                      color: '#000000'
                    },
                    symbol: 'circle',
                    symbolSize: 8,
                    showAllSymbol: true,
                    itemStyle: {
                      color: '#f8766d',
                      borderColor: '#000000',
                      borderWidth: 1
                    },
                    markLine: {
                      data: [
                        {
                          yAxis: h1Value,
                          name: h1Label,
                          label: {
                            show: true,
                            position: 'insideStart',
                            formatter: function (params) {
                              return params.data.name
                            }
                          }
                        },
                        {
                          yAxis: h2Value,
                          name: h2Label,
                          label: {
                            show: true,
                            position: 'insideEnd',
                            formatter: function (params) {
                              return params.data.name
                            }
                          }
                        }
                      ],
                      emphasis: {
                        disabled: true
                      },
                      lineStyle: {
                        color: '#373737'
                      },
                      symbol: ['none', 'none'],
                      tooltip: {
                        show: true,
                        formatter: function (params) {
                          return params.data.name + '  ' + params.data.yAxis
                        }
                      }
                    }
                  },
                  {
                    name: 'Lowess',
                    type: 'line',
                    data: yValueLowess,
                    lineStyle: {
                      color: '#0000ff'
                    },
                    symbol: 'none',
                    symbolSize: 0,
                    showSymbol: false
                  },
                  {
                    name: 'Theil Sen',
                    type: 'line',
                    data: yValueTheilSen,
                    lineStyle: {
                      color: '#FFA500',
                      type: 'dashed'
                    },
                    symbol: 'none',
                    symbolSize: 0,
                    showSymbol: false,
                    itemStyle: {
                      color: '#FFA500'
                    }
                  }
                ]
              }
            }

            store.commit('CLEAR_TRENDS')
            store.commit('ADD_TREND', trend)
          } else {
            console.error('Invalid response structure:', response)
          }
        })
        .catch(error => {
          console.error('Error fetching trend data:', error)
        })
    },
    togglePanelCollapse ({ commit }) {
      commit('TOGGLE_PANEL_COLLAPSE')
    }
  },
  modules: {
  }
})
