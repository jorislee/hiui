<template>
	<n-config-provider :theme="undefined" :theme-overrides="themeOverrides">
		<n-layout has-sider position="absolute">
			<n-layout-sider content-style="padding: 14px;" bordered :native-scrollbar="false" collapsed :collapsed-width="124" collapse-mode="width">
				<div class="logo-name">
					<router-link to="/home">
						<img src="@/assets/logo.svg" style="width: 64px" />
					</router-link>
				</div>
				<n-dialog-provider>
					<the-menu :menus="menus"></the-menu>
				</n-dialog-provider>
			</n-layout-sider>
			<n-layout>
				<n-layout-header bordered style="padding: 4px">
					<n-space justify="end" size="large">
						<n-tooltip placement="bottom">
							<template #trigger>
								<n-switch v-model:value="darkTheme" :rail-style="() => 'background-color: #000e1c'">
									<template #checked>
										<n-icon size="14" color="#ffd93b"><sunny-sharp-icon /></n-icon>
									</template>
									<template #unchecked>
										<n-icon size="14" color="#ffd93b"><moon-icon /></n-icon>
									</template>
								</n-switch>
							</template>
							<span>{{ $t((darkTheme ? 'Dark' : 'Light') + ' theme') }}</span>
						</n-tooltip>
					</n-space>
				</n-layout-header>

				<n-layout-content embedded content-style="padding: 30px;" :native-scrollbar="false">
					<router-view>
						<template #default="{Component}">
							<transition name="zoom-fade" mode="out-in">
								<div :key="$route.path" style="display: flex; justify-content: center">
									<n-message-provider>
										<n-dialog-provider>
											<component :is="Component" />
										</n-dialog-provider>
									</n-message-provider>
								</div>
							</transition>
						</template>
					</router-view>
					<n-back-top />
				</n-layout-content>

				<n-layout-footer position="absolute" bordered style="padding: 4px">
					<div class="copyright">
						<n-text type="info">{{ $t('© 2021 SpeedBox版权所有') }}</n-text>
						<n-divider vertical />
						<n-text type="info">S/N: 1123123123123213213</n-text>
						<n-divider vertical />
						<n-text type="info">version: 2.0.0-14</n-text>
					</div>
				</n-layout-footer>
			</n-layout>
		</n-layout>
	</n-config-provider>
</template>

<script setup>
import {Moon as MoonIcon, SunnySharp as SunnySharpIcon} from '@vicons/ionicons5';
import TheMenu from './components/TheMenu.vue';
const proxy = getCurrentInstance().appContext.config.globalProperties;
/**
 * js 文件下使用这个做类型提示
 * @type import('naive-ui').GlobalThemeOverrides
 */
const themeOverrides = {
	common: {
		bodyColor: '#f3f5f8'
	},
	Dialog: {
		borderRadius: '8px'
	},
	Button: {
		colorInfo: '#0052D9',
		textColorHover: '#0052D9',
		textColorFocus: '#0052D9',
		borderHover: '1px solid #0052D9',
		borderFocus: '1px solid #0052D9'
	},
	Checkbox: {
		colorChecked: '#0052D9'
	},
	Layout: {
		color: '#f3f5f8',
		colorEmbedded: '#f3f5f8',
		footerColor: '#f3f5f8'
	},
	Input: {
		heightMedium: '48px',
		borderHover: '1px solid #0052D9',
		borderFocus: '1px solid #0052D9'
	},
	Select: {
		peers: {
			InternalSelection: {
				heightMedium: '48px',
				borderHover: '1px solid #0052D9',
				borderFocus: '1px solid #0052D9',
				borderActive: '1px solid #0052D9'
			}
		}
	},
	Switch: {
		railColorActive: '#0052D9',
		loadingColor: '#0052D9'
	},
	Radio: {
		buttonTextColorHover: '#0052D9',
		buttonTextColorActive: '#FFFFFF',
		buttonBorderColorActive: '#0052D9',
		dotColorActive: '#0052D9',
		buttonBoxShadowFocus: 'inset 0 0 0 1px #0052D9',
		buttonColorActive: '#0052D9'
	},
	Modal: {
		boxShadow: 'none'
	}
};
defineProps({
	menus: Array
});
let darkTheme = computed({
	get() {
		return proxy.$hiui.state.theme === 'dark';
	},
	set(val) {
		proxy.$hiui.setTheme(val ? 'dark' : 'light');
	}
});
</script>

<style scoped>
.logo-name {
	line-height: 50px;
	text-align: center;
	font-size: 2em;
}

.logo-name a {
	text-decoration: none;
}

.copyright {
	text-align: right;
	font-size: medium;
	padding-right: 40px;
	display: flex;
	justify-content: center;
}

.copyright .n-a {
	font-size: 1.2em;
}

.zoom-fade-enter-active,
.zoom-fade-leave-active {
	transition: transform 0.35s, opacity 0.28s ease-in-out;
}

.zoom-fade-enter-from {
	opacity: 0;
	transform: scale(0.97);
}

.zoom-fade-leave-to {
	opacity: 0;
	transform: scale(1.03);
}
</style>

<i18n src="./locale.json" />
