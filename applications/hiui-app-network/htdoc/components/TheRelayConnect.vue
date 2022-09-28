<template>
	<div class="flex-hor bg-color bg-border">
		<n-list class="width-fill pd-30">
			<template #header>
				<n-space justify="space-between">
					<n-space class="font-18" align="center">
						<div class="circle" :class="{gray: !relayInfo.up}"></div>
						{{ $t(relayInfo.name ?? 'Not connected') }}
						<n-tag :bordered="false" size="small" :type="relayInfo?.up ? 'info' : ''">{{ $t('current network') }}</n-tag>
					</n-space>
					<n-button v-if="relayInfo.up" ghost round color="red" size="medium" @click="disconnect">{{ $t('Disconnect') }}</n-button>
				</n-space>
			</template>
			<n-list-item v-for="i in relayInfo.info" :key="i">
				<n-thing :title="i[0]" :title-extra="i[1]" />
			</n-list-item>
		</n-list>
		<n-divider vertical />

		<n-list class="width-fill pd-30">
			<template #header>
				<n-space class="font-18" align="center">
					<div class="circle"></div>
					{{ $t('中继设置') }}
				</n-space>
			</template>
			<n-list-item>
				<div>{{ $t('Nearby available network') }}</div>
				<template #suffix>
					<n-button text type="info" @click="pushRelayd('scan')">{{ $t('scan') }}</n-button>
				</template>
			</n-list-item>
			<n-list-item>
				<div>{{ $t('History connect network') }}</div>
				<template #suffix>
					<n-button text type="info" @click="pushRelayd('check')">{{ $t('check') }}</n-button>
				</template>
			</n-list-item>
			<n-list-item>
				<div>{{ $t('Auto connect') }}</div>
				<template #suffix>
					<n-switch v-model:value="autoConnect" size="medium" @update:value="handleAutoConnect" />
				</template>
			</n-list-item>
		</n-list>
	</div>
	<n-modal v-model:show="loading" :close-on-esc="false" :mask-closable="false">
		<n-spin size="large">
			<template #description>
				<div style="color: var(--primary-color)">{{ $t('Upgrading') }}...</div>
			</template>
		</n-spin>
	</n-modal>
</template>

<script setup>
const props = defineProps({
	relayInfo: Object
});
const autoConnect = ref(false);
const loading = ref(false);
const {proxy} = getCurrentInstance();

function disconnect() {
	loading.value = true;
	proxy.$hiui.call('wireless', 'disRelaydConnect').then((result) => {
		if (result.code === 0) {
			loading.value = false;
		}
	});
}

function handleAutoConnect(params) {
	const disabled = params ? '0' : '1';
	proxy.$dialog.warning({
		title: '关闭自动连接',
		content: '停止自动连接,任何网络重启都将断开中继',
		positiveText: '确定',
		negativeText: '取消',
		autoFocus: false,
		style: 'border-radius: 8px;--n-icon-color: red;--n-content-margin: 10px 0 16px 28px',
		negativeButtonProps: {round: true, size: 'medium'},
		positiveButtonProps: {round: true, size: 'medium', color: '#0052D9'},
		onNegativeClick: () => {
			autoConnect.value = !params;
		},
		onPositiveClick: () => {
			proxy.$hiui.call('uci', 'set', {config: 'wireless', section: 'sta', values: {disabled}});
		}
	});
}

function pushRelayd(params) {
	let data;
	if (params === 'scan') {
		data = {action: 'scan'};
	} else if (params === 'check') {
		data = {action: 'check'};
	}
	proxy.$router.push({path: '/network/relayd', query: data});
}

onMounted(() => {
	proxy.$hiui.call('relayd', 'history').then((result) => {
		if (result) {
			result.forEach((item) => {
				if (item.ssid === props.relayInfo.name) {
					autoConnect.value = item.disabled !== '1';
				}
			});
		}
	});
});
</script>
<style scoped>
:deep(.n-divider.n-divider--vertical) {
	height: 200px;
	margin: 50px 30px;
}

.pd-30 {
	padding: 18px 30px 30px 30px;
}
</style>
