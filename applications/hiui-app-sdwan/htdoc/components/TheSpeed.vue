<template>
	<div class="bg-color bg-border">
		<n-list class="width-fill pd-30">
			<n-list-item>
				<n-space align="center" justify="space-between">
					<div>{{ $t('Enable Speed') }}</div>
					<n-switch v-model:value="speedInfo.up" size="medium" @update:value="enableSpeed" />
				</n-space>
			</n-list-item>
			<n-list-item>
				<n-space align="center" justify="space-between">
					<div>{{ $t('Remaining Time') }}</div>
					<div>{{ speedInfo.time }}</div>
				</n-space>
			</n-list-item>
			<n-list-item>
				<n-space align="center" justify="space-between">
					<div>{{ $t('Line') }}</div>
					<div>{{ speedInfo.line }}</div>
				</n-space>
			</n-list-item>
			<n-list-item>
				<n-space align="center" justify="space-between">
					<div>{{ $t('Network Speed') }}</div>
					<n-space>↑ {{ bytesToSizeList(netSpeed.up) }} | ↓ {{ bytesToSizeList(netSpeed.down) }}</n-space>
				</n-space>
			</n-list-item>
			<n-list-item>
				<n-space justify="flex-end">
					<n-button type="info" round :disabled="!hasChange" @click="Apply">{{ $t('Apply') }}</n-button>
				</n-space>
			</n-list-item>
		</n-list>
	</div>
</template>

<script setup>
const {proxy} = getCurrentInstance();
const speedInfo = reactive({});
const netSpeed = reactive({});
const hasChange = ref(false);
let curStatus;

function bytesToSizeList(num) {
	if (num === 0 || !num) return '0 B';
	const k = 1024;
	const sizeStr = ['B', 'KB', 'MB', 'GB', 'TB', 'PB', 'EB', 'ZB', 'YB'];
	let i = 0;
	for (let l = 0; l < 8; l++) {
		if (num / Math.pow(k, l) < 1) {
			break;
		}
		i = l;
	}
	let item = (num / Math.pow(k, i)).toFixed(1) + ' ' + sizeStr[i];
	return item;
}

function enableSpeed(params) {
	if (curStatus !== speedInfo.up) {
		hasChange.value = true;
	} else {
		hasChange.value = false;
	}
}

function Apply() {
	proxy.$hiui.call('sdwan', 'enableSpeed', {enable: speedInfo.up ? '0' : '1'});
}

onBeforeMount(() => {
	proxy.$hiui.call('sdwan', 'status').then((result) => {
		console.log(result);
	});
});
</script>
<style scoped lang="less"></style>
