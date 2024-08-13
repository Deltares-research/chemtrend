import { createStore } from 'vuex'

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
    setLocations (state, locations) {
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
    }
  },
  modules: {
  }
})
