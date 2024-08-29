import { createRouter, createWebHistory } from 'vue-router'
import TrendView from '@/views/TrendView'

const routes = [
  {
    path: '/trends',
    name: 'trends',
    component: TrendView
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
