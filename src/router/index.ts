import { createRouter, createWebHistory } from 'vue-router'

const router = createRouter({
  history: createWebHistory(import.meta.env.BASE_URL),
  routes: [
    {
      path: '/',
      name: 'home',
      component: () => import('../views/HomePage.vue'),
    },
    {
      path: '/login',
      name: 'login',
      component: () => import('../views/LoginView.vue'),
    },
    {
      path: '/register/:lrn?',
      name: 'register',
      component: () => import('../views/RegisView.vue'),
      props: true,
    },
    {
      path: '/assessment/:lrn',
      name: 'assessment',
      component: () => import('../views/AssessmentView.vue'),
      props: true,
    },
  ],
})

export default router
