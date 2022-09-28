<template>
	<div class="components-bg pd-30">
		<n-layout>
			<n-space align="center">
				<div class="circle"></div>
				<div class="font-24-size">{{ $t('Clients') }}</div>
			</n-space>
		</n-layout>
		<n-divider />
		<n-space justify="space-between" style="padding-bottom: 20px">
			<n-radio-group v-model:value="cur" name="curpage" @update:value="handlePageChange">
				<n-space>
					<n-radio-button class="bt-radio" key="speed" value="speed" :label="$t('Speed')" />
					<n-radio-button class="bt-radio" key="shunt" value="shunt" :label="$t('Shunt')" />
				</n-space>
			</n-radio-group>
		</n-space>
		<the-speed v-if="cur === 'speed'"></the-speed>
		<the-shunt v-else-if="cur === 'shunt'"></the-shunt>
	</div>
</template>

<script setup>
import TheSpeed from './components/TheSpeed.vue';
import TheShunt from './components/TheShunt.vue';
const cur = ref('speed');

function handlePageChange(params) {
	console.log(params);
}
</script>

<style scoped>
.bt-radio {
	height: 32px;
	display: flex;
	align-items: center;
}
</style>
<i18n src="./locale.json" />
