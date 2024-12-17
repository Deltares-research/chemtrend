import { createApp } from 'vue'
import App from './App.vue'
import router from './router'
import store from './store'
import vuetify from './plugins/vuetify'
import 'mapbox-gl/dist/mapbox-gl.css'
import { loadFonts } from './plugins/webfontloader'
import VueTour from './plugins/vue-tour'

loadFonts()

const app = createApp(App)

app.use(router)
app.use(store)
app.use(vuetify)
app.use(VueTour)

app.mount('#app')
