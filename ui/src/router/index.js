import Vue from 'vue'
import VueRouter from 'vue-router'

Vue.use(VueRouter)

const routes = [{
  path: '/',
  name: 'home',
  component: () =>
    import('@/views/HomeView.vue')
},
{
  path: '/how-to-play',
  name: 'how-to-play',
  component: () =>
    import('@/views/DescriptionPage.vue')
},

]

const router = new VueRouter({
  routes
})

// error handler
const onError = (e) => {
  // avoid NavigationDuplicated
  if (e.name !== 'NavigationDuplicated') throw e
}

// keep original function
const _push = router.__proto__.push
// then override it
router.__proto__.push = function push(...args) {
  try {
    const op = _push.call(this, ...args)
    if (op instanceof Promise) op.catch(onError)
    return op
  } catch (e) {
    onError(e)
  }
}

export default router