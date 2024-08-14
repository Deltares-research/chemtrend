import { createStore } from 'vuex'

export default createStore({
  state: {
    substances: [{
      substance_id: '',
      substance_description: ''
    }]
  },
  getters: {
    substances (state) {
      return state.substances
    }
  },
  mutations: {
    SET_SUBSTANCES (state, data) {
      state.substances = data
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
          console.log(response)
          store.commit('SET_SUBSTANCES', response)
        })
    }
  },
  modules: {
  }
})
