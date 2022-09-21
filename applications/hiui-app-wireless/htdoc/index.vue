<template>
	<div class="components-bg pd-30" vertical>
		<n-layout>
			<n-space align="center">
				<div class="circle"></div>
				<div class="font-24-size">{{ $t('Wireless') }}</div>
			</n-space>
		</n-layout>
		<n-divider />

		<n-config-provider :theme-overrides="themeOverrides" class="bg-color bg-border flex-hor-ac">
			<the-wifi-settings :wifi-info="wifiConfig.wifi2g" :title="$t('2.4G WIFI')"></the-wifi-settings>
			<n-divider vertical v-if="wifiConfig.wifi5g" />
			<the-wifi-settings v-if="wifiConfig.wifi5g" :wifi-info="wifiConfig.wifi5g" :title="$t('5G WIFI')"></the-wifi-settings>
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
		heightMedium: '48px'
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
onBeforeMount(() => {
	proxy.$hiui.call('wireless', 'getConfig').then((result) => {
		result = {
			wifi_2g: {
				repeater_connected: false,
				device: 'radio1',
				txpower: '20',
				band: '2G',
				channel: '11',
				type: '2.4G',
				hwmodelist: ['802.11b/g/n', '802.11g', '802.11b'],
				htmode: '20/40 MHz',
				hwmode: '802.11b/g/n',
				htmodelist: ['20 MHz', '40 MHz', '20/40 MHz'],
				txpower_max: '20',
				channels: ['1', '2', '3', '4', '5', '6', '7', '8', '9', '10', '11', 'auto'],
				encryptions: ['none', 'psk2', 'psk-mixed', 'sae', 'sae-mixed'],
				interfaces: [
					{
						id: 1,
						ssid: 'GL-AR750S-29a',
						encrypt: 'psk2',
						key: 'goodlife',
						guest: '0',
						ifname: 'wlan1',
						mode: 'ap',
						network: 'lan',
						up: false,
						hidden: true,
						maxsta: '0'
					},
					{
						id: 3,
						ssid: 'GL-AR750S-29a-Guest',
						encrypt: 'psk2',
						key: 'goodlife',
						guest: '1',
						ifname: 'wlan3',
						mode: 'ap',
						network: 'guest',
						up: false,
						hidden: true,
						maxsta: '0'
					}
				]
			},
			code: 0
		};
		if (result) {
			wifiConfig.wifi2g = result.wifi_2g ?? {};
			wifiConfig.wifi5g = result.wifi_5g ?? null;
		}
	});
});
</script>
<style scoped>
:deep(.n-divider.n-divider--vertical) {
	height: 420px;
	margin: 0 30px;
}
</style>

<i18n src="./locale.json" />
