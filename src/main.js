import Vue from 'vue'

import App from './App.vue'
import router from './router'
import axios from 'axios'

import Vuesax from 'vuesax'
import 'vuesax/dist/vuesax.css'
import 'material-icons/iconfont/material-icons.css';
import { store, mutations } from './store';


import { BootstrapVue, BootstrapVueIcons } from 'bootstrap-vue'
import 'bootstrap/dist/css/bootstrap.css'
import 'bootstrap-vue/dist/bootstrap-vue.css'

import './assets/main.css'

Vue.use(BootstrapVue)
Vue.use(BootstrapVueIcons)
Vue.use(Vuesax)


async function initApp() {
  try {
    const configResponse = await axios.get(`/config.json?timestamp=${new Date().getTime()}`);
    mutations.setAppConfig(configResponse.data);

    new Vue({
      router,
      render: h => h(App),
    }).$mount('#app');

  } catch (error) {
    console.error('Failed to load app configuration:', error);
  }
}

initApp().then(r => console.log("Application Loaded"));
