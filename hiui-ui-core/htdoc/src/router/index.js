import {createRouter, createWebHashHistory} from 'vue-router';
import addRoutesDev from './development.js';
import hiui from '../hiui';

function loadView(name) {
	return new Promise((resolve, reject) => {
		const script = document.createElement('script');
		script.setAttribute('src', `/views/${name}.umd.js?_t=${new Date().getTime()}`);
		document.head.appendChild(script);

		script.addEventListener('load', () => {
			document.head.removeChild(script);
			resolve(window['hiui-com-' + name]);
		});

		script.addEventListener('error', () => {
			document.head.removeChild(script), reject();
		});
	});
}

const loginView = import.meta.env.VITE_HIUI_LOGIN_VIEW || 'login';
const layoutView = import.meta.env.VITE_HIUI_LAYOUT_VIEW || 'layout';
const homeView = import.meta.env.VITE_HIUI_HOME_VIEW || 'home';

const routes = [];

if (import.meta.env.MODE === 'development') {
	// eslint-disable-next-line no-undef
	const menus = hiui.parseMenus(__MENUS__);
	addRoutesDev(routes, menus, loginView, layoutView, homeView);
} else {
	routes.push({
		path: '/login',
		name: 'login',
		component: () => loadView(loginView)
	});

	routes.push({
		path: '/',
		name: '/',
		component: () => loadView(layoutView),
		props: () => ({menus: hiui.menus}),
		children: [
			{
				path: '/network',
				name: 'network',
				component: () => loadView(homeView)
			},
			{
				path: '/:pathMatch(.*)*',
				name: 'NotFound',
				component: () => import('../components/NotFound.vue')
			}
		]
	});
}

function addRoutes(menu) {
	if (menu.view && menu.path !== '/')
		router.addRoute('/', {
			path: menu.path,
			name: Symbol(),
			component: () => loadView(menu.view),
			meta: {menu: menu}
		});
	if (menu.children) menu.children.forEach((m) => addRoutes(m));
}

const router = createRouter({
	history: createWebHashHistory(),
	routes
});

router.beforeEach(async (to) => {
	await hiui.init();

	if (to.path === '/login') return;

	const authenticated = await hiui.isAuthenticated();
	if (!authenticated) return '/login';

	await hiui.initWithAuthed();

	if (import.meta.env.MODE === 'development') return;

	if (!hiui.menus) {
		router.getRoutes().forEach((r) => {
			const name = r.name;
			if (typeof name === 'string') return;
			router.removeRoute(name);
		});
		const menus = await hiui.loadMenus();
		menus.forEach((m) => addRoutes(m));
		return to.fullPath;
	}
});

router.afterEach((to) => {
	if (to.path === '/') router.push('/network');
});

export default router;
