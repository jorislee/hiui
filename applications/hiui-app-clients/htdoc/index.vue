<template>
	<div class="components-bg pd-30">
		<n-layout>
			<n-space align="center">
				<div class="circle"></div>
				<div class="font-24-size">{{ $t('Clients') }}</div>
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
				<n-switch v-model:value="traffic" size="medium" @update:value="handleTraffic" :loading="loading" />
			</n-space>
		</n-space>
		<div class="bg-color bg-border">
			<div class="bg pd-8-20">
				<the-device-list v-for="(item, index) in datas" :key="index" :data="item" :title="index" :online="cur === 'online'" :traffic="traffic"></the-device-list>
			</div>
			<n-empty v-if="empty" description="什么也没有"></n-empty>
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
let rawdata;

const empty = ref(true);

const traffic = ref(false);
const cur = ref('online');
const loading = ref(false);
function addItem(item) {
	switch (item.iface.toUpperCase()) {
		case '2.4G':
			for (let index = 0; index < datas.device2g.length; index++) {
				if (datas.device2g[index].mac === item.mac) {
					return;
				}
			}
			if (cur.value === (item.online ? 'online' : 'offline')) {
				empty.value = false;
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
				empty.value = false;
				datas.device5g.push(item);
			}
			break;
		case 'WIRED':
			for (let index = 0; index < datas.deviceCable.length; index++) {
				if (datas.deviceCable[index].mac === item.mac) {
					return;
				}
			}
			if (cur.value === (item.online ? 'online' : 'offline')) {
				console.log('----------------------------------------------------------------');
				empty.value = false;
				datas.deviceCable.push(item);
			}
			break;
		default:
			break;
	}
}
function handleTraffic() {
	setTimeout(() => {
		loading.value = false;
	}, 10000);
	if (!loading.value) {
		loading.value = true;
		setTrafficStatus();
	}
}

function handleOnlineChange() {
	datas.device2g = [];
	datas.device5g = [];
	datas.deviceCable = [];
	empty.value = true;

	if (rawdata) {
		rawdata.forEach((item) => {
			addItem(item);
		});
	}
}

function setTrafficStatus() {
	proxy.$hiui.call('clients', 'setTraffic', {enable: traffic.value ? '1' : '0'}).then((result) => {
		traffic.value = result.enable;
	});
}

function getTrafficStatus() {
	proxy.$hiui.call('clients', 'getTraffic').then((result) => {
		traffic.value = result.enable;
	});
}

onBeforeMount(() => {
	proxy.$timer.create(
		'getClients',
		() => {
			proxy.$hiui.call('clients', 'getClients').then((result) => {
				console.log(result);
				if (result.code === 0) {
					rawdata = result.clients;
					datas.device2g = [];
					datas.device5g = [];
					datas.deviceCable = [];
					result.clients.forEach((item) => {
						addItem(item);
					});
				}
			});
		},
		{repeat: true, immediate: true, time: 5000}
	);
	getTrafficStatus();
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
