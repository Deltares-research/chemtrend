import { createRouter, createWebHistory } from 'vue-router'
import TrendView from '@/views/TrendView'

const routes = [
  {
    path: '/trends',
    name: 'trends',
    component: TrendView
  }
]

const router = createRouter({
  history: createWebHistory(process.env.BASE_URL),
  routes
})

export default router
