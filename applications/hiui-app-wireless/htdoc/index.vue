<template>
	<div class="components-bg pd-30" vertical>
		<n-layout>
			<n-space align="center">
				<div class="circle"></div>
				<div class="font-24-size">{{ $t('Network Status') }}</div>
			</n-space>
		</n-layout>
		<n-divider />

		<n-config-provider :theme-overrides="themeOverrides" class="bg-color bg-border flex-hor-ac">
			<the-wifi-settings :wifi-info="wifiConfig.wifi2g" :title="$t('2.4G WIFI')"></the-wifi-settings>
			<n-divider vertical />
			<the-wifi-settings :wifi-info="wifiConfig.wifi5g" :title="$t('5G WIFI')"></the-wifi-settings>
		</n-config-provider>
	</div>
</template>

<script setup>
import TheWifiSettings from './components/TheWifiSettings.vue';
/**
 * js 文件下使用这个做类型提示
 * @type import('naive-ui').GlobalThemeOverrides
 */
const themeOverrides = {
	Input: {
		heightLarge: '48px'
	},
	Select: {
		peers: {
			InternalSelection: {
				heightMedium: '48px'
			}
		}
	}
};
const {proxy} = getCurrentInstance();
const wifiConfig = reactive({wifi2g: {}, wifi5g: {}});
const test = {
	wifi_2g: {
		band: '2g',
		type: 'mac80211',
		freqlist: [1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13],
		htmodelist: ['HT40', 'HE20', 'HE40', 'HT20'],
		txpwrlist: [
			{dbm: 0, mw: 1},
			{dbm: 1, mw: 1},
			{dbm: 2, mw: 1},
			{dbm: 3, mw: 1},
			{dbm: 4, mw: 2},
			{dbm: 5, mw: 3},
			{dbm: 6, mw: 3},
			{dbm: 7, mw: 5},
			{dbm: 8, mw: 6},
			{dbm: 9, mw: 7},
			{dbm: 10, mw: 10},
			{dbm: 11, mw: 12},
			{dbm: 12, mw: 15},
			{dbm: 13, mw: 19},
			{dbm: 14, mw: 25},
			{dbm: 15, mw: 31},
			{dbm: 16, mw: 39},
			{dbm: 17, mw: 50},
			{dbm: 18, mw: 63},
			{dbm: 19, mw: 79},
			{dbm: 20, mw: 100}
		],
		hwmodelist: ['802.11b', '802.11ax', '802.11g', '802.11n'],
		'.type': 'wifi-device',
		'.index': 0,
		'.name': 'radio0',
		channel: '6',
		cell_density: '0',
		'.anonymous': false,
		htmode: 'HE20',
		interfaces: [
			{'.name': 'default_radio0', '.anonymous': false, ssid: 'wr1800k', encryption: 'sae', device: 'radio0', '.index': 1, key: '88888888', mode: 'ap', '.type': 'wifi-iface', network: 'lan'}
		]
	},
	wifi_5g: {
		band: '5g',
		'.anonymous': false,
		type: 'mac80211',
		country: 'CN',
		freqlist: [36, 40, 44, 48, 52, 56, 60, 64, 149, 153, 157, 161, 165],
		htmodelist: ['HT40', 'VHT40', 'HE20', 'VHT80', 'HE160', 'HE80', 'HE80+80', 'HE40', 'VHT20', 'HT20'],
		txpwrlist: [
			{dbm: 0, mw: 1},
			{dbm: 1, mw: 1},
			{dbm: 2, mw: 1},
			{dbm: 3, mw: 1},
			{dbm: 4, mw: 2},
			{dbm: 5, mw: 3},
			{dbm: 6, mw: 3},
			{dbm: 7, mw: 5},
			{dbm: 8, mw: 6},
			{dbm: 9, mw: 7},
			{dbm: 10, mw: 10},
			{dbm: 11, mw: 12},
			{dbm: 12, mw: 15},
			{dbm: 13, mw: 19},
			{dbm: 14, mw: 25},
			{dbm: 15, mw: 31},
			{dbm: 16, mw: 39},
			{dbm: 17, mw: 50},
			{dbm: 18, mw: 63},
			{dbm: 19, mw: 79},
			{dbm: 20, mw: 100}
		],
		hwmodelist: ['802.11ac', '802.11ax', '802.11n'],
		'.name': 'radio1',
		'.index': 2,
		channel: '48',
		cell_density: '0',
		'.type': 'wifi-device',
		htmode: 'HE40',
		interfaces: [
			{'.name': 'default_radio1', '.anonymous': false, ssid: 'OpenWrt-5g', encryption: 'psk2', device: 'radio1', '.index': 3, key: '88888888', mode: 'ap', network: 'lan2', '.type': 'wifi-iface'}
		]
	}
};
onBeforeMount(() => {
	proxy.$hiui.call('wireless', 'getConfig').then((result) => {
		console.log(result, '1111111111111111');
		if (result) {
			wifiConfig.wifi2g = result.wifi_2g ?? {};
			wifiConfig.wifi5g = result.wifi_5g ?? {};
		}
	});
	proxy.$timer.create(
		'test',
		() => {
			wifiConfig.wifi2g = test.wifi_2g;
			wifiConfig.wifi5g = test.wifi_5g;
		},
		{repeat: false, immediate: false, time: 1000}
	);
});
</script>
<style scoped>
:deep(.n-divider.n-divider--vertical) {
	height: 420px;
	margin: 0 30px;
}
</style>

<i18n src="./locale.json" />
