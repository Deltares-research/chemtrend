import { createApp } from 'vue'
import App from './App.vue'
import router from './router'
import store from './store'
import vuetify from './plugins/vuetify'
import 'mapbox-gl/dist/mapbox-gl.css'
import { loadFonts } from './plugins/webfontloader'
import Vue3Tour from 'vue3-tour'
import 'vue3-tour/dist/vue3-tour.css'

loadFonts()

createApp(App)
  .use(router)
  .use(store)
  .use(vuetify)
  .use(Vue3Tour)
  .mount('#app')
