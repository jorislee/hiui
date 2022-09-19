<template>
	<div class="components-bg pd-30">
		<n-layout>
			<n-space align="center">
				<div class="circle"></div>
				<div class="font-24-size">{{ $t('Network Status') }}</div>
			</n-space>
		</n-layout>
		<n-divider />
		<n-space justify="space-between" style="padding-bottom: 20px">
			<n-radio-group v-model:value="cur" name="curpage" @update:value="handleOnlineChange">
				<n-space>
					<n-radio-button class="bt-radio" key="online" value="online" :label="$t('online')" />
					<n-radio-button class="bt-radio" key="offline" value="offline" :label="$t('offline')" />
				</n-space>
			</n-radio-group>
			<n-space>
				{{ $t('开启实时') }}
				<n-switch v-model:value="traffic" size="medium" @update:value="handleTraffic" />
			</n-space>
		</n-space>
		<div class="bg-color bg-border">
			<div class="bg pd-8-20">
				<the-device-list v-for="(item, index) in datas" :key="index" :data="item" :title="index" :online="cur === 'online'"></the-device-list>
			</div>
		</div>
	</div>
</template>

<script setup>
import TheDeviceList from './components/TheDeviceList.vue';
const {proxy} = getCurrentInstance();
const datas = reactive({
	deviceCable: [],
	device5g: [],
	device2g: []
});

const traffic = ref(false);
const cur = ref('online');
const test = {
	clients: [
		{
			remote: false,
			mac: 'e0:ac:cb:72:3e:4e',
			favorite: false,
			ip: '192.168.8.143',
			up: '0',
			down: '0',
			total_up: '0',
			total_down: '0',
			qos_up: '0',
			qos_down: '0',
			blocked: true,
			iface: '5G',
			name: '*',
			online_time: '1662605882',
			alive: '701739',
			new_online: false,
			online: false,
			vendor: 'Apple, Inc.',
			node: '0'
		},
		{
			remote: false,
			mac: 'd0:81:7a:ad:61:ca',
			favorite: false,
			ip: '192.168.8.173',
			up: '0',
			down: '0',
			total_up: '7928009',
			total_down: '15733725',
			qos_up: '0',
			qos_down: '0',
			blocked: false,
			iface: '2.4G',
			name: 'hzynverdeiMac',
			online_time: '1663120091',
			alive: '429428',
			new_online: false,
			online: false,
			vendor: 'Apple, Inc.',
			node: '0'
		},
		{
			remote: false,
			mac: 'a8:a1:59:52:e7:33',
			favorite: false,
			ip: '192.168.8.120',
			up: '0',
			down: '0',
			total_up: '0',
			total_down: '0',
			qos_up: '0',
			qos_down: '0',
			blocked: false,
			iface: 'cable',
			name: 'Hitosea15deiMac',
			online_time: '1663239186',
			alive: '338685',
			new_online: false,
			online: true,
			vendor: 'ASRock Incorporation',
			node: '0'
		},
		{
			remote: false,
			mac: '5a:27:59:f1:c4:66',
			favorite: false,
			ip: '192.168.8.169',
			up: '0',
			down: '0',
			total_up: '22115',
			total_down: '75465',
			qos_up: '0',
			qos_down: '0',
			blocked: false,
			iface: '5G',
			name: '*',
			online_time: '1663577241',
			alive: '630',
			new_online: false,
			online: true,
			vendor: 'Unknown',
			node: '0'
		}
	],
	code: 0
};
function addItem(item) {
	switch (item.iface.toUpperCase()) {
		case '2.4G':
			for (let index = 0; index < datas.device2g.length; index++) {
				if (datas.device2g[index].mac === item.mac) {
					return;
				}
			}
			if (cur.value === (item.online ? 'online' : 'offline')) {
				datas.device2g.push(item);
			}
			break;
		case '5G':
			for (let index = 0; index < datas.device5g.length; index++) {
				if (datas.device5g[index].mac === item.mac) {
					return;
				}
			}
			if (cur.value === (item.online ? 'online' : 'offline')) {
				datas.device5g.push(item);
			}
			break;
		case 'CABLE':
			for (let index = 0; index < datas.deviceCable.length; index++) {
				if (datas.deviceCable[index].mac === item.mac) {
					return;
				}
			}
			if (cur.value === (item.online ? 'online' : 'offline')) {
				datas.deviceCable.push(item);
			}
			break;
		default:
			break;
	}
}
function handleTraffic() {
	console.log('111');
}

function handleOnlineChange() {
	datas.device2g = [];
	datas.device5g = [];
	datas.deviceCable = [];
	test.clients.forEach((item) => {
		addItem(item);
	});
}

onBeforeMount(() => {
	proxy.$timer.create(
		'getClients',
		() => {
			proxy.$hiui.call('clients', 'getClients').then((result) => {
				console.log(result);
				if (Object.keys(result).length > 0) {
					result.clients.forEach((item) => {
						addItem(item);
					});
				}
			});
		},
		{repeat: true, immediate: true, time: 10000}
	);
	test.clients.forEach((item) => {
		addItem(item);
	});
});
</script>
<style scoped>
.bg {
	width: -webkit-fill-available;
	background: transparent;
}

.bt-radio {
	height: 32px;
	display: flex;
	align-items: center;
}
</style>

<i18n src="./locale.json" />
