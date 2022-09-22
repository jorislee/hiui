<template>
	<n-page-header @back="handleBack" class="components-bg pd-30">
		<template #title>
			{{ $t('Relayd Settings') }}
		</template>
		<n-space v-if="route.query.action === 'check'" vertical class="pd-20 components-bg">
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
								<n-tag v-if="item.auto" type="info" size="small">{{ $t('current') }}</n-tag>
							</div>
							<div class="flex-hor-ac">
								<n-switch style="padding-right: 45px" v-model:value="item.auto" size="medium" @update:value="changeNetwork(item)" />
								<n-button text @click="removeWifi(item)">
									<n-icon size="18"><DeleteFilled /></n-icon>
								</n-button>
							</div>
						</n-space>
					</n-list-item>
				</n-space>
			</n-list>
			<n-empty v-if="historyList.length === 0" description="什么也没有"></n-empty>
		</n-space>
		<n-space v-else-if="route.query.action === 'scan'" vertical class="pd-20 components-bg">
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
								<n-switch v-model:value="item.auto" size="medium" @update:value="readyJoin(item)" />
							</div>
						</n-space>
					</n-list-item>
				</n-space>
			</n-list>
			<n-progress v-if="scaning > 0" type="line" :percentage="scaning" :indicator-placement="'inside'" processing />
		</n-space>
	</n-page-header>
	<n-modal :show="showModal" preset="dialog" :title="modalTitle" :show-icon="false">
		<n-space vertical>
			<n-input type="password" show-password-on="mousedown" placeholder="密码" :minlength="8" v-model:value="password" />
			<n-checkbox v-model:checked="remember" :label="$t('remember network')" />
		</n-space>

		<template #action>
			<n-space align="center">
				<n-button round @click="cancelJoin">{{ $t('cancel') }}</n-button>
				<n-button type="info" round @click="joinNetwork">{{ $t('join') }}</n-button>
			</n-space>
		</template>
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
const route = proxy.$router.currentRoute.value;
function handleBack() {
	window.history.back();
}

//===================附近网络========================
function scanlist() {
	proxy.$timer.create(
		'scanWifi',
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
			proxy.$timer.stop('scanWifi');
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
	showModal.value = item.auto;
	curItem = item;
}

function joinNetwork() {
	curItem.key = password.value;
	console.log(curItem);
	proxy.$hiui.call('relayd', 'join', curItem).then(({result}) => {
		if (result.code) {
			showModal.value = false;
		}
		console.log(result);
	});
	showModal.value = false;
}

function cancelJoin() {
	showModal.value = false;
	curItem.auto = false;
}
//===================附近网络========================

function curNetwork() {
	proxy.$hiui.call('wireless', 'relayInfo').then((result) => {
		console.log(result);
	});
}

//===================历史网络========================
function getHistoryList() {
	proxy.$hiui.call('relayd', 'history').then(({result}) => {
		if (result) {
			historyList.value.push(...result);
		}
	});
}

function changeNetwork(params) {
	historyList.value.forEach((item) => {
		console.log(params);
		if (item.bssid !== params.bssid) {
			item.auto = false;
		}
	});
	proxy.$hiui.call('relayd', 'updateHistory', params).then(({result}) => {
		console.log(result);
	});
}

function removeWifi(item) {
	dialog.warning({
		title: '移除网络',
		content: '停止自动连接“GAOER-Mac”，再次连接时可能需要重新输入密码。',
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
				console.log(result);
			});
		}
	});
}
//===================历史网络========================

function test() {
	let test = {
		radio0: [
			{
				quality_max: 70,
				ssid: 'B1300-9b4-5G',
				encryption: {
					enabled: true,
					auth_algs: [],
					description: 'mixed WPA/WPA2 PSK (TKIP, CCMP)',
					wep: false,
					auth_suites: ['PSK'],
					wpa: 3,
					pair_ciphers: ['TKIP', 'CCMP'],
					group_ciphers: ['TKIP']
				},
				bssid: '94:83:C4:03:79:B5',
				channel: 149,
				htmodelist: {
					HT40: true,
					VHT40: true,
					VHT160: false,
					VHT20: true,
					VHT80: true,
					'VHT80+80': false,
					HT20: true
				},
				mode: 'Master',
				signal: -53,
				quality: 57,
				device: 'radio0'
			},
			{
				quality_max: 70,
				ssid: 'AJAX_5G',
				encryption: {
					enabled: true,
					auth_algs: [],
					description: 'mixed WPA/WPA2 PSK (CCMP)',
					wep: false,
					auth_suites: ['PSK'],
					wpa: 3,
					pair_ciphers: ['CCMP'],
					group_ciphers: ['CCMP']
				},
				bssid: 'F4:2A:7D:2A:95:39',
				channel: 153,
				htmodelist: {
					HT40: true,
					VHT40: true,
					VHT160: false,
					VHT20: true,
					VHT80: true,
					'VHT80+80': false,
					HT20: true
				},
				mode: 'Master',
				signal: -53,
				quality: 57,
				device: 'radio0'
			},
			{
				quality_max: 70,
				ssid: 'AJAX_5G',
				encryption: {
					enabled: true,
					auth_algs: [],
					description: 'mixed WPA/WPA2 PSK (CCMP)',
					wep: false,
					auth_suites: ['PSK'],
					wpa: 3,
					pair_ciphers: ['CCMP'],
					group_ciphers: ['CCMP']
				},
				bssid: '80:EA:07:E9:23:DE',
				channel: 153,
				htmodelist: {
					HT40: true,
					VHT40: true,
					VHT160: false,
					VHT20: true,
					VHT80: true,
					'VHT80+80': false,
					HT20: true
				},
				mode: 'Master',
				signal: -42,
				quality: 68,
				device: 'radio0'
			},
			{
				htmodelist: {
					HT40: true,
					VHT40: true,
					VHT160: false,
					VHT20: true,
					VHT80: true,
					'VHT80+80': false,
					HT20: true
				},
				quality_max: 70,
				encryption: {
					enabled: true,
					auth_algs: [],
					description: 'mixed WPA/WPA2 PSK (CCMP)',
					wep: false,
					auth_suites: ['PSK'],
					wpa: 3,
					pair_ciphers: ['CCMP'],
					group_ciphers: ['CCMP']
				},
				channel: 153,
				signal: -53,
				mode: 'Master',
				bssid: 'F6:2A:7D:2A:95:39',
				quality: 57,
				device: 'radio0'
			},
			{
				htmodelist: {
					HT40: true,
					VHT40: true,
					VHT160: false,
					VHT20: true,
					VHT80: true,
					'VHT80+80': false,
					HT20: true
				},
				quality_max: 70,
				encryption: {
					enabled: true,
					auth_algs: [],
					description: 'mixed WPA/WPA2 PSK (CCMP)',
					wep: false,
					auth_suites: ['PSK'],
					wpa: 3,
					pair_ciphers: ['CCMP'],
					group_ciphers: ['CCMP']
				},
				channel: 153,
				signal: -42,
				mode: 'Master',
				bssid: '82:EA:07:E9:23:DE',
				quality: 68,
				device: 'radio0'
			},
			{
				quality_max: 70,
				ssid: 'AJAX_5G',
				encryption: {
					enabled: true,
					auth_algs: [],
					description: 'mixed WPA/WPA2 PSK (CCMP)',
					wep: false,
					auth_suites: ['PSK'],
					wpa: 3,
					pair_ciphers: ['CCMP'],
					group_ciphers: ['CCMP']
				},
				bssid: '18:F2:2C:8C:0C:30',
				channel: 153,
				htmodelist: {
					HT40: true,
					VHT40: true,
					VHT160: false,
					VHT20: true,
					VHT80: true,
					'VHT80+80': false,
					HT20: true
				},
				mode: 'Master',
				signal: -51,
				quality: 59,
				device: 'radio0'
			},
			{
				htmodelist: {
					HT40: true,
					VHT40: true,
					VHT160: false,
					VHT20: true,
					VHT80: true,
					'VHT80+80': false,
					HT20: true
				},
				quality_max: 70,
				encryption: {
					enabled: true,
					auth_algs: [],
					description: 'mixed WPA/WPA2 PSK (CCMP)',
					wep: false,
					auth_suites: ['PSK'],
					wpa: 3,
					pair_ciphers: ['CCMP'],
					group_ciphers: ['CCMP']
				},
				channel: 153,
				signal: -51,
				mode: 'Master',
				bssid: '1A:F2:2C:DC:0C:2E',
				quality: 59,
				device: 'radio0'
			},
			{
				quality_max: 70,
				ssid: 'GL-AR750S-248-5G1123',
				encryption: {
					enabled: true,
					auth_algs: [],
					description: 'WPA2 PSK (CCMP)',
					wep: false,
					auth_suites: ['PSK'],
					wpa: 2,
					pair_ciphers: ['CCMP'],
					group_ciphers: ['CCMP']
				},
				bssid: '96:83:C4:0D:A2:49',
				channel: 36,
				htmodelist: {
					HT40: true,
					VHT40: true,
					VHT160: false,
					VHT20: true,
					VHT80: true,
					'VHT80+80': false,
					HT20: true
				},
				mode: 'Master',
				signal: -54,
				quality: 56,
				device: 'radio0'
			},
			{
				htmodelist: {
					HT40: true,
					VHT40: true,
					VHT160: false,
					VHT20: true,
					VHT80: true,
					'VHT80+80': false,
					HT20: true
				},
				quality_max: 70,
				encryption: {
					enabled: true,
					auth_algs: [],
					description: 'WPA2 PSK (CCMP)',
					wep: false,
					auth_suites: ['PSK'],
					wpa: 2,
					pair_ciphers: ['CCMP'],
					group_ciphers: ['CCMP']
				},
				channel: 36,
				signal: -55,
				mode: 'Master',
				bssid: '94:83:C4:0D:A2:49',
				quality: 55,
				device: 'radio0'
			},
			{
				quality_max: 70,
				ssid: '能慧集团办公室',
				encryption: {
					enabled: true,
					auth_algs: [],
					description: 'mixed WPA/WPA2 PSK (TKIP, CCMP)',
					wep: false,
					auth_suites: ['PSK'],
					wpa: 3,
					pair_ciphers: ['TKIP', 'CCMP'],
					group_ciphers: ['TKIP']
				},
				bssid: '30:0D:9E:FF:47:B5',
				channel: 36,
				htmodelist: {
					HT40: true,
					VHT40: true,
					VHT160: false,
					VHT20: true,
					VHT80: true,
					'VHT80+80': false,
					HT20: true
				},
				mode: 'Master',
				signal: -67,
				quality: 43,
				device: 'radio0'
			},
			{
				quality_max: 70,
				ssid: 'YXYC2-5G',
				encryption: {
					enabled: true,
					auth_algs: [],
					description: 'mixed WPA/WPA2 PSK (CCMP)',
					wep: false,
					auth_suites: ['PSK'],
					wpa: 3,
					pair_ciphers: ['CCMP'],
					group_ciphers: ['CCMP']
				},
				bssid: 'C4:27:28:68:4F:79',
				channel: 44,
				htmodelist: {
					HT40: true,
					VHT40: true,
					VHT160: true,
					VHT20: true,
					VHT80: true,
					'VHT80+80': false,
					HT20: true
				},
				mode: 'Master',
				signal: -73,
				quality: 37,
				device: 'radio0'
			},
			{
				quality_max: 70,
				ssid: 'OpenWrt-5g',
				encryption: {
					enabled: true,
					auth_algs: [],
					description: 'WPA2 PSK (CCMP)',
					wep: false,
					auth_suites: ['PSK'],
					wpa: 2,
					pair_ciphers: ['CCMP'],
					group_ciphers: ['CCMP']
				},
				bssid: 'E4:67:1E:09:C0:7C',
				channel: 44,
				htmodelist: {
					HT40: true,
					VHT40: true,
					VHT160: false,
					VHT20: true,
					VHT80: false,
					'VHT80+80': false,
					HT20: true
				},
				mode: 'Master',
				signal: -67,
				quality: 43,
				device: 'radio0'
			},
			{
				quality_max: 70,
				ssid: '能慧集团',
				encryption: {
					enabled: true,
					auth_algs: [],
					description: 'WPA2 PSK (CCMP)',
					wep: false,
					auth_suites: ['PSK'],
					wpa: 2,
					pair_ciphers: ['CCMP'],
					group_ciphers: ['CCMP']
				},
				bssid: '30:0D:9E:FF:4C:F2',
				channel: 52,
				htmodelist: {
					HT40: true,
					VHT40: true,
					VHT160: false,
					VHT20: true,
					VHT80: true,
					'VHT80+80': false,
					HT20: true
				},
				mode: 'Master',
				signal: -54,
				quality: 56,
				device: 'radio0'
			},
			{
				quality_max: 70,
				ssid: 'CU_hrhd_5G',
				encryption: {
					enabled: true,
					auth_algs: [],
					description: 'mixed WPA/WPA2 PSK (TKIP, CCMP)',
					wep: false,
					auth_suites: ['PSK'],
					wpa: 3,
					pair_ciphers: ['TKIP', 'CCMP'],
					group_ciphers: ['TKIP']
				},
				bssid: '80:EE:25:C4:CA:51',
				channel: 56,
				htmodelist: {
					HT40: true,
					VHT40: true,
					VHT160: false,
					VHT20: true,
					VHT80: true,
					'VHT80+80': false,
					HT20: true
				},
				mode: 'Master',
				signal: -57,
				quality: 53,
				device: 'radio0'
			},
			{
				quality_max: 70,
				ssid: '能慧集团',
				encryption: {
					enabled: true,
					auth_algs: [],
					description: 'WPA2 PSK (CCMP)',
					wep: false,
					auth_suites: ['PSK'],
					wpa: 2,
					pair_ciphers: ['CCMP'],
					group_ciphers: ['CCMP']
				},
				bssid: '30:0D:9E:FF:4C:D7',
				channel: 60,
				htmodelist: {
					HT40: true,
					VHT40: true,
					VHT160: false,
					VHT20: true,
					VHT80: true,
					'VHT80+80': false,
					HT20: true
				},
				mode: 'Master',
				signal: -54,
				quality: 56,
				device: 'radio0'
			},
			{
				quality_max: 70,
				ssid: '能慧集团',
				encryption: {
					enabled: true,
					auth_algs: [],
					description: 'WPA2 PSK (CCMP)',
					wep: false,
					auth_suites: ['PSK'],
					wpa: 2,
					pair_ciphers: ['CCMP'],
					group_ciphers: ['CCMP']
				},
				bssid: '30:0D:9E:FF:4C:EF',
				channel: 60,
				htmodelist: {
					HT40: true,
					VHT40: true,
					VHT160: false,
					VHT20: true,
					VHT80: true,
					'VHT80+80': false,
					HT20: true
				},
				mode: 'Master',
				signal: -59,
				quality: 51,
				device: 'radio0'
			},
			{
				quality_max: 70,
				ssid: 'CU_97e3_5G',
				encryption: {
					enabled: true,
					auth_algs: [],
					description: 'WPA2 PSK (TKIP, CCMP)',
					wep: false,
					auth_suites: ['PSK'],
					wpa: 2,
					pair_ciphers: ['TKIP', 'CCMP'],
					group_ciphers: ['TKIP']
				},
				bssid: '28:C0:1B:16:0A:2F',
				channel: 64,
				htmodelist: {
					HT40: true,
					VHT40: true,
					VHT160: false,
					VHT20: true,
					VHT80: true,
					'VHT80+80': false,
					HT20: true
				},
				mode: 'Master',
				signal: -84,
				quality: 26,
				device: 'radio0'
			},
			{
				quality_max: 70,
				ssid: 'CU_bkre_5G',
				encryption: {
					enabled: true,
					auth_algs: [],
					description: 'WPA2 PSK (TKIP, CCMP)',
					wep: false,
					auth_suites: ['PSK'],
					wpa: 2,
					pair_ciphers: ['TKIP', 'CCMP'],
					group_ciphers: ['TKIP']
				},
				bssid: '68:1A:A4:22:FF:0B',
				channel: 157,
				htmodelist: {
					HT40: true,
					VHT40: true,
					VHT160: false,
					VHT20: true,
					VHT80: true,
					'VHT80+80': false,
					HT20: true
				},
				mode: 'Master',
				signal: -73,
				quality: 37,
				device: 'radio0'
			},
			{
				quality_max: 70,
				ssid: 'Xiaomi_5AE7_5G',
				encryption: {
					enabled: true,
					auth_algs: [],
					description: 'mixed WPA/WPA2 PSK (TKIP, CCMP)',
					wep: false,
					auth_suites: ['PSK'],
					wpa: 3,
					pair_ciphers: ['TKIP', 'CCMP'],
					group_ciphers: ['TKIP']
				},
				bssid: '28:6C:07:CB:5A:E9',
				channel: 157,
				htmodelist: {
					HT40: true,
					VHT40: true,
					VHT160: true,
					VHT20: true,
					VHT80: true,
					'VHT80+80': false,
					HT20: true
				},
				mode: 'Master',
				signal: -33,
				quality: 70,
				device: 'radio0'
			},
			{
				quality_max: 70,
				ssid: 'bbc-5g',
				encryption: {
					enabled: true,
					auth_algs: [],
					description: 'mixed WPA/WPA2 PSK (TKIP, CCMP)',
					wep: false,
					auth_suites: ['PSK'],
					wpa: 3,
					pair_ciphers: ['TKIP', 'CCMP'],
					group_ciphers: ['TKIP']
				},
				bssid: '94:83:C4:03:7B:BD',
				channel: 161,
				htmodelist: {
					HT40: true,
					VHT40: true,
					VHT160: false,
					VHT20: true,
					VHT80: true,
					'VHT80+80': false,
					HT20: true
				},
				mode: 'Master',
				signal: -44,
				quality: 66,
				device: 'radio0'
			},
			{
				quality_max: 70,
				ssid: 'AX1800-5G',
				encryption: {
					enabled: true,
					auth_algs: [],
					description: 'WPA2 PSK (CCMP)',
					wep: false,
					auth_suites: ['PSK'],
					wpa: 2,
					pair_ciphers: ['CCMP'],
					group_ciphers: ['CCMP']
				},
				bssid: '94:83:C4:12:7B:7A',
				channel: 161,
				htmodelist: {
					HT40: true,
					VHT40: true,
					VHT160: false,
					VHT20: true,
					VHT80: true,
					'VHT80+80': false,
					HT20: true
				},
				mode: 'Master',
				signal: -48,
				quality: 62,
				device: 'radio0'
			},
			{
				quality_max: 70,
				ssid: '能慧集团',
				encryption: {
					enabled: true,
					auth_algs: [],
					description: 'WPA2 PSK (CCMP)',
					wep: false,
					auth_suites: ['PSK'],
					wpa: 2,
					pair_ciphers: ['CCMP'],
					group_ciphers: ['CCMP']
				},
				bssid: '30:0D:9E:FF:3B:CD',
				channel: 36,
				htmodelist: {
					HT40: true,
					VHT40: true,
					VHT160: false,
					VHT20: true,
					VHT80: true,
					'VHT80+80': false,
					HT20: true
				},
				mode: 'Master',
				signal: -69,
				quality: 41,
				device: 'radio0'
			},
			{
				quality_max: 70,
				ssid: 'ChinaUnicom-1312',
				encryption: {
					enabled: true,
					auth_algs: [],
					description: 'mixed WPA/WPA2 PSK (CCMP)',
					wep: false,
					auth_suites: ['PSK'],
					wpa: 3,
					pair_ciphers: ['CCMP'],
					group_ciphers: ['CCMP']
				},
				bssid: '18:3C:B7:BB:76:0C',
				channel: 36,
				htmodelist: {
					HT40: true,
					VHT40: true,
					VHT160: false,
					VHT20: true,
					VHT80: true,
					'VHT80+80': false,
					HT20: true
				},
				mode: 'Master',
				signal: -75,
				quality: 35,
				device: 'radio0'
			},
			{
				htmodelist: {
					HT40: true,
					VHT40: true,
					VHT160: false,
					VHT20: true,
					VHT80: true,
					'VHT80+80': false,
					HT20: true
				},
				quality_max: 70,
				encryption: {
					enabled: true,
					auth_algs: [],
					description: 'WPA2 PSK (CCMP)',
					wep: false,
					auth_suites: ['PSK'],
					wpa: 2,
					pair_ciphers: ['CCMP'],
					group_ciphers: ['CCMP']
				},
				channel: 36,
				signal: -75,
				mode: 'Master',
				bssid: '18:3C:B7:BB:76:0E',
				quality: 35,
				device: 'radio0'
			},
			{
				quality_max: 70,
				ssid: 'YXYC3-5G',
				encryption: {
					enabled: true,
					auth_algs: [],
					description: 'mixed WPA/WPA2 PSK (CCMP)',
					wep: false,
					auth_suites: ['PSK'],
					wpa: 3,
					pair_ciphers: ['CCMP'],
					group_ciphers: ['CCMP']
				},
				bssid: 'C4:27:28:68:4F:75',
				channel: 48,
				htmodelist: {
					HT40: true,
					VHT40: true,
					VHT160: true,
					VHT20: true,
					VHT80: true,
					'VHT80+80': false,
					HT20: true
				},
				mode: 'Master',
				signal: -83,
				quality: 27,
				device: 'radio0'
			},
			{
				quality_max: 70,
				ssid: 'TP-LINK_7_F2F3',
				encryption: {
					enabled: true,
					auth_algs: [],
					description: 'mixed WPA/WPA2 PSK (TKIP, CCMP)',
					wep: false,
					auth_suites: ['PSK'],
					wpa: 3,
					pair_ciphers: ['TKIP', 'CCMP'],
					group_ciphers: ['CCMP']
				},
				bssid: '0C:4B:54:33:F2:F3',
				channel: 36,
				htmodelist: {
					HT40: true,
					VHT40: true,
					VHT160: false,
					VHT20: true,
					VHT80: true,
					'VHT80+80': false,
					HT20: true
				},
				mode: 'Master',
				signal: -84,
				quality: 26,
				device: 'radio0'
			},
			{
				quality_max: 70,
				ssid: 'TP-LINK_4_EAF2',
				encryption: {
					enabled: true,
					auth_algs: [],
					description: 'mixed WPA/WPA2 PSK (TKIP, CCMP)',
					wep: false,
					auth_suites: ['PSK'],
					wpa: 3,
					pair_ciphers: ['TKIP', 'CCMP'],
					group_ciphers: ['CCMP']
				},
				bssid: '1C:FA:68:DE:EA:F2',
				channel: 36,
				htmodelist: {
					HT40: true,
					VHT40: true,
					VHT160: false,
					VHT20: true,
					VHT80: true,
					'VHT80+80': false,
					HT20: true
				},
				mode: 'Master',
				signal: -83,
				quality: 27,
				device: 'radio0'
			},
			{
				quality_max: 70,
				ssid: 'TP-LINK_2_2830',
				encryption: {
					enabled: true,
					auth_algs: [],
					description: 'mixed WPA/WPA2 PSK (TKIP, CCMP)',
					wep: false,
					auth_suites: ['PSK'],
					wpa: 3,
					pair_ciphers: ['TKIP', 'CCMP'],
					group_ciphers: ['CCMP']
				},
				bssid: '14:E6:E4:69:28:30',
				channel: 36,
				htmodelist: {
					HT40: true,
					VHT40: true,
					VHT160: false,
					VHT20: true,
					VHT80: true,
					'VHT80+80': false,
					HT20: true
				},
				mode: 'Master',
				signal: -84,
				quality: 26,
				device: 'radio0'
			},
			{
				quality_max: 70,
				ssid: 'TP-LINK_3_D0A1',
				encryption: {
					enabled: true,
					auth_algs: [],
					description: 'mixed WPA/WPA2 PSK (TKIP, CCMP)',
					wep: false,
					auth_suites: ['PSK'],
					wpa: 3,
					pair_ciphers: ['TKIP', 'CCMP'],
					group_ciphers: ['CCMP']
				},
				bssid: 'A8:57:4E:78:D0:A1',
				channel: 36,
				htmodelist: {
					HT40: true,
					VHT40: true,
					VHT160: false,
					VHT20: true,
					VHT80: true,
					'VHT80+80': false,
					HT20: true
				},
				mode: 'Master',
				signal: -85,
				quality: 25,
				device: 'radio0'
			},
			{
				quality_max: 70,
				ssid: 'MikroTik_5g',
				encryption: {
					enabled: true,
					auth_algs: [],
					description: 'mixed WPA/WPA2 PSK (TKIP, CCMP)',
					wep: false,
					auth_suites: ['PSK'],
					wpa: 3,
					pair_ciphers: ['TKIP', 'CCMP'],
					group_ciphers: ['CCMP']
				},
				bssid: '18:FD:74:28:49:D4',
				channel: 36,
				htmodelist: {
					HT40: true,
					VHT40: true,
					VHT160: false,
					VHT20: true,
					VHT80: true,
					'VHT80+80': false,
					HT20: true
				},
				mode: 'Master',
				signal: -85,
				quality: 25,
				device: 'radio0'
			},
			{
				quality_max: 70,
				ssid: 'TP-LINK_8_AF95',
				encryption: {
					enabled: true,
					auth_algs: [],
					description: 'mixed WPA/WPA2 PSK (TKIP, CCMP)',
					wep: false,
					auth_suites: ['PSK'],
					wpa: 3,
					pair_ciphers: ['TKIP', 'CCMP'],
					group_ciphers: ['CCMP']
				},
				bssid: 'B0:4E:26:C4:AF:95',
				channel: 36,
				htmodelist: {
					HT40: true,
					VHT40: true,
					VHT160: false,
					VHT20: true,
					VHT80: true,
					'VHT80+80': false,
					HT20: true
				},
				mode: 'Master',
				signal: -85,
				quality: 25,
				device: 'radio0'
			}
		],
		radio1: [
			{
				quality_max: 70,
				ssid: 'sun',
				encryption: {
					enabled: true,
					auth_algs: [],
					description: 'WPA2 PSK (CCMP)',
					wep: false,
					auth_suites: ['PSK'],
					wpa: 2,
					pair_ciphers: ['CCMP'],
					group_ciphers: ['CCMP']
				},
				bssid: 'A0:C5:F2:B5:18:BA',
				channel: 6,
				htmodelist: {
					HT40: false,
					VHT40: false,
					VHT160: false,
					VHT20: false,
					VHT80: false,
					'VHT80+80': false,
					HT20: true
				},
				mode: 'Master',
				signal: -40,
				quality: 70
			},
			{
				quality_max: 70,
				ssid: '能慧集团',
				encryption: {
					enabled: true,
					auth_algs: [],
					description: 'WPA2 PSK (CCMP)',
					wep: false,
					auth_suites: ['PSK'],
					wpa: 2,
					pair_ciphers: ['CCMP'],
					group_ciphers: ['CCMP']
				},
				bssid: '30:0D:9E:FF:4C:D6',
				channel: 6,
				htmodelist: {
					HT40: false,
					VHT40: false,
					VHT160: false,
					VHT20: false,
					VHT80: false,
					'VHT80+80': false,
					HT20: true
				},
				mode: 'Master',
				signal: -25,
				quality: 70
			},
			{
				quality_max: 70,
				ssid: 'CU_hrhd',
				encryption: {
					enabled: true,
					auth_algs: [],
					description: 'WPA2 PSK (TKIP, CCMP)',
					wep: false,
					auth_suites: ['PSK'],
					wpa: 2,
					pair_ciphers: ['TKIP', 'CCMP'],
					group_ciphers: ['TKIP']
				},
				bssid: '80:EE:25:C4:CA:50',
				channel: 6,
				htmodelist: {
					HT40: false,
					VHT40: false,
					VHT160: false,
					VHT20: false,
					VHT80: false,
					'VHT80+80': false,
					HT20: true
				},
				mode: 'Master',
				signal: -39,
				quality: 70
			},
			{
				htmodelist: {
					HT40: true,
					VHT40: true,
					VHT160: false,
					VHT20: true,
					VHT80: false,
					'VHT80+80': false,
					HT20: true
				},
				quality_max: 70,
				encryption: {
					enabled: true,
					auth_algs: [],
					description: 'mixed WPA/WPA2 PSK (CCMP)',
					wep: false,
					auth_suites: ['PSK'],
					wpa: 3,
					pair_ciphers: ['CCMP'],
					group_ciphers: ['CCMP']
				},
				channel: 11,
				signal: -35,
				mode: 'Master',
				bssid: 'F6:2A:7D:2A:95:37',
				quality: 70
			},
			{
				quality_max: 70,
				ssid: 'GL-USB150-7e1',
				encryption: {
					enabled: true,
					auth_algs: [],
					description: 'WPA2 PSK (CCMP)',
					wep: false,
					auth_suites: ['PSK'],
					wpa: 2,
					pair_ciphers: ['CCMP'],
					group_ciphers: ['CCMP']
				},
				bssid: 'E6:95:6E:4E:87:E1',
				channel: 11,
				htmodelist: {
					HT40: true,
					VHT40: false,
					VHT160: false,
					VHT20: false,
					VHT80: false,
					'VHT80+80': false,
					HT20: true
				},
				mode: 'Master',
				signal: -29,
				quality: 70
			},
			{
				quality_max: 70,
				ssid: 'AJAX',
				encryption: {
					enabled: true,
					auth_algs: [],
					description: 'mixed WPA/WPA2 PSK (CCMP)',
					wep: false,
					auth_suites: ['PSK'],
					wpa: 3,
					pair_ciphers: ['CCMP'],
					group_ciphers: ['CCMP']
				},
				bssid: '80:EA:07:E9:23:DC',
				channel: 11,
				htmodelist: {
					HT40: true,
					VHT40: true,
					VHT160: false,
					VHT20: true,
					VHT80: false,
					'VHT80+80': false,
					HT20: true
				},
				mode: 'Master',
				signal: -22,
				quality: 70
			},
			{
				quality_max: 70,
				ssid: 'AJAX',
				encryption: {
					enabled: true,
					auth_algs: [],
					description: 'mixed WPA/WPA2 PSK (CCMP)',
					wep: false,
					auth_suites: ['PSK'],
					wpa: 3,
					pair_ciphers: ['CCMP'],
					group_ciphers: ['CCMP']
				},
				bssid: '18:F2:2C:8C:0C:2E',
				channel: 11,
				htmodelist: {
					HT40: true,
					VHT40: true,
					VHT160: false,
					VHT20: true,
					VHT80: false,
					'VHT80+80': false,
					HT20: true
				},
				mode: 'Master',
				signal: -38,
				quality: 70
			},
			{
				quality_max: 70,
				ssid: 'AJAX',
				encryption: {
					enabled: true,
					auth_algs: [],
					description: 'mixed WPA/WPA2 PSK (CCMP)',
					wep: false,
					auth_suites: ['PSK'],
					wpa: 3,
					pair_ciphers: ['CCMP'],
					group_ciphers: ['CCMP']
				},
				bssid: 'F4:2A:7D:2A:95:37',
				channel: 11,
				htmodelist: {
					HT40: true,
					VHT40: true,
					VHT160: false,
					VHT20: true,
					VHT80: false,
					'VHT80+80': false,
					HT20: true
				},
				mode: 'Master',
				signal: -34,
				quality: 70
			},
			{
				quality_max: 70,
				ssid: 'DIRECT-80-Mi All-in-One Inkjet',
				encryption: {
					enabled: true,
					auth_algs: [],
					description: 'WPA2 PSK (CCMP)',
					wep: false,
					auth_suites: ['PSK'],
					wpa: 2,
					pair_ciphers: ['CCMP'],
					group_ciphers: ['CCMP']
				},
				bssid: '84:69:93:B8:FA:81',
				channel: 11,
				htmodelist: {
					HT40: false,
					VHT40: false,
					VHT160: false,
					VHT20: false,
					VHT80: false,
					'VHT80+80': false,
					HT20: true
				},
				mode: 'Master',
				signal: -49,
				quality: 61
			},
			{
				htmodelist: {
					HT40: true,
					VHT40: true,
					VHT160: false,
					VHT20: true,
					VHT80: false,
					'VHT80+80': false,
					HT20: true
				},
				quality_max: 70,
				encryption: {
					enabled: true,
					auth_algs: [],
					description: 'mixed WPA/WPA2 PSK (CCMP)',
					wep: false,
					auth_suites: ['PSK'],
					wpa: 3,
					pair_ciphers: ['CCMP'],
					group_ciphers: ['CCMP']
				},
				channel: 11,
				signal: -17,
				mode: 'Master',
				bssid: '82:EA:07:E9:23:DC',
				quality: 70
			},
			{
				quality_max: 70,
				ssid: 'B1300-9b4',
				encryption: {
					enabled: true,
					auth_algs: [],
					description: 'mixed WPA/WPA2 PSK (TKIP, CCMP)',
					wep: false,
					auth_suites: ['PSK'],
					wpa: 3,
					pair_ciphers: ['TKIP', 'CCMP'],
					group_ciphers: ['TKIP']
				},
				bssid: '94:83:C4:03:79:B4',
				channel: 11,
				htmodelist: {
					HT40: true,
					VHT40: true,
					VHT160: false,
					VHT20: true,
					VHT80: false,
					'VHT80+80': false,
					HT20: true
				},
				mode: 'Master',
				signal: -36,
				quality: 70
			},
			{
				quality_max: 70,
				ssid: 'OrayBox-1C7C',
				encryption: {
					enabled: true,
					auth_algs: [],
					description: 'WPA2 PSK (CCMP)',
					wep: false,
					auth_suites: ['PSK'],
					wpa: 2,
					pair_ciphers: ['CCMP'],
					group_ciphers: ['CCMP']
				},
				bssid: 'A0:C5:F2:B5:1C:7C',
				channel: 6,
				htmodelist: {
					HT40: false,
					VHT40: false,
					VHT160: false,
					VHT20: false,
					VHT80: false,
					'VHT80+80': false,
					HT20: true
				},
				mode: 'Master',
				signal: -38,
				quality: 70
			},
			{
				htmodelist: {
					HT40: true,
					VHT40: true,
					VHT160: false,
					VHT20: true,
					VHT80: false,
					'VHT80+80': false,
					HT20: true
				},
				quality_max: 70,
				encryption: {
					enabled: true,
					auth_algs: [],
					description: 'mixed WPA/WPA2 PSK (CCMP)',
					wep: false,
					auth_suites: ['PSK'],
					wpa: 3,
					pair_ciphers: ['CCMP'],
					group_ciphers: ['CCMP']
				},
				channel: 11,
				signal: -36,
				mode: 'Master',
				bssid: '1A:F2:2C:AC:0C:2E',
				quality: 70
			},
			{
				htmodelist: {
					HT40: true,
					VHT40: false,
					VHT160: false,
					VHT20: false,
					VHT80: false,
					'VHT80+80': false,
					HT20: true
				},
				quality_max: 70,
				encryption: {
					enabled: true,
					auth_algs: [],
					description: 'WPA2 PSK (CCMP)',
					wep: false,
					auth_suites: ['PSK'],
					wpa: 2,
					pair_ciphers: ['CCMP'],
					group_ciphers: ['CCMP']
				},
				channel: 11,
				signal: -35,
				mode: 'Master',
				bssid: '94:83:C4:0D:A2:48',
				quality: 70
			},
			{
				quality_max: 70,
				ssid: 'CU_97e3',
				encryption: {
					enabled: true,
					auth_algs: [],
					description: 'WPA2 PSK (TKIP, CCMP)',
					wep: false,
					auth_suites: ['PSK'],
					wpa: 2,
					pair_ciphers: ['TKIP', 'CCMP'],
					group_ciphers: ['TKIP']
				},
				bssid: '28:C0:1B:16:0A:2E',
				channel: 6,
				htmodelist: {
					HT40: false,
					VHT40: false,
					VHT160: false,
					VHT20: false,
					VHT80: false,
					'VHT80+80': false,
					HT20: true
				},
				mode: 'Master',
				signal: -58,
				quality: 52
			},
			{
				quality_max: 70,
				ssid: 'MT300N-V2-7ae',
				encryption: {
					enabled: true,
					auth_algs: [],
					description: 'mixed WPA/WPA2 PSK (CCMP)',
					wep: false,
					auth_suites: ['PSK'],
					wpa: 3,
					pair_ciphers: ['CCMP'],
					group_ciphers: ['CCMP']
				},
				bssid: '94:83:C4:07:A7:AE',
				channel: 6,
				htmodelist: {
					HT40: false,
					VHT40: false,
					VHT160: false,
					VHT20: false,
					VHT80: false,
					'VHT80+80': false,
					HT20: true
				},
				mode: 'Master',
				signal: -40,
				quality: 70
			},
			{
				quality_max: 70,
				ssid: '能慧集团',
				encryption: {
					enabled: true,
					auth_algs: [],
					description: 'WPA2 PSK (CCMP)',
					wep: false,
					auth_suites: ['PSK'],
					wpa: 2,
					pair_ciphers: ['CCMP'],
					group_ciphers: ['CCMP']
				},
				bssid: '30:0D:9E:FF:3B:CC',
				channel: 6,
				htmodelist: {
					HT40: false,
					VHT40: false,
					VHT160: false,
					VHT20: false,
					VHT80: false,
					'VHT80+80': false,
					HT20: true
				},
				mode: 'Master',
				signal: -35,
				quality: 70
			},
			{
				quality_max: 70,
				ssid: 'CU_bkre',
				encryption: {
					enabled: true,
					auth_algs: [],
					description: 'WPA2 PSK (TKIP, CCMP)',
					wep: false,
					auth_suites: ['PSK'],
					wpa: 2,
					pair_ciphers: ['TKIP', 'CCMP'],
					group_ciphers: ['TKIP']
				},
				bssid: '68:1A:A4:22:FF:0A',
				channel: 9,
				htmodelist: {
					HT40: false,
					VHT40: false,
					VHT160: false,
					VHT20: true,
					VHT80: false,
					'VHT80+80': false,
					HT20: true
				},
				mode: 'Master',
				signal: -28,
				quality: 70
			},
			{
				quality_max: 70,
				ssid: '能慧集团',
				encryption: {
					enabled: true,
					auth_algs: [],
					description: 'WPA2 PSK (CCMP)',
					wep: false,
					auth_suites: ['PSK'],
					wpa: 2,
					pair_ciphers: ['CCMP'],
					group_ciphers: ['CCMP']
				},
				bssid: '30:0D:9E:FF:4C:F1',
				channel: 1,
				htmodelist: {
					HT40: false,
					VHT40: false,
					VHT160: false,
					VHT20: false,
					VHT80: false,
					'VHT80+80': false,
					HT20: true
				},
				mode: 'Master',
				signal: -33,
				quality: 70
			},
			{
				htmodelist: {
					HT40: true,
					VHT40: false,
					VHT160: false,
					VHT20: false,
					VHT80: false,
					'VHT80+80': false,
					HT20: true
				},
				quality_max: 70,
				encryption: {
					enabled: true,
					auth_algs: [],
					description: 'WPA2 PSK (CCMP)',
					wep: false,
					auth_suites: ['PSK'],
					wpa: 2,
					pair_ciphers: ['CCMP'],
					group_ciphers: ['CCMP']
				},
				channel: 1,
				signal: -47,
				mode: 'Master',
				bssid: '18:3C:B7:BB:76:0D',
				quality: 63
			},
			{
				quality_max: 70,
				ssid: 'ChinaUnicom-1312',
				encryption: {
					enabled: true,
					auth_algs: [],
					description: 'mixed WPA/WPA2 PSK (CCMP)',
					wep: false,
					auth_suites: ['PSK'],
					wpa: 3,
					pair_ciphers: ['CCMP'],
					group_ciphers: ['CCMP']
				},
				bssid: '18:3C:B7:BB:76:08',
				channel: 1,
				htmodelist: {
					HT40: true,
					VHT40: false,
					VHT160: false,
					VHT20: false,
					VHT80: false,
					'VHT80+80': false,
					HT20: true
				},
				mode: 'Master',
				signal: -46,
				quality: 64
			},
			{
				quality_max: 70,
				ssid: 'YXYC3',
				encryption: {
					enabled: true,
					auth_algs: [],
					description: 'mixed WPA/WPA2 PSK (CCMP)',
					wep: false,
					auth_suites: ['PSK'],
					wpa: 3,
					pair_ciphers: ['CCMP'],
					group_ciphers: ['CCMP']
				},
				bssid: 'C4:27:28:68:4F:74',
				channel: 3,
				htmodelist: {
					HT40: false,
					VHT40: false,
					VHT160: false,
					VHT20: true,
					VHT80: false,
					'VHT80+80': false,
					HT20: true
				},
				mode: 'Master',
				signal: -46,
				quality: 64
			},
			{
				encryption: {
					enabled: true,
					auth_algs: [],
					description: 'mixed WPA/WPA2 PSK (TKIP, CCMP)',
					wep: false,
					auth_suites: ['PSK'],
					wpa: 3,
					pair_ciphers: ['TKIP', 'CCMP'],
					group_ciphers: ['TKIP']
				},
				quality_max: 70,
				ssid: 'EZVIZ_F44265850',
				channel: 1,
				signal: -43,
				bssid: '2C:D2:6B:C8:A0:73',
				mode: 'Master',
				quality: 67
			},
			{
				quality_max: 70,
				ssid: '能慧集团办公室',
				encryption: {
					enabled: true,
					auth_algs: [],
					description: 'mixed WPA/WPA2 PSK (TKIP, CCMP)',
					wep: false,
					auth_suites: ['PSK'],
					wpa: 3,
					pair_ciphers: ['TKIP', 'CCMP'],
					group_ciphers: ['TKIP']
				},
				bssid: '30:0D:9E:FF:47:B4',
				channel: 1,
				htmodelist: {
					HT40: false,
					VHT40: false,
					VHT160: false,
					VHT20: false,
					VHT80: false,
					'VHT80+80': false,
					HT20: true
				},
				mode: 'Master',
				signal: -27,
				quality: 70
			},
			{
				quality_max: 70,
				ssid: 'bbc',
				encryption: {
					enabled: true,
					auth_algs: [],
					description: 'mixed WPA/WPA2 PSK (TKIP, CCMP)',
					wep: false,
					auth_suites: ['PSK'],
					wpa: 3,
					pair_ciphers: ['TKIP', 'CCMP'],
					group_ciphers: ['TKIP']
				},
				bssid: '94:83:C4:03:7B:BC',
				channel: 1,
				htmodelist: {
					HT40: true,
					VHT40: true,
					VHT160: false,
					VHT20: true,
					VHT80: false,
					'VHT80+80': false,
					HT20: true
				},
				mode: 'Master',
				signal: -41,
				quality: 69
			},
			{
				quality_max: 70,
				ssid: 'ChinaNet-y4x4',
				encryption: {
					enabled: true,
					auth_algs: [],
					description: 'mixed WPA/WPA2 PSK (TKIP, CCMP)',
					wep: false,
					auth_suites: ['PSK'],
					wpa: 3,
					pair_ciphers: ['TKIP', 'CCMP'],
					group_ciphers: ['TKIP']
				},
				bssid: '9A:00:74:C9:67:76',
				channel: 1,
				htmodelist: {
					HT40: false,
					VHT40: false,
					VHT160: false,
					VHT20: false,
					VHT80: false,
					'VHT80+80': false,
					HT20: true
				},
				mode: 'Master',
				signal: -56,
				quality: 54
			},
			{
				quality_max: 70,
				ssid: 'Xiaomi_5AE7',
				encryption: {
					enabled: true,
					auth_algs: [],
					description: 'mixed WPA/WPA2 PSK (TKIP, CCMP)',
					wep: false,
					auth_suites: ['PSK'],
					wpa: 3,
					pair_ciphers: ['TKIP', 'CCMP'],
					group_ciphers: ['TKIP']
				},
				bssid: '28:6C:07:CB:5A:E8',
				channel: 2,
				htmodelist: {
					HT40: false,
					VHT40: false,
					VHT160: false,
					VHT20: false,
					VHT80: false,
					'VHT80+80': false,
					HT20: true
				},
				mode: 'Master',
				signal: -32,
				quality: 70
			},
			{
				quality_max: 70,
				ssid: '能慧集团',
				encryption: {
					enabled: true,
					auth_algs: [],
					description: 'WPA2 PSK (CCMP)',
					wep: false,
					auth_suites: ['PSK'],
					wpa: 2,
					pair_ciphers: ['CCMP'],
					group_ciphers: ['CCMP']
				},
				bssid: '30:0D:9E:FF:4C:EE',
				channel: 1,
				htmodelist: {
					HT40: false,
					VHT40: false,
					VHT160: false,
					VHT20: false,
					VHT80: false,
					'VHT80+80': false,
					HT20: true
				},
				mode: 'Master',
				signal: -37,
				quality: 70
			},
			{
				quality_max: 70,
				ssid: 'YXYC2',
				encryption: {
					enabled: true,
					auth_algs: [],
					description: 'mixed WPA/WPA2 PSK (CCMP)',
					wep: false,
					auth_suites: ['PSK'],
					wpa: 3,
					pair_ciphers: ['CCMP'],
					group_ciphers: ['CCMP']
				},
				bssid: 'C4:27:28:68:4F:78',
				channel: 3,
				htmodelist: {
					HT40: false,
					VHT40: false,
					VHT160: false,
					VHT20: true,
					VHT80: false,
					'VHT80+80': false,
					HT20: true
				},
				mode: 'Master',
				signal: -39,
				quality: 70
			},
			{
				htmodelist: {
					HT40: true,
					VHT40: false,
					VHT160: false,
					VHT20: false,
					VHT80: false,
					'VHT80+80': false,
					HT20: true
				},
				quality_max: 70,
				encryption: {
					enabled: true,
					auth_algs: [],
					description: 'WPA2 PSK (CCMP)',
					wep: false,
					auth_suites: ['PSK'],
					wpa: 2,
					pair_ciphers: ['CCMP'],
					group_ciphers: ['CCMP']
				},
				channel: 6,
				signal: -66,
				mode: 'Master',
				bssid: '74:C1:4F:FA:4A:4D',
				quality: 44
			}
		]
	};
	Object.keys(test).map((key) => {
		for (const i of test[key]) {
			if (i.ssid) {
				i.device = key;
				wifiList.value.push(i);
			}
		}
	});
}
onBeforeMount(() => {
	if (route.query.action === 'scan') {
		console.log('-------------');
		proxy.$timer.create('scanlist', scanlist, {repeat: false, immediate: true, time: 30000});
		// test();
	} else if (route.query.action === 'check') {
		console.log('-------1111111111------');
		proxy.$timer.create('historylist', getHistoryList, {repeat: false, immediate: true, time: 2000});
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
