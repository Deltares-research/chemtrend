import { createStore } from 'vuex'

export default createStore({
  state: {
    substances: ['Substance A', 'Substance B', 'Substance C', 'Substance D', 'Substance E', 'Substance F']
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
    setSubstances ({ commit }, substances) {
      commit('SET_SUBSTANCES', substances)
    }
    // loadSubstances (store) {
    // const url = `${process.env.VUE_APP_SERVER_URL}/substances/`
    // fetch(url)
    //   .then(res => {
    //     return res.json()
    //   })
    //   .then(response => {
    //     store.commit('setSubstances', response)
    //   })
    // }
  },
  modules: {
  }
})
