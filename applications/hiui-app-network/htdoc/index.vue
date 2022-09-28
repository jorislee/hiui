<template>
	<div class="pd-30 components-bg" vertical size="large">
		<n-layout>
			<n-space align="center">
				<div class="circle"></div>
				<div class="font-24-size">{{ $t('Network Status') }}</div>
			</n-space>
		</n-layout>
		<n-divider />

		<div class="dis-fle-nowrap">
			<n-space vertical align="center" size="large">
				<img src="@/assets/router.png" height="157" class="pd-0-55" />
				<div>{{ $t('Router') }}</div>
				<n-button v-if="!noWifi" type="default" @click="showInfo('router')" class="bt-bg">
					<div v-if="wifiInfo.wifi2g" class="flex-hor-ac">
						<div class="circle" :class="{gray: !wifiInfo.wifi2g.up}"></div>
						<span>&ensp;{{ wifiInfo.wifi2g.name }}</span>
					</div>
					<n-divider vertical v-if="wifiInfo.wifi5g" />
					<div v-if="wifiInfo.wifi5g" class="flex-hor-ac">
						<div class="circle"></div>
						<span>&ensp;{{ wifiInfo.wifi5g.name }}</span>
					</div>
				</n-button>
			</n-space>
			<div ref="dividerInternal" style="width: 100%">
				<img v-if="conInternal" src="@/assets/connect-success.svg" />
				<n-divider v-else style="padding-top: 55px" />
			</div>
			<n-space vertical align="center" size="large" class="pd-0-55">
				<img src="@/assets/internal.png" height="157" />
				<div>{{ $t('Internal') }}</div>
				<n-button type="default" @click="showInfo('internal')" class="bt-bg">
					<div class="flex-hor-ac" v-if="wired.up">
						<div class="circle"></div>
						<span>&ensp;{{ wired.name }}</span>
					</div>
					<n-divider vertical v-if="relay.up && wired.up" />
					<div class="flex-hor-ac" v-if="relay.up">
						<div class="circle"></div>
						<span>&ensp;{{ relay.name }}</span>
					</div>
					<div v-if="!wired.up && !relay.up">{{ $t('settings') }}</div>
				</n-button>
			</n-space>
			<div ref="dividerSpeed" style="width: 100%">
				<img v-if="conSpeed > 1" src="@/assets/connect-success.svg" />
				<n-divider v-else style="padding-top: 55px" />
			</div>
			<div class="pd-0-55">
				<n-space v-if="conSpeed > 0" vertical align="center" size="large">
					<img src="@/assets/speedserver.png" height="157" />
					<div>{{ $t('Internal') }}</div>
					<n-button v-if="conSpeed === 1" ghost round type="info" @click="showInfo('internal')">{{ $t('enable') }}</n-button>
				</n-space>
				<n-space v-else-if="conSpeed === 0" vertical align="center" size="large" style="padding-top: 40px">
					<n-ellipsis style="width: 157px" :line-clamp="3">您可以开通互联网加速模块，以便更快速地访问互联网。</n-ellipsis>
					<n-button type="info" @click="showInfo('speed')" color="#0052D9" round size="medium">{{ $t('开通加速') }}</n-button>
				</n-space>
			</div>
		</div>
		<div>
			<the-lan-info v-if="infoType === 1" :lan-info="lanInfo" :wan-info="wanInfo"></the-lan-info>
			<the-relay-connect v-else-if="infoType === 2" :relay-info="relay"></the-relay-connect>
		</div>
	</div>
</template>
<script setup>
import TheLanInfo from './components/TheLanInfo.vue';
import TheRelayConnect from './components/TheRelayConnect.vue';

const {proxy} = getCurrentInstance();
const conInternal = ref(true);
const conSpeed = ref(0);
const noWifi = ref(false);
const infoType = ref(1);
const dividerInternal = ref(null);
const dividerSpeed = ref(null);
const wired = reactive({up: false, name: 'Wired'});
const relay = reactive({
	up: false,
	name: null,
	info: [
		['Address', ''],
		['Mask', ''],
		['Gateway', ''],
		['DNS', '']
	]
});
const lanInfo = ref([]);
const wanInfo = ref([]);
const wifiInfo = reactive({});
const speedInfo = reactive({});

function showInfo(params) {
	if (params === 'router') {
		infoType.value = 1;
	} else if (params === 'internal') {
		infoType.value = 2;
	} else if (params === 'speed') {
		proxy.$router.push('/sdwan');
	}
}

function getNetworks() {
	proxy.$hiui.call('network', 'get_networks').then(({networks}) => {
		networks.forEach((element) => {
			let mask;
			if (element.interface === 'lan') {
				lanInfo.value[0] = ['Address', element['ipv4-address'][0].address];
				if (element['ipv4-address'][0].mask === 24) {
					mask = '255.255.255.0';
				} else if (element['ipv4-address'][0].mask === 16) {
					mask = '255.255.0.0';
				}
				lanInfo.value[1] = ['Mask', mask];
				lanInfo.value[2] = ['DHCP', element.proto === 'dhcp' ? 'yes' : 'no'];
			}

			element.route?.forEach((v) => {
				if (v.target === '0.0.0.0' && v.mask === 0) {
					wanInfo.value[0] = ['Address', element['ipv4-address'][0].address];
					if (element['ipv4-address'][0].mask === 24) {
						mask = '255.255.255.0';
					} else if (element['ipv4-address'][0].mask === 16) {
						mask = '255.255.0.0';
					}
					wanInfo.value[1] = ['Mask', mask];
					wanInfo.value[2] = ['Gateway', element.route.filter((r) => r.target === '0.0.0.0' && r.mask === 0).map((r) => r.nexthop)[0]];
					wanInfo.value[3] = ['DNS', element['dns-server'].join(', ')];
					wanInfo.value[4] = ['Mac', element.mac];
					if (element.interface === 'wan') {
						wired.up = true;
					}
					console.log(element);
				}
			});
		});
	});
}

function getRelayInfo() {
	proxy.$hiui.call('wireless', 'relayInfo').then((result) => {
		if (Object.keys(result).length === 0 || !result.up) {
			relay.name = null;
			relay.up = false;
			relay.info = [
				['Address', ''],
				['Mask', ''],
				['Gateway', ''],
				['DNS', '']
			];
			return;
		}
		relay.name = result.name;
		relay.up = result.up;
		relay.info[0] = ['Address', result['ipv4-address'][0].address];
		let mask;
		if (result['ipv4-address'][0].mask === 24) {
			mask = '255.255.255.0';
		} else if (result['ipv4-address'][0].mask === 16) {
			mask = '255.255.0.0';
		}
		relay.info[1] = ['Mask', mask];
		relay.info[2] = ['Gateway', result.route.filter((r) => r.target === '0.0.0.0' && r.mask === 0).map((r) => r.nexthop)[0]];
		relay.info[3] = ['DNS', result['dns-server'].join(', ')];
	});
}

function getWifiInfo() {
	proxy.$hiui.call('wireless', 'getConfig').then((result) => {
		if (result?.wifi_2g) {
			result.wifi_2g.interfaces.forEach((item) => {
				if (item.network === 'lan') {
					wifiInfo.wifi2g = {};
					wifiInfo.wifi2g.name = item.ssid;
					wifiInfo.wifi2g.up = item.enable ?? item.up;
				}
			});
		}
		if (result?.wifi_5g) {
			result.wifi_5g.interfaces.forEach((item) => {
				if (item.network === 'lan') {
					wifiInfo.wifi5g = {};
					wifiInfo.wifi5g.name = item.ssid;
					wifiInfo.wifi5g.up = item.enable ?? item.up;
				}
			});
		}
		if (Object.keys(result).length === 0) {
			noWifi.value = true;
		}
	});
}

function getSpeedInfo() {
	proxy.$hiui.call('speed', 'speedStatus').then((result) => {
		console.log(result);
		speedInfo.wg = result.wg;
		speedInfo.service = result.service;
		if (result.service && Object.hasOwnProperty.call(result.service, 'peer')) {
			conSpeed.value = 1;
		}
		if (speedInfo.wg?.length > 10) {
			conSpeed.value = 2;
		}
	});
}

onBeforeMount(() => {
	proxy.$timer.create('getNetworks', getNetworks, {repeat: true, immediate: true, time: 5000});
	proxy.$timer.create('getRelayInfo', getRelayInfo, {repeat: true, immediate: true, time: 5000});
	proxy.$timer.create('getWifiInfo', getWifiInfo, {repeat: true, immediate: true, time: 5000});
	proxy.$timer.create('getSpeedInfo', getSpeedInfo, {repeat: true, immediate: true, time: 5000});
});
</script>
<style scoped>
.dis-fle-nowrap {
	display: flex;
	flex-wrap: nowrap;
	padding-bottom: 20px;
}
.pd-0-55 {
	padding: 0 60px;
}

.bt-bg {
	background: linear-gradient(180deg, #f3f5f8 0%, #ffffff 100%);
	box-sizing: border-box;
	border: 2px solid #ffffff;
	box-shadow: -4px -4px 10px 0px #ffffff, 4px 4px 10px 0px rgba(55, 99, 170, 0.05);
	width: 100%;
	height: 48px;
	border-radius: 110px;
	padding: 0 20px;
}
</style>
<i18n src="./locale.json" />
