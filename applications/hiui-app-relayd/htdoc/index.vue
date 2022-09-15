<template>
	<n-page-header @back="handleBack" class="components-bg pd-30">
		<template #title>
			{{ $t('Relayd Settings') }}
		</template>
		<n-space v-if="route.query.action === 'check'" vertical class="pd-20 components-bg">
			<n-space justify="space-between" class="pd-0-15">
				{{ $t('History connect network') }}
				<n-space :size="35">
					<div>{{ $t('enable network') }}</div>
					<div>{{ $t('operation') }}</div>
				</n-space>
			</n-space>
			<n-list bordered>
				<n-space vertical>
					<n-list-item v-for="(item, index) in historyList" :key="index" class="bg">
						<n-space justify="space-between" align="center">
							<n-space>
								<n-icon size="24" :component="MdWifi"></n-icon>
								<span>{{ item.ssid }}</span>
							</n-space>
							<n-space>
								<n-switch v-model:value="item.auto" size="medium" />
								<n-button text v-if="cur == 'offline'" @click="delClient(item)">
									<n-icon size="18"><DeleteFilled /></n-icon>
								</n-button>
							</n-space>
						</n-space>
					</n-list-item>
				</n-space>
			</n-list>
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
							<n-space>
								<n-icon size="24" :component="MdWifi"></n-icon>
								<span>{{ item.ssid }}</span>
							</n-space>
							<div>
								<n-switch v-model:value="item.auto" size="medium" @update:value="handleChange(item)" />
							</div>
						</n-space>
					</n-list-item>
				</n-space>
			</n-list>
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
const dialog = useDialog();
const wifiList = ref([
	{
		encryption: {enabled: true, auth_algs: {}, description: 'mixed WPA/WPA2 PSK (TKIP, CCMP)', wep: false, auth_suites: ['PSK'], wpa: 3, pair_ciphers: ['TKIP', 'CCMP'], group_ciphers: ['TKIP']},
		quality_max: 70,
		ssid: 'EZVIZ_F44265850',
		channel: 1,
		signal: -60,
		bssid: '2C:D2:6B:C8:A0:73',
		mode: 'Master',
		quality: 50
	},
	{
		encryption: {enabled: true, auth_algs: {}, description: 'WPA2 PSK (CCMP)', wep: false, auth_suites: ['PSK'], wpa: 2, pair_ciphers: ['CCMP'], group_ciphers: ['CCMP']},
		quality_max: 70,
		ssid: '能慧集团',
		channel: 1,
		signal: -44,
		bssid: '30:0D:9E:FF:4C:F1',
		mode: 'Master',
		quality: 66
	},
	{
		encryption: {enabled: true, auth_algs: {}, description: 'mixed WPA/WPA2 PSK (TKIP, CCMP)', wep: false, auth_suites: ['PSK'], wpa: 3, pair_ciphers: ['TKIP', 'CCMP'], group_ciphers: ['TKIP']},
		quality_max: 70,
		ssid: 'Xiaomi_5AE7',
		channel: 2,
		signal: -56,
		bssid: '28:6C:07:CB:5A:E8',
		mode: 'Master',
		quality: 54
	},
	{
		encryption: {enabled: true, auth_algs: {}, description: 'mixed WPA/WPA2 PSK (CCMP)', wep: false, auth_suites: ['PSK'], wpa: 3, pair_ciphers: ['CCMP'], group_ciphers: ['CCMP']},
		quality_max: 70,
		ssid: 'YXYC2',
		channel: 3,
		signal: -53,
		bssid: 'C4:27:28:68:4F:78',
		mode: 'Master',
		quality: 57
	},
	{
		encryption: {enabled: true, auth_algs: {}, description: 'WPA2 PSK (TKIP, CCMP)', wep: false, auth_suites: ['PSK'], wpa: 2, pair_ciphers: ['TKIP', 'CCMP'], group_ciphers: ['TKIP']},
		quality_max: 70,
		ssid: 'CU_hrhd',
		channel: 6,
		signal: -3,
		bssid: '80:EE:25:C4:CA:50',
		mode: 'Master',
		quality: 70
	},
	{
		encryption: {enabled: true, auth_algs: {}, description: 'WPA2 PSK (CCMP)', wep: false, auth_suites: ['PSK'], wpa: 2, pair_ciphers: ['CCMP'], group_ciphers: ['CCMP']},
		quality_max: 70,
		ssid: '能慧集团',
		channel: 6,
		signal: -52,
		bssid: '30:0D:9E:FF:3B:CC',
		mode: 'Master',
		quality: 58
	},
	{
		encryption: {enabled: true, auth_algs: {}, description: 'WPA2 PSK (TKIP, CCMP)', wep: false, auth_suites: ['PSK'], wpa: 2, pair_ciphers: ['TKIP', 'CCMP'], group_ciphers: ['TKIP']},
		quality_max: 70,
		ssid: 'CU_97e3',
		channel: 6,
		signal: -49,
		bssid: '28:C0:1B:16:0A:2E',
		mode: 'Master',
		quality: 61
	},
	{
		encryption: {enabled: true, auth_algs: {}, description: 'WPA2 PSK (CCMP)', wep: false, auth_suites: ['PSK'], wpa: 2, pair_ciphers: ['CCMP'], group_ciphers: ['CCMP']},
		quality_max: 70,
		ssid: '能慧集团',
		channel: 6,
		signal: -44,
		bssid: '30:0D:9E:FF:4C:D6',
		mode: 'Master',
		quality: 66
	},
	{
		encryption: {enabled: true, auth_algs: {}, description: 'WPA2 PSK (CCMP)', wep: false, auth_suites: ['PSK'], wpa: 2, pair_ciphers: ['CCMP'], group_ciphers: ['CCMP']},
		quality_max: 70,
		ssid: 'sun',
		channel: 6,
		signal: -51,
		bssid: 'A0:C5:F2:B5:18:BA',
		mode: 'Master',
		quality: 59
	},
	{
		encryption: {enabled: true, auth_algs: {}, description: 'WPA2 PSK (CCMP)', wep: false, auth_suites: ['PSK'], wpa: 2, pair_ciphers: ['CCMP'], group_ciphers: ['CCMP']},
		quality_max: 70,
		ssid: 'OrayBox-1C7C',
		channel: 6,
		signal: -38,
		bssid: 'A0:C5:F2:B5:1C:7C',
		mode: 'Master',
		quality: 70
	},
	{
		encryption: {enabled: true, auth_algs: {}, description: 'mixed WPA/WPA2 PSK (CCMP)', wep: false, auth_suites: ['PSK'], wpa: 3, pair_ciphers: ['CCMP'], group_ciphers: ['CCMP']},
		quality_max: 70,
		ssid: 'MT300N-V2-7ae',
		channel: 6,
		signal: -50,
		bssid: '94:83:C4:07:A7:AE',
		mode: 'Master',
		quality: 60
	},
	{
		encryption: {enabled: true, auth_algs: {}, description: 'WPA2 PSK (TKIP, CCMP)', wep: false, auth_suites: ['PSK'], wpa: 2, pair_ciphers: ['TKIP', 'CCMP'], group_ciphers: ['TKIP']},
		quality_max: 70,
		ssid: 'CU_iTV_SSID2',
		channel: 9,
		signal: -59,
		bssid: '6A:1A:A4:12:FF:0A',
		mode: 'Master',
		quality: 51
	},
	{
		encryption: {enabled: true, auth_algs: {}, description: 'mixed WPA/WPA2 PSK (CCMP)', wep: false, auth_suites: ['PSK'], wpa: 3, pair_ciphers: ['CCMP'], group_ciphers: ['CCMP']},
		quality_max: 70,
		ssid: 'AJAX',
		channel: 11,
		signal: -40,
		bssid: 'F4:2A:7D:2A:95:37',
		mode: 'Master',
		quality: 70
	},
	{
		encryption: {enabled: true, auth_algs: {}, description: 'mixed WPA/WPA2 PSK (CCMP)', wep: false, auth_suites: ['PSK'], wpa: 3, pair_ciphers: ['CCMP'], group_ciphers: ['CCMP']},
		quality_max: 70,
		ssid: 'AJAX',
		channel: 11,
		signal: -41,
		bssid: '80:EA:07:E9:23:DC',
		mode: 'Master',
		quality: 69
	},
	{
		encryption: {enabled: true, auth_algs: {}, description: 'WPA2 PSK (CCMP)', wep: false, auth_suites: ['PSK'], wpa: 2, pair_ciphers: ['CCMP'], group_ciphers: ['CCMP']},
		quality_max: 70,
		ssid: 'GL-AR750S-29a',
		channel: 11,
		signal: -50,
		bssid: '96:83:C4:06:12:9A',
		mode: 'Master',
		quality: 60
	},
	{
		encryption: {enabled: true, auth_algs: {}, description: 'WPA2 PSK (CCMP)', wep: false, auth_suites: ['PSK'], wpa: 2, pair_ciphers: ['CCMP'], group_ciphers: ['CCMP']},
		quality_max: 70,
		ssid: 'GL-AR750S-248',
		channel: 11,
		signal: -53,
		bssid: '94:83:C4:0D:A2:48',
		mode: 'Master',
		quality: 57
	},
	{
		encryption: {enabled: true, auth_algs: {}, description: 'WPA2 PSK (CCMP)', wep: false, auth_suites: ['PSK'], wpa: 2, pair_ciphers: ['CCMP'], group_ciphers: ['CCMP']},
		quality_max: 70,
		ssid: 'DIRECT-80-Mi All-in-One Inkjet',
		channel: 11,
		signal: -41,
		bssid: '84:69:93:B8:FA:81',
		mode: 'Master',
		quality: 69
	},
	{
		quality_max: 70,
		encryption: {enabled: true, auth_algs: {}, description: 'mixed WPA/WPA2 PSK (CCMP)', wep: false, auth_suites: ['PSK'], wpa: 3, pair_ciphers: ['CCMP'], group_ciphers: ['CCMP']},
		channel: 11,
		signal: -39,
		mode: 'Master',
		bssid: '82:EA:07:E9:23:DC',
		quality: 70
	},
	{
		encryption: {enabled: true, auth_algs: {}, description: 'mixed WPA/WPA2 PSK (CCMP)', wep: false, auth_suites: ['PSK'], wpa: 3, pair_ciphers: ['CCMP'], group_ciphers: ['CCMP']},
		quality_max: 70,
		ssid: 'AJAX',
		channel: 11,
		signal: -46,
		bssid: '18:F2:2C:8C:0C:2E',
		mode: 'Master',
		quality: 64
	},
	{
		quality_max: 70,
		encryption: {enabled: true, auth_algs: {}, description: 'mixed WPA/WPA2 PSK (CCMP)', wep: false, auth_suites: ['PSK'], wpa: 3, pair_ciphers: ['CCMP'], group_ciphers: ['CCMP']},
		channel: 11,
		signal: -46,
		mode: 'Master',
		bssid: '1A:F2:2C:AC:0C:2E',
		quality: 64
	},
	{
		encryption: {enabled: true, auth_algs: {}, description: 'mixed WPA/WPA2 PSK (CCMP)', wep: false, auth_suites: ['PSK'], wpa: 3, pair_ciphers: ['CCMP'], group_ciphers: ['CCMP']},
		quality_max: 70,
		ssid: 'YXYC3',
		channel: 3,
		signal: -65,
		bssid: 'C4:27:28:68:4F:74',
		mode: 'Master',
		quality: 45
	},
	{
		encryption: {enabled: true, auth_algs: {}, description: 'WPA2 PSK (CCMP)', wep: false, auth_suites: ['PSK'], wpa: 2, pair_ciphers: ['CCMP'], group_ciphers: ['CCMP']},
		quality_max: 70,
		ssid: '能慧集团',
		channel: 1,
		signal: -52,
		bssid: '30:0D:9E:FF:4C:EE',
		mode: 'Master',
		quality: 58
	},
	{
		encryption: {enabled: true, auth_algs: {}, description: 'mixed WPA/WPA2 PSK (TKIP, CCMP)', wep: false, auth_suites: ['PSK'], wpa: 3, pair_ciphers: ['TKIP', 'CCMP'], group_ciphers: ['TKIP']},
		quality_max: 70,
		ssid: '能慧集团办公室',
		channel: 1,
		signal: -59,
		bssid: '30:0D:9E:FF:47:B4',
		mode: 'Master',
		quality: 51
	},
	{
		quality_max: 70,
		encryption: {enabled: true, auth_algs: {}, description: 'WPA2 PSK (CCMP)', wep: false, auth_suites: ['PSK'], wpa: 2, pair_ciphers: ['CCMP'], group_ciphers: ['CCMP']},
		channel: 1,
		signal: -63,
		mode: 'Master',
		bssid: '18:3C:B7:BB:76:0D',
		quality: 47
	},
	{
		encryption: {enabled: true, auth_algs: {}, description: 'mixed WPA/WPA2 PSK (TKIP, CCMP)', wep: false, auth_suites: ['PSK'], wpa: 3, pair_ciphers: ['TKIP', 'CCMP'], group_ciphers: ['TKIP']},
		quality_max: 70,
		ssid: 'bbc',
		channel: 1,
		signal: -51,
		bssid: '94:83:C4:03:7B:BC',
		mode: 'Master',
		quality: 59
	},
	{
		encryption: {enabled: true, auth_algs: {}, description: 'WPA2 PSK (CCMP)', wep: false, auth_suites: ['PSK'], wpa: 2, pair_ciphers: ['CCMP'], group_ciphers: ['CCMP']},
		quality_max: 70,
		ssid: 'GL-USB150-7e1',
		channel: 11,
		signal: -48,
		bssid: 'E6:95:6E:4E:87:E1',
		mode: 'Master',
		quality: 62
	},
	{
		quality_max: 70,
		encryption: {enabled: false, auth_algs: {}, description: 'None', wep: false, auth_suites: {}, wpa: 0, pair_ciphers: {}, group_ciphers: {}},
		channel: 1,
		signal: -76,
		mode: 'Master',
		bssid: 'F4:74:88:3A:F3:B2',
		quality: 34
	},
	{
		encryption: {enabled: true, auth_algs: {}, description: 'mixed WPAWPA2 PSK (CCMP)', wep: false, auth_suites: ['PSK'], wpa: 3, pair_ciphers: ['CCMP'], group_ciphers: ['CCMP']},
		quality_max: 70,
		ssid: 'ChinaUnicom-1312',
		channel: 1,
		signal: -61,
		bssid: '18:3C:B7:BB:76:08',
		mode: 'Master',
		quality: 49
	},
	{
		quality_max: 70,
		encryption: {enabled: true, auth_algs: {}, description: 'WPA2 PSK (CCMP)', wep: false, auth_suites: ['PSK'], wpa: 2, pair_ciphers: ['CCMP'], group_ciphers: ['CCMP']},
		channel: 1,
		signal: -71,
		mode: 'Master',
		bssid: '18:3C:B7:BB:76:51',
		quality: 39
	},
	{
		encryption: {enabled: true, auth_algs: {}, description: 'mixed WPA/WPA2 PSK (TKIP, CCMP)', wep: false, auth_suites: ['PSK'], wpa: 3, pair_ciphers: ['TKIP', 'CCMP'], group_ciphers: ['TKIP']},
		quality_max: 70,
		ssid: 'CMCC-ck33',
		channel: 4,
		signal: -77,
		bssid: '18:7C:AA:F3:48:BF',
		mode: 'Master',
		quality: 33
	},
	{
		quality_max: 70,
		encryption: {enabled: true, auth_algs: {}, description: 'WPA2 PSK (CCMP)', wep: false, auth_suites: ['PSK'], wpa: 2, pair_ciphers: ['CCMP'], group_ciphers: ['CCMP']},
		channel: 6,
		signal: -76,
		mode: 'Master',
		bssid: '74:C1:4F:FA:4A:4D',
		quality: 34
	},
	{
		encryption: {enabled: true, auth_algs: {}, description: 'mixed WPA/WPA2 PSK (CCMP)', wep: false, auth_suites: ['PSK'], wpa: 3, pair_ciphers: ['CCMP'], group_ciphers: ['CCMP']},
		quality_max: 70,
		ssid: 'Gxprtz',
		channel: 6,
		signal: -77,
		bssid: '74:C1:4F:FA:4A:48',
		mode: 'Master',
		quality: 33
	},
	{
		encryption: {enabled: true, auth_algs: {}, description: 'WPA2 PSK (CCMP)', wep: false, auth_suites: ['PSK'], wpa: 2, pair_ciphers: ['CCMP'], group_ciphers: ['CCMP']},
		quality_max: 70,
		ssid: 'DIRECT-EC-HP DeskJet 2700 series',
		channel: 13,
		signal: -73,
		bssid: 'C0:18:03:12:D0:ED',
		mode: 'Master',
		quality: 37
	}
]);
const remember = ref(true);
const password = ref('');
let curItem;
const historyList = ref([]);
const {proxy} = getCurrentInstance();
const {autoConnect} = ref(false);
const showModal = ref(false);
const modalTitle = ref('');
const route = useRoute();
console.log(route.query.action);

function handleBack() {
	console.log('2222222');
}

function handleChange(item) {
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

function removeWifi() {
	dialog.warning({
		title: '警告',
		content: '你确定？',
		positiveText: '确定',
		negativeText: '不确定',
		onPositiveClick: () => {
			console.log('1');
		},
		onNegativeClick: () => {
			console.log('2');
		}
	});
}

function scanlist() {
	proxy.$hiui.call('relayd', 'scan').then(({result}) => {
		Object.keys(result).map((key) => {
			result[key].forEach((item) => {
				item.device = key;
			});
			wifiList.value.push.apply(...result[key]);
		});
	});
}

onBeforeMount(() => {
	if (route.query.action === 'scan') {
		proxy.$timer.create('scanlist', scanlist, {repeat: true, immediate: true, time: 5000});
	}
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
