import {defineConfig, loadEnv} from 'vite';
import vue from '@vitejs/plugin-vue';
import viteCompression from 'vite-plugin-compression';
import vueI18n from '@intlify/vite-plugin-vue-i18n';
import path from 'path';
import AutoImport from 'unplugin-auto-import/vite';

const env = loadEnv('', process.cwd());

export default defineConfig({
	resolve: {
		preserveSymlinks: true,
		alias: {
			'@': path.resolve(__dirname, '')
		}
	},
	plugins: [
		vue(),
		viteCompression({
			deleteOriginFile: true
		}),
		vueI18n({
			compositionOnly: false
		}),
		AutoImport({
			include: [
				/\.[tj]sx?$/, // .ts, .tsx, .js, .jsx
				/\.vue$/,
				/\.vue\?vue/, // .vue
				/\.md$/ // .md
			],
			dts: true,
			imports: ['vue']
		})
	],
	build: {
		cssCodeSplit: true,
		lib: {
			formats: ['umd'],
			entry: 'index.vue',
			name: 'hiui-com-' + env.VITE_APP_NAME,
			fileName: env.VITE_APP_NAME
		},
		rollupOptions: {
			external: ['vue'],
			output: {
				globals: {
					vue: 'Vue'
				}
			}
		}
	}
});
