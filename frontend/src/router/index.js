import { createRouter, createWebHistory } from 'vue-router'
import TrendView from '@/views/TrendView'
import Disclaimer from '@/components/Disclaimer.vue'

const routes = [
  {
    path: '/trends',
    name: 'trends',
    component: TrendView
  },
  {
    path: '/terms-of-use',
    name: 'disclaimer',
    component: Disclaimer
  },
  // TODO: restructure the routing, create a default home view
  {
    path: '/',
    redirect: { name: 'trends' }
  }
]

const router = createRouter({
  history: createWebHistory(process.env.BASE_URL),
  routes
})

export default router
