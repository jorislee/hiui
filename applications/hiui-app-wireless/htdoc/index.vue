<template>
	<div class="components-bg pd-30" vertical>
		<n-layout>
			<n-space align="center">
				<div class="circle"></div>
				<div class="font-24-size">{{ $t('Wireless') }}</div>
			</n-space>
		</n-layout>
		<n-divider />

		<div class="bg-color bg-border flex-hor-ac">
			<the-wifi-settings :wifi-info="wifiConfig.wifi2g" :title="$t('2.4G WIFI')"></the-wifi-settings>
			<n-divider vertical v-if="wifiConfig.wifi5g" />
			<the-wifi-settings v-if="wifiConfig.wifi5g" :wifi-info="wifiConfig.wifi5g" :title="$t('5G WIFI')"></the-wifi-settings>
		</div>
	</div>
</template>

<script setup>
import TheWifiSettings from './components/TheWifiSettings.vue';
const {proxy} = getCurrentInstance();
const wifiConfig = reactive({wifi2g: {}, wifi5g: {}});
onBeforeMount(() => {
	proxy.$hiui.call('wireless', 'getConfig').then((result) => {
		console.log(result);
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
