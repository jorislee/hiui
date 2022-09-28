<template>
	<n-page-header @back="handleBack" class="components-bg pd-30">
		<template #title>
			{{ $t('Relayd Settings') }}
		</template>
		<!-- --------------------历史网络-------------------- -->
		<n-space v-if="route.query.action === 'check'" vertical class="pd-20 bg-border">
			<n-space justify="space-between" class="pd-0-15" style="font-size: 12px">
				{{ $t('History connect network') }}
				<n-space :size="35">
					<div>{{ $t('enable network') }}</div>
					<div>{{ $t('del') }}</div>
				</n-space>
			</n-space>
			<n-list bordered>
				<n-space vertical>
					<n-list-item v-for="(item, index) in historyList" :key="index" class="bg">
						<n-space justify="space-between" align="center">
							<div class="flex-hor-ac">
								<n-icon size="24" :component="MdWifi"></n-icon>
								<span class="pd-0-15">{{ item.ssid }}</span>
								<span>({{ item.bssid }})</span>
								<n-tag v-if="item.up" type="info" size="small">{{ $t('current') }}</n-tag>
							</div>
							<div class="flex-hor-ac">
								<n-switch style="padding-right: 45px" v-model:value="item.up" size="medium" @update:value="changeNetwork(item)" />
								<n-button text @click="removeWifi(index, item)">
									<n-icon size="18"><DeleteFilled /></n-icon>
								</n-button>
							</div>
						</n-space>
					</n-list-item>
				</n-space>
			</n-list>
			<n-empty v-if="historyList.length === 0" description="什么也没有"></n-empty>
		</n-space>
		<!-- ----------------------------------------------- -->

		<!-- --------------------附近网络-------------------- -->
		<n-space v-else-if="route.query.action === 'scan'" vertical class="pd-20 bg-border">
			<n-space justify="space-between" class="pd-0-15">
				<div>{{ $t('Nearby available network') }}</div>
				<div>{{ $t('Join network') }}</div>
			</n-space>
			<n-list bordered>
				<n-space vertical>
					<n-list-item v-for="(item, index) in wifiList" :key="index" class="bg">
						<n-space justify="space-between" align="center">
							<div class="flex-hor-ac">
								<n-icon size="24" :component="MdWifi"></n-icon>
								<span class="pd-0-15">{{ item.ssid }}</span>
								<span>({{ item.bssid }})</span>
							</div>
							<div>
								<n-switch v-model:value="item.up" size="medium" @update:value="readyJoin(item)" />
							</div>
						</n-space>
					</n-list-item>
				</n-space>
			</n-list>
			<n-progress v-if="scaning > 0" type="line" :percentage="scaning" :indicator-placement="'inside'" processing />
		</n-space>
		<!-- ----------------------------------------------- -->
	</n-page-header>
	<n-modal :show="showModal" preset="dialog" :title="modalTitle" :show-icon="false">
		<n-space vertical>
			<n-input type="password" size="large" show-password-on="mousedown" placeholder="密码" :minlength="8" v-model:value="password" />
			<n-checkbox v-model:checked="remember" :label="$t('remember network')" />
		</n-space>

		<template #action>
			<n-space align="center">
				<n-button round @click="cancelJoin">{{ $t('cancel') }}</n-button>
				<n-button type="info" round @click="joinNetwork" :disabled="!password">{{ $t('join') }}</n-button>
			</n-space>
		</template>
	</n-modal>
	<n-modal v-model:show="joining" :close-on-esc="false" :mask-closable="false">
		<n-spin size="large">
			<template #description>
				<div>{{ $t('Joining') }}...</div>
			</template>
		</n-spin>
	</n-modal>
</template>

<script setup>
import {DeleteFilled} from '@vicons/antd';
import {MdWifi} from '@vicons/ionicons4';

const {proxy} = getCurrentInstance();
const dialog = proxy.$dialog;
const wifiList = ref([]);
const remember = ref(true);
const password = ref('');
let curItem;
const historyList = ref([]);
const showModal = ref(false);
const modalTitle = ref('');
const scaning = ref(0);
const joining = ref(false);
const route = proxy.$router.currentRoute.value;
function handleBack() {
	window.history.back();
}

//===================附近网络========================
function scanlist() {
	proxy.$timer.create(
		'scaning',
		() => {
			if (scaning.value >= 99) {
				scaning.value = 99;
				return;
			}
			scaning.value += Math.floor(Math.random() * 10 + 1);
		},
		{repeat: true, immediate: true}
	);
	proxy.$hiui
		.call('relayd', 'scan')
		.then((result) => {
			scaning.value = 99;
			proxy.$timer.stop('scaning');
			Object.keys(result).map((key) => {
				for (const i of result[key]) {
					if (i.ssid) {
						i.device = key;
						wifiList.value.push(i);
					}
				}
			});
			scaning.value = 0;
		})
		.catch((err) => {
			console.log(err);
		});
}

function readyJoin(item) {
	modalTitle.value = proxy.$t('input password', [item.ssid]);
	showModal.value = item.up;
	curItem = item;
}

function joinNetwork() {
	curItem.key = password.value;
	let encryption = 'psk2';
	switch (curItem.encryption.wpa) {
		case 0:
			encryption = 'none';
			break;
		case 1:
			encryption = 'psk';
			break;
		case 2:
			encryption = 'psk2';
			break;
		case 3:
			encryption = 'psk-mixed';
			break;
		case 4:
			encryption = 'sae';
			break;
		case 6:
			encryption = 'psk-mixed';
			break;
		default:
			break;
	}
	curItem.encryption = encryption;
	curItem.remember = remember;
	proxy.$hiui.call('relayd', 'join', curItem).then((result) => {
		console.log(result, 'join');
	});
	showModal.value = false;
	joining.value = true;

	password.value = '';
}

function cancelJoin() {
	showModal.value = false;
	curItem.up = false;
}
//===================附近网络========================

function curNetwork() {
	proxy.$hiui.call('wireless', 'relayInfo').then((result) => {
		console.log(result);
		historyList.value.forEach((item) => {
			if (result.name === item.ssid && !joining.value) {
				item.up = result.up;
			}
		});
		if (result.up && joining.value) {
			joining.value = false;
			proxy.$message.success('success');
			proxy.$timer.create('pushNetwork', () => {
				proxy.$router.push('/network');
			});
		}
	});
}

//===================历史网络========================
function getHistoryList() {
	proxy.$hiui.call('relayd', 'history').then((result) => {
		console.log(result);
		if (result) {
			historyList.value.push(...result);
		}
	});
}

function changeNetwork(params) {
	proxy.$hiui.call('relayd', 'updateHistory', params).then((result) => {
		if (result.code === 0 && params.up) {
			joining.value = true;
		}
	});
}

function removeWifi(index, item) {
	dialog.warning({
		title: '移除网络',
		content: '删除历史连接记录,再次连接时需要重新输入密码',
		positiveText: '确定',
		negativeText: '取消',
		autoFocus: false,
		style: 'border-radius: 8px;--n-icon-color: red;--n-content-margin: 10px 0 16px 28px',
		negativeButtonProps: {round: true, size: 'medium'},
		positiveButtonProps: {round: true, size: 'medium', color: '#0052D9'},
		onNegativeClick: () => {
			console.log('cancel');
		},
		onPositiveClick: () => {
			proxy.$hiui.call('relayd', 'delHistory', item).then((result) => {
				if (result.code === 0) {
					historyList.value.splice(index, 1);
				}
			});
		}
	});
}
//===================历史网络========================

onBeforeMount(() => {
	if (route.query.action === 'scan') {
		scanlist();
	} else if (route.query.action === 'check') {
		getHistoryList();
	}
	proxy.$timer.create('curNetwork', curNetwork, {repeat: true, immediate: true, time: 10000});
});
</script>
<style scoped>
.bg {
	background-color: #ffffff;
	border: 1px solid rgba(73, 87, 112, 0.15);
}
:deep(.__dialog-dark-dl) {
	--n-border-radius: 8px !important;
}
:deep(.__dialog-dl) {
	--n-border-radius: 8px !important;
}
</style>

<i18n src="./locale.json" />
