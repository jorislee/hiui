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
					<n-switch :value="false" size="medium" />
				</n-space>
			</n-space>
		</template>
		<n-list-item>
			<n-input :value="iface.ssid" type="text" placeholder="" size="large">
				<template #suffix>
					<div style="padding: 0 24px 0 0; color: #98a3b7">{{ $t('name') }}</div>
				</template>
			</n-input>
		</n-list-item>
		<n-list-item>
			<n-space justify="end" align="center" class="des">{{ $t('加密方式') }}</n-space>
			<n-select placeholder="" v-model:value="iface.encryption" @update:value="handleUpdateValue"></n-select>
		</n-list-item>
		<n-list-item>
			<n-input :value="iface.key" type="password" placeholder="" size="large" show-password-on="mousedown" :minlenght="8">
				<template #suffix>
					<div style="padding: 0 8px 0 0; color: #98a3b7">{{ $t('password') }}</div>
				</template>
			</n-input>
		</n-list-item>
		<n-list-item>
			<n-space justify="end" align="center" class="des">{{ $t('模式') }}</n-space>
			<n-select placeholder="" v-model:value="device.hwmode" :options="hwmodelist" @update:value="handleUpdateValue" />
		</n-list-item>
		<n-list-item>
			<n-space justify="end" align="center" class="des">{{ $t('频宽') }}</n-space>
			<n-select placeholder="" v-model:value="device.htmode" :options="htmodelist" @update:value="handleUpdateValue" />
		</n-list-item>
		<n-list-item>
			<n-space justify="end" align="center" class="des">{{ $t('信道') }}</n-space>
			<n-select placeholder="" v-model:value="device.channel" :options="freqlist" @update:value="handleUpdateValue" />
		</n-list-item>
		<n-list-item>
			<n-space justify="end" align="center" class="des">{{ $t('发射功率(dBm)') }}</n-space>
			<n-select placeholder="" v-model:value="device.txpower" :options="txpowerlist" @update:value="handleUpdateValue" />
		</n-list-item>
		<n-list-item>
			<n-space justify="space-between" align="center">
				<n-checkbox v-model:checked="hiddenCheck">{{ $t('隐藏网络不被发现') }}</n-checkbox>
				<n-space>
					<n-button type="text" ghost>{{ $t('信道优化') }}</n-button>
					<n-button type="info" round size="medium">{{ $t('save') }}</n-button>
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
const hiddenCheck = ref(false);
const device = reactive({});
const iface = reactive({});
const hwmodelist = reactive([]); //模式
const htmodelist = computed({
	get() {
		let hts = [];
		switch (device.hwmode) {
			case '802.11ax':
				device.htmodelist.forEach((element) => {
					if (element.includes('HE')) {
						console.log(element.indexOf('80+80'));
						if (element.indexOf('80+80') === -1) {
							let tmp = {};
							tmp.label = element.replace('HE', '') + ' MHz';
							tmp.value = element;
							hts.push(tmp);
						}
					}
				});
				break;
			case '802.11ac':
				device.htmodelist.forEach((element) => {
					if (element.includes('VHT')) {
						let tmp = {};
						tmp.label = element.replace('VHT', '') + ' MHz';
						tmp.value = element;
						hts.push(tmp);
					}
				});
				break;
			case '802.11b':
			case '802.11n':
			case '802.11g':
				device.htmodelist.forEach((element) => {
					if (element.startsWith('HT')) {
						let tmp = {};
						tmp.label = element.replace('HT', '') + ' MHz';
						tmp.value = element;
						hts.push(tmp);
					}
				});
				break;
			default:
				break;
		}
		return hts;
	}
}); //频宽
const freqlist = reactive([]);
const txpowerlist = reactive([]);

function handleUpdateValue(params) {
	console.log(params);
}

function dealWith(params) {
	console.log(params);
	if (Object.keys(params).length > 0) {
		device.name = params['.name'];
		device.channel = params.channel;
		device.htmode = params.htmode;
		device.htmodelist = params.htmodelist;
		if (params.htmode.startsWith('HE')) {
			device.hwmode = '802.11ax';
		} else if (params.htmode.startsWith('VHT')) {
			device.hwmode = '802.11ac';
		} else if (params.htmode.startsWith('HT')) {
			device.hwmode = '802.11bgn';
		}
		console.log(device.hwmode);

		params.freqlist.forEach((element) => {
			let tmp = {};
			tmp.label = element.toString();
			tmp.value = element;
			freqlist.push(tmp);
		});
		params.hwmodelist.forEach((element) => {
			let tmp = {};
			tmp.label = element.toString();
			tmp.value = element;
			hwmodelist.push(tmp);
			hwmodelist.sort();
		});
		params.interfaces.forEach((element) => {
			if (element.network === 'lan') {
				iface.ssid = element.ssid;
				iface.key = element.key;
				iface.encryption = element.encryption;
				iface.device = element.device;
			}
		});
	}
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
