<template>
	<div class="the-menu">
		<n-space vertical>
			<div class="menu-item" v-for="(item, index) in menus" :key="index" :class="selectIndex == index ? 'active' : ''" @click="menuClick(index, item.path)">
				<div>
					<n-icon v-if="item.svg" :size="48">
						<svg :xmlns="item['svg']['-xmlns']" :viewBox="item['svg']['-viewBox']">
							<path :d="item['svg']['path']['-d']" />
						</svg>
					</n-icon>
				</div>
				<div>{{ $t('menus.' + item.title) }}</div>
			</div>
		</n-space>
		<div class="more">
			<n-dropdown :options="userOptions" placement="right-end" :render-label="renderDropdownLabel">
				<n-button text>
					<img src="../../../../assets/more.svg" />
				</n-button>
			</n-dropdown>
		</div>
	</div>
</template>

<script setup>
//import { useI18n } from 'vue-i18n'
//const { t } = useI18n()
import {ContentDeliveryNetwork} from '@vicons/carbon';
import {
	PersonCircleOutline as UserIcon,
	LogOutOutline as LogoutIcon,
	PowerSharp as PowerSharpIcon,
	ChevronForward as ChevronForwardIcon,
	Moon as MoonIcon,
	SunnySharp as SunnySharpIcon
} from '@vicons/ionicons5';
defineProps({
	menus: Object
});

const router = useRouter();
const {proxy} = getCurrentInstance();
const localeOptions = () => {
	const titles = {
		'en-US': 'English',
		'ja-JP': '日本語',
		'zh-CN': '简体中文',
		'zh-TW': '繁體中文'
	};

	const options = proxy.$i18n.availableLocales.map((locale) => {
		return {
			label: titles[locale] ?? locale,
			key: locale
		};
	});

	options.unshift({
		label: proxy.$t('Auto'),
		key: 'auto'
	});
	return options;
};

const userOptions = reactive([
	{
		label: '语言',
		key: 'others2',
		children: []
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

const selectIndex = ref(-1);

function renderIcon(icon) {
	return () => h(resolveComponent('n-icon'), () => h(icon));
}

function handleUserAction(key) {
	if (key === 'logout') {
		proxy.$hiui.logout();
		proxy.$router.push('/login');
	} else if (key === 'reboot') {
		proxy.$dialog.warning({
			title: proxy.$t('Reboot'),
			content: proxy.$t('RebootConfirm'),
			positiveText: proxy.$t('OK'),
			onPositiveClick: () => {
				proxy.$hiui.ubus('system', 'reboot').then(() => {
					proxy.modalSpin = true;
					proxy.$hiui.reconnect().then(() => {
						proxy.modalSpin = false;
						proxy.$router.push('/login');
					});
				});
			}
		});
	}
}

function menuClick(index, path) {
	console.log(index, path);
	router.push(path);
	this.selectIndex = index;
}

function renderDropdownLabel(option) {
	option.label = proxy.$t(option.label);
	if ('children' in option && option.children.length === 0) {
		option.children = localeOptions();
	}
	return option.label;
}

onMounted(() => {
	console.log(proxy.$t('Logout'));
});
</script>
<style scoped lang="less">
.the-menu {
	display: flex;
	flex-direction: column;
	align-items: center;
}
.menu-item {
	display: flex;
	flex-wrap: nowrap;
	align-items: center;
	justify-content: center;
	flex-direction: column;
	left: 14px;
	top: 130px;
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
}
.more {
	position: absolute;
	bottom: 30px;
	width: 48px;
	height: 48px;
}
</style>
<i18n src="../locale.json" />
