<template>
	<n-list v-if="data.length > 0" class="bg">
		<template #header>
			<n-space justify="space-between" class="pd-0-15">
				<div>{{ $t(title) + $t('device') }}</div>
				<n-space :size="50">
					<n-tooltip trigger="hover">
						<template #trigger>
							<div>{{ $t('internet') }}</div>
						</template>
						如果它长得像鸭子，走起来像鸭子，叫起来也像鸭子，那它一定是个鸭子。
					</n-tooltip>
					<div v-if="!online">{{ $t('operate') }}</div>
				</n-space>
			</n-space>
		</template>
		<n-list-item v-for="(item, index) in data" :key="index" class="list-item-border mg-bt-10">
			<n-space align="center" justify="space-between">
				<n-space>
					<n-icon size="40" :component="LogoAndroid"></n-icon>
					<n-space vertical size="small">
						<div>{{ item.name }}</div>
						<n-space :size="24">
							<n-space>
								{{ $t('IP地址') }}:
								<div>{{ item.ip }}</div>
							</n-space>
							<n-space>
								{{ $t('mac地址') }}:
								<div>{{ item.mac }}</div>
							</n-space>
							<n-space>
								{{ $t('speed') }}:
								<div>↑ {{ item.up }} | ↓ {{ item.down }}</div>
							</n-space>
							<n-space>
								{{ $t('total') }}:
								<div>↑ {{ item.total_up }} | ↓ {{ item.total_down }}</div>
							</n-space>
							<n-space>
								{{ $t('Qos') }}:
								<n-button type="primary" text ghost>{{ $t('settings') }}</n-button>
							</n-space>
						</n-space>
					</n-space>
				</n-space>
				<n-space :size="50">
					<n-switch v-model:value="item.blocked" size="medium" @update:value="handleChange(item)" />
					<n-button text v-if="!online" @click="delClient(item)">
						<n-icon size="18"><Delete20Filled /></n-icon>
					</n-button>
				</n-space>
			</n-space>
		</n-list-item>
	</n-list>
</template>

<script setup>
import {LogoAndroid, LogoApple} from '@vicons/ionicons4';
import {Delete20Filled} from '@vicons/fluent';
const {proxy} = getCurrentInstance();
const dialog = proxy.$dialog;

defineProps({
	data: {
		type: Array,
		default: function () {
			return [];
		}
	},
	title: String,
	online: Boolean
});
function handleChange(item) {
	console.log(item.blocked);
	proxy.$hiui.call('clients', 'addBlocked', {mac: item.mac}).then((result) => {
		console.log(result);
	});
}
function delClient(item) {
	dialog.warning({
		title: proxy.$t('警告'),
		content: proxy.$t('确认删除?'),
		positiveText: proxy.$t('确定'),
		negativeText: proxy.$t('取消'),
		onPositiveClick: () => {
			proxy.$hiui.call('clients', 'delClients', {mac: item.mac}).then((result) => {
				console.log(result);
			});
		},
		onNegativeClick: () => {}
	});
}
</script>
<style scoped></style>
