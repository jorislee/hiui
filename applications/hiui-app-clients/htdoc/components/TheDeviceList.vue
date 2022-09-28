<template>
	<n-list v-if="data.length > 0" class="bg">
		<template #header>
			<n-space justify="space-between" class="pd-0-15">
				<div class="secondary-text">{{ $t(title) + $t('device') }}</div>
				<!-- <n-space :size="50">
					<n-tooltip trigger="hover">
						<template #trigger>
							<div>{{ $t('internet') }}</div>
						</template>
						{{ $t('关闭后用户将无法使用网络') }}
					</n-tooltip>
					<div v-if="!online">{{ $t('operate') }}</div>
				</n-space> -->
			</n-space>
		</template>
		<n-list-item v-for="(item, index) in data" :key="index" class="list-item-border mg-bt-10">
			<n-space align="center" justify="space-between">
				<div class="flex-hor-ac">
					<div class="icon-bg">
						<n-icon size="24" :component="DeviceUnknownOutlined"></n-icon>
					</div>
					<n-space vertical size="small" class="pd-0-20">
						<div>{{ item.name }}</div>
						<n-space :size="24" class="secondary-text">
							<n-space size="small">
								{{ $t('IP Addr') }}:
								<div>{{ item.ip }}</div>
							</n-space>
							<div class="flex-hor-ac">
								<n-tooltip trigger="hover">
									<template #trigger>
										<n-icon :size="18" :component="item.bind ? LinkOutlined : DisconnectOutlined" :color="item.bind ? 'green' : ''"></n-icon>
									</template>
									{{ item.bind ? $t('bind') : $t('unbind') }}
								</n-tooltip>
								<n-space>
									<div>{{ $t('MAC Addr') }}:</div>
									<div>{{ item.mac }}</div>
								</n-space>
							</div>
							<n-space v-if="traffic">
								<n-space style="width: 220px" size="small">
									{{ $t('Speed') }}:
									<div>↑ {{ bytesToSizeList(item.up) }} | ↓ {{ bytesToSizeList(item.down) }}</div>
								</n-space>
								<n-space style="width: 220px" size="small">
									{{ $t('Total') }}:
									<div>↑ {{ bytesToSizeList(item.total_up) }} | ↓ {{ bytesToSizeList(item.total_down) }}</div>
								</n-space>
								<!-- <n-space size="small">
									{{ $t('Qos') }}:
									<n-button type="primary" text ghost @click="setQos(item)">{{ $t('settings') }}</n-button>
								</n-space> -->
							</n-space>
						</n-space>
					</n-space>
				</div>
				<!-- <n-space :size="50">
					<n-switch v-model:value="item.blocked" size="medium" @update:value="handleChange(item)" />
					<n-button text v-if="!online" @click="delClient(item)">
						<n-icon size="18"><Delete20Filled /></n-icon>
					</n-button>
				</n-space> -->
			</n-space>
		</n-list-item>
	</n-list>
	<n-modal v-model:show="showQosMoal" preset="dialog" title="QoS限速范围(1KB/s-1GB/s)" :show-icon="false" style="width: 420px; border-radius: 8px">
		<n-space vertify>
			<n-space align="center">
				<div class="w-100">上传限速</div>
				<n-input v-model:value="qos_up" type="text" size="large" clearable>
					<template #suffix>
						<div style="color: #98a3b7">{{ $t('KB/s') }}</div>
					</template>
				</n-input>
			</n-space>
			<n-space align="center">
				<div class="w-100">Download Limit</div>
				<n-input v-model:value="qos_down" type="text" size="large" clearable>
					<template #suffix>
						<div style="color: #98a3b7">{{ $t('KB/s') }}</div>
					</template>
				</n-input>
			</n-space>
		</n-space>
		<template #action>
			<n-space align="center">
				<n-button round @click="cancelQos">{{ $t('cancel') }}</n-button>
				<n-button type="info" round @click="applyQos">{{ $t('apply') }}</n-button>
			</n-space>
		</template>
	</n-modal>
</template>

<script setup>
import {DeviceUnknownOutlined} from '@vicons/material';
import {LinkOutlined, DisconnectOutlined} from '@vicons/antd';
const props = defineProps({
	data: {
		type: Array,
		default: function () {
			return [];
		}
	},
	title: String,
	online: Boolean,
	traffic: Boolean
});
const {proxy} = getCurrentInstance();
const dialog = proxy.$dialog;
const showQosMoal = ref(false);
const qos_up = ref('0');
const qos_down = ref('0');
let curItem;

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

function setQos(item) {
	showQosMoal.value = true;
	curItem = item;
}

function applyQos() {
	const regtext = /^\d+$/;
	if (!regtext.test(qos_up.value) || !regtext.test(qos_down.value)) {
		proxy.$message.error('this.$lang.clients.Exceed1');
		return;
	}
	if (qos_up.value.length >= 2) {
		console.log(qos_up.value.slice(0, 1));
		if (qos_up.value.slice(0, 1) === '0') {
			proxy.$message.error('this.$lang.clients.Exceed2');
			return;
		}
	}
	if (qos_down.value.length >= 2) {
		console.log(qos_down.value.slice(0, 1));
		if (qos_down.value.slice(0, 1) === '0') {
			proxy.$message.error('this.$lang.clients.Exceed3');
			return;
		}
	}
	if (parseInt(qos_up.value) > 1048576 || parseInt(qos_up.value) <= 0) {
		proxy.$message.error('this.$lang.clients.Exceed4');
		return;
	}
	if (parseInt(qos_down.value) > 1048576 || parseInt(qos_down.value) <= 0) {
		proxy.$message.error('this.$lang.clients.Exceed5');
		return;
	}

	proxy.$hiui.call('clients', 'setQos', {mac: curItem.mac, upload: qos_up, download: qos_down}).then((result) => {
		console.log(result);
	});
}

function cancelQos() {
	showQosMoal.value = false;
	qos_up.value = '0';
	qos_down.value = '0';
}

function handleChange(item) {
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
<style scoped>
.w-100 {
	width: 100px;
}
.icon-bg {
	width: 40px;
	height: 40px;
	border-radius: 6px;
	background: rgba(73, 87, 112, 0.15);
	display: flex;
	align-items: center;
	justify-content: center;
}
.secondary-text {
	color: #98a3b7;
}
</style>
