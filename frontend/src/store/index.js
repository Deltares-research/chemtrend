import { createStore } from 'vuex'

const test_locations = {
  "type": "FeatureCollection",
  "features": [
    {
      "type": "Feature",
      "properties": {},
      "geometry": {
        "coordinates": [
          5.145777368152608,
          52.05497715243345
        ],
        "type": "Point"
      }
    },
    {
      "type": "Feature",
      "properties": {},
      "geometry": {
        "coordinates": [
          5.210791458255784,
          51.922306228142446
        ],
        "type": "Point"
      }
    },
    {
      "type": "Feature",
      "properties": {},
      "geometry": {
        "coordinates": [
          5.055267556439617,
          52.00478114570629
        ],
        "type": "Point"
      }
    },
    {
      "type": "Feature",
      "properties": {},
      "geometry": {
        "coordinates": [
          5.343369174823067,
          52.010273981845444
        ],
        "type": "Point"
      }
    }
  ]
}
export default createStore({
  state: {
    locations: []
  },
  getters: {
    locations (state) {
      return state.locations
    }
  },
  mutations: {
    setLocations(state, locations) {
      state.locations = locations
    }
  },
  actions: {
    loadLocations (store) {
      // const url = `${process.env.VUE_APP_SERVER_URL}/locations/`
      // fetch(url)
      //   .then(res => {
      //     return res.json()
      //   })
      //   .then(response => {
      //     store.commit('setLocations', response)
      //   })
      store.commit('setLocations', test_locations)
    }
  },
  modules: {
  }
})
