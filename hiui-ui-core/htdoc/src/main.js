import {createApp} from 'vue';
import VueAxios from 'vue-axios';
import axios from 'axios';
import App from './App.vue';
import router from './router';
import timers from './timers';
import i18n from './i18n';
import hiui from './hiui';
import NaiveUI from './naive-ui';
import basic from './css/basic.css';

const app = createApp(App);

app.use(VueAxios, axios);
app.use(router);
app.use(i18n);
app.use(hiui);
app.use(timers);
app.use(NaiveUI);

app.mount('#app');
