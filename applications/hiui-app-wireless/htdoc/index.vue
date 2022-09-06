<template>
	<div class="components-bg pd-30" vertical>
		<n-layout>
			<n-space align="center">
				<div class="circle"></div>
				<div class="font-24-size">{{ $t('Network Status') }}</div>
			</n-space>
		</n-layout>
		<n-divider />

		<div class="bg-color bg-border">
			<the-wifi-settings :wifiInfo="wifi"></the-wifi-settings>
			<n-divider vertical />
			<the-wifi-settings :wifiInfo="wifi"></the-wifi-settings>
		</div>
	</div>
</template>

<script setup>
import TheWifiSettings from './components/TheWifiSettings.vue';
const wifi = {
	name: 'test',
	password: '12342211'
};
</script>
<style scoped>
:deep(.n-divider.n-divider--vertical) {
	height: 420px;
	margin: 0 30px;
}
</style>

<i18n src="./locale.json" />
