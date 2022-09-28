<template>
	<n-list class="width-fill pd-30" :show-divider="false">
		<template #header>
			<n-space justify="space-between">
				<n-space class="font-18" align="center">
					<div class="circle"></div>
					{{ title }}
				</n-space>
				<n-space align="center">
					<div>{{ $t('Enable wifi') }}</div>
					<n-switch v-model:value="iface.enable" size="medium" @update:value="handleUpdateValue('enable')" />
				</n-space>
			</n-space>
		</template>
		<n-list-item>
			<n-input v-model:value="iface.ssid" type="text" @update:value="handleUpdateValue('ssid')">
				<template #suffix>
					<div style="padding: 0 24px 0 0; color: #98a3b7">{{ $t('name') }}</div>
				</template>
			</n-input>
		</n-list-item>
		<n-list-item>
			<n-space justify="end" align="center" class="des">{{ $t('Encryption') }}</n-space>
			<n-select v-model:value="iface.encryption" :options="encryptions" @update:value="handleUpdateValue('encryption')"></n-select>
		</n-list-item>
		<n-list-item>
			<n-input v-model:value="iface.key" type="password" show-password-on="mousedown" :minlenght="8" @update:value="handleUpdateValue('key')">
				<template #suffix>
					<div style="padding: 0 8px 0 0; color: #98a3b7">{{ $t('password') }}</div>
				</template>
			</n-input>
		</n-list-item>
		<n-list-item>
			<n-space justify="end" align="center" class="des">{{ $t('Model') }}</n-space>
			<n-select v-model:value="device.hwmode" :options="hwmodelist" @update:value="handleUpdateValue('hwmode')" />
		</n-list-item>
		<n-list-item>
			<n-space justify="end" align="center" class="des">{{ $t('Bandwidth') }}</n-space>
			<n-select v-model:value="device.htmode" :options="htmodelist" @update:value="handleUpdateValue('htmode')" />
		</n-list-item>
		<n-list-item>
			<n-space justify="end" align="center" class="des">{{ $t('Channel') }}</n-space>
			<n-select v-model:value="device.channel" :options="channels" @update:value="handleUpdateValue('channel')" />
		</n-list-item>
		<n-list-item>
			<n-space justify="end" align="center" class="des">{{ $t('Launch power (dBm)') }}</n-space>
			<n-select v-model:value="device.txpower" :options="txpwrlist" @update:value="handleUpdateValue('txpower')" />
		</n-list-item>
		<n-list-item>
			<n-space justify="space-between" align="center">
				<n-checkbox v-model:checked="iface.hidden" @update:checked="handleUpdateValue('hidden')">{{ $t('Hidden network is not found') }}</n-checkbox>
				<n-space>
					<n-button type="text" ghost @click="channelOptimize">{{ $t('Channel optimization') }}</n-button>
					<n-button type="info" round size="medium" @click="updateConfig">{{ $t('save') }}</n-button>
				</n-space>
			</n-space>
		</n-list-item>
	</n-list>
</template>

<script setup>
const props = defineProps({
	wifiInfo: Object,
	title: String
});
const {proxy} = getCurrentInstance();
const device = reactive({});
const iface = reactive({});
const channels = reactive([]);
const txpwrlist = reactive([]);
const encryptions = reactive([]);
const hwmodelist = reactive([]); //模式
const htmodelist = computed({
	get() {
		let hts = [];
		switch (device.hwmode) {
			case '802.11ax':
				device.htmodelist.forEach((element) => {
					if (element.includes('HE')) {
						if (element.indexOf('80+80') === -1) {
							let tmp = {};
							tmp.label = element.replace('HE', '') + ' MHz';
							tmp.value = element;
							hts.push(tmp);
						}
					} else if (element.includes('MHz')) {
						let tmp = {};
						tmp.label = element;
						tmp.value = element;
						hts.push(tmp);
					}
				});
				break;
			case '802.11ac':
			case '802.11a/n/ac':
				device.htmodelist.forEach((element) => {
					if (element.includes('VHT')) {
						let tmp = {};
						tmp.label = element.replace('VHT', '') + ' MHz';
						tmp.value = element;
						hts.push(tmp);
					} else if (element.includes('MHz')) {
						let tmp = {};
						tmp.label = element;
						tmp.value = element;
						hts.push(tmp);
					}
				});
				break;
			case '802.11a':
			case '802.11b':
			case '802.11n':
			case '802.11g':
			case '802.11b/g/n':
				device.htmodelist.forEach((element) => {
					if (element.startsWith('HT')) {
						let tmp = {};
						tmp.label = element.replace('HT', '') + ' MHz';
						tmp.value = element;
						hts.push(tmp);
					} else if (element.includes('MHz')) {
						let tmp = {};
						tmp.label = element;
						tmp.value = element;
						hts.push(tmp);
					}
				});
				break;
			default:
				break;
		}
		return hts.sort((a, b) => {
			return a.value.localeCompare(b.value);
		});
	}
}); //频宽

let changeStatus = {
	ssid: false,
	encryption: false,
	key: false,
	htmode: false,
	channel: false,
	txpower: false,
	hidden: false,
	enable: false
};
const encryptionDes = {
	none: 'No Encryption',
	psk: 'WPA-PSK',
	psk2: 'WPA2-PSK',
	sae: 'WPA3-SAE',
	'psk-mixed': 'WPA-PSK/WPA2-PSK Mixed Mode',
	'sae-mixed': 'WPA2-PSK/WPA3-SAE Mixed Mode',
	'psk+psk2': 'WPA-PSK/WPA2-PSK Mixed Mode',
	'wep-open': 'WEP Open System',
	'wep-shared': 'WEP Shared Key'
};

function handleUpdateValue(key) {
	if (key === 'hwmode') {
		device.htmode = htmodelist.value[0].value;
	} else {
		changeStatus[key] = true;
	}
}

function dealWith(params) {
	if (Object.keys(params).length > 0) {
		device.device = params['.name'] ?? params.device;
		device.channel = params.channel;
		device.htmode = params.htmode;
		device.htmodelist = params.htmodelist;
		device.txpower = params.txpower ? params.txpower : 0;
		if (params.htmode.startsWith('HE')) {
			device.hwmode = '802.11ax';
		} else if (params.htmode.startsWith('VHT')) {
			device.hwmode = '802.11ac';
		} else if (params.htmode.startsWith('HT')) {
			device.hwmode = '802.11n';
		} else {
			device.hwmode = params.hwmode;
		}
		params.encryptions?.forEach((element) => {
			let tmp = {};
			tmp.label = encryptionDes[element];
			tmp.value = element;
			encryptions.push(tmp);
		});
		params.channels.forEach((element) => {
			let tmp = {};
			tmp.label = element.toString();
			tmp.value = element;
			channels.push(tmp);
		});
		params.hwmodelist.forEach((element) => {
			let tmp = {};
			tmp.label = element.toString();
			tmp.value = element;
			hwmodelist.push(tmp);
		});
		hwmodelist.sort((a, b) => {
			return a.value.localeCompare(b.value);
		});
		params.interfaces.forEach((element) => {
			if (element.network === 'lan') {
				iface.id = element['.name'];
				iface.ssid = element.ssid;
				iface.key = element.key;
				iface.encryption = element.encryption;
				iface.device = element.device;
				iface.hidden = element.hidden;
				iface.enable = element.enable ?? true;
			}
		});
		params.txpwrlist?.forEach((element) => {
			let tmp = {};
			if (element.dbm === 0) {
				tmp.label = proxy.$t('Driver default');
			} else {
				tmp.label = element.dbm.toString();
			}
			tmp.value = element.dbm.toString();
			txpwrlist.push(tmp);
		});
	}
}

function channelOptimize() {
	proxy.$message.success('success');
}

function updateConfig() {
	let params = {};
	for (const key in changeStatus) {
		if (changeStatus[key]) {
			params[key] = device[key] ?? iface[key];
		}
	}
	if (Object.hasOwnProperty.call(params, 'enable')) {
		params.disabled = params.enable ? '0' : '1';
	}
	if (Object.hasOwnProperty.call(params, 'hidden')) {
		params.hidden = params.hidden ? '1' : '0';
	}
	params.id = iface.id;
	params.device = iface.device;
	console.log(params);

	proxy.$hiui.call('wireless', 'updateConfig', params).then((result) => {
		for (const key in changeStatus) {
			changeStatus[key] = false;
		}
		proxy.$message.success('success');
	});
}

watch(
	() => props.wifiInfo,
	(nv, pv) => {
		dealWith(nv);
	}
);
</script>
<style scoped>
.font-18 {
	font-size: 18px;
}
.des {
	position: absolute;
	z-index: 500;
	pointer-events: none;
	width: 100%;
	right: 36px;
	height: 48px;
	color: #98a3b7;
}
</style>
