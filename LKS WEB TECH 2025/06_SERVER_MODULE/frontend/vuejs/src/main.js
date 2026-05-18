import { createApp } from 'vue'
import App from './App.vue'
import router from './router/index'
import './css/bootstrap.css'
import './css/custom.css'

createApp(App).use(router).mount('#app')
