<template>
	<div class="the-menu">
		<n-space vertical>
			<div class="menu-item" v-for="(item, index) in menus" :key="index" :class="selectIndex == index ? 'active' : ''" @click="menuClick(index, item.path)">
				<div>
					<n-icon v-if="item.svg" :size="48">
						<IconSvg :opt="item.svg" />
					</n-icon>
				</div>
				<div>{{ $t('menus.' + item.title) }}</div>
			</div>
		</n-space>
		<div class="more">
			<n-dropdown :options="moreOptions" placement="right-end" @select="handleSelect" :render-label="renderDropdownLabel">
				<n-button text>
					<img src="@/assets/more.svg" />
				</n-button>
			</n-dropdown>
		</div>
	</div>
	<n-modal v-model:show="modalSpin" :close-on-esc="false" :mask-closable="false">
		<n-spin size="large">
			<template #description>
				<n-el style="color: var(--primary-color)">{{ $t('Rebooting') }}...</n-el>
			</template>
		</n-spin>
	</n-modal>
</template>

<script setup>
import {getCurrentInstance} from 'vue';
import {ContentDeliveryNetwork} from '@vicons/carbon';
import {IconSvg} from './IconSvg.ts';
import {PersonCircleOutline as UserIcon, LogOutOutline as LogoutIcon, PowerSharp as PowerSharpIcon, ChevronForward as ChevronForwardIcon} from '@vicons/ionicons5';

defineProps({
	menus: Object
});

const {proxy} = getCurrentInstance();

const titles = {
	'en-US': 'English',
	'ja-JP': '日本語',
	'zh-CN': '简体中文',
	'zh-TW': '繁體中文'
};
const localeOptions = () => {
	let isAuto = true;
	const options = proxy.$i18n.availableLocales.map((locale) => {
		let tmp = {
			label: titles[locale] ?? locale,
			key: locale
		};
		if (locale === proxy.$hiui.state.locale) {
			isAuto = false;
			tmp.icon = renderIcon(ChevronForwardIcon);
		}
		return tmp;
	});

	options.unshift({
		label: proxy.$t('Auto'),
		key: 'auto',
		icon: isAuto ? renderIcon(ChevronForwardIcon) : null
	});

	return options;
};

const moreOptions = reactive([
	{
		label: 'Auto',
		key: 'language',
		children: [],
		icon: renderIcon(ContentDeliveryNetwork)
	},
	{
		key: 'logout',
		label: 'Logout',
		icon: renderIcon(LogoutIcon)
	},
	{
		key: 'reboot',
		label: 'Reboot',
		icon: renderIcon(PowerSharpIcon)
	}
]);
const modalSpin = ref(false);
const selectIndex = ref(-1);
const dialog = proxy.$dialog;
function renderDropdownLabel(option) {
	option.label = proxy.$t(option.label);
	if ('children' in option && option.children.length === 0) {
		option.label = titles[proxy.$hiui.state.locale] ?? proxy.$t('Auto');
		option.children = localeOptions();
	}
	return option.label;
}

function renderIcon(icon) {
	return () => h(resolveComponent('n-icon'), () => h(icon));
}
function handleSelect(key) {
	if (key === 'logout') {
		proxy.$hiui.logout();
		proxy.$router.push('/login');
	} else if (key === 'reboot') {
		dialog.warning({
			title: proxy.$t('Reboot'),
			content: proxy.$t('RebootConfirm'),
			positiveText: proxy.$t('OK'),
			onPositiveClick: () => {
				proxy.$hiui.ubus('system', 'reboot').then(() => {
					modalSpin.value = true;
					proxy.$hiui.reconnect().then(() => {
						modalSpin.value = false;
						proxy.$router.push('/login');
					});
				});
			}
		});
	} else {
		proxy.$hiui.setLocale(key);
		moreOptions[0].label = titles[key] ?? proxy.$t('Auto');
		moreOptions[0].children.forEach((element) => {
			if (element.key === key) {
				element.icon = renderIcon(ChevronForwardIcon);
			} else {
				element.icon = null;
			}
		});
	}
}

function menuClick(index, path) {
	selectIndex.value = index;
	proxy.$router.push(path);
}
</script>
<style scoped>
.the-menu {
	display: flex;
	flex-direction: column;
	align-items: center;
	color: white;
}
.menu-item {
	display: flex;
	flex-wrap: nowrap;
	align-items: center;
	justify-content: center;
	flex-direction: column;
	width: 96px;
	height: 96px;
	transition: background-color 3s;
	-webkit-transition: background-color 3s;
}

.menu-item:hover {
	border-radius: 8px;
	background: linear-gradient(174deg, rgba(231, 232, 239, 0.15) 4%, rgba(198, 202, 222, 0.359) 95%);
	box-shadow: -4px -4px 10px 0px rgba(54, 62, 77, 0.5), 4px 4px 10px 0px rgba(18, 21, 26, 0.6), inset 0px 2px 10px 0px rgba(36, 41, 51, 0.5);
}
.menu-item.active {
	border-radius: 8px;
	background: linear-gradient(174deg, rgba(231, 232, 239, 0.15) 4%, rgba(198, 202, 222, 0.359) 95%);
	box-shadow: -4px -4px 10px 0px rgba(54, 62, 77, 0.5), 4px 4px 10px 0px rgba(18, 21, 26, 0.6), inset 0px 2px 10px 0px rgba(36, 41, 51, 0.5);
	--icon-active-color: var(--n-toggle-button-color);
}
.more {
	position: absolute;
	bottom: 30px;
	width: 48px;
	height: 48px;
}
</style>
<i18n src="../locale.json" />
