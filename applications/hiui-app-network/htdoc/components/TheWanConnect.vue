<template>
	<div class="flex-hor bg-color bg-border">
		<n-list class="width-fill pd-30">
			<template #header>
				<n-space justify="space-between">
					<n-space class="font-18" align="center">
						<div class="circle"></div>
						{{ $t(name) }}
						<n-tag :bordered="false" size="small">{{ $t('current network') }}</n-tag>
					</n-space>
					<n-button v-if="isconnect" ghost round color="red" size="medium" @click="disconnect">{{ $t('Disconnect') }}</n-button>
				</n-space>
			</template>
			<n-list-item v-for="i in staName.length" :key="i">
				<n-thing :title="staName[i - 1]" :title-extra="i[1]" />
			</n-list-item>
		</n-list>
		<n-divider vertical />

		<n-list class="width-fill pd-30">
			<template #header>
				<n-space class="font-18" align="center">
					<div class="circle"></div>
					{{ $t('中继设置') }}
				</n-space>
			</template>
			<n-list-item>
				<div>{{ $t('Nearby available network') }}</div>
				<template #suffix>
					<n-button text type="info" @click="pushRelayd('scan')">{{ $t('scan') }}</n-button>
				</template>
			</n-list-item>
			<n-list-item>
				<div>{{ $t('History connect network') }}</div>
				<template #suffix>
					<n-button text type="info" @click="pushRelayd('check')">{{ $t('check') }}</n-button>
				</template>
			</n-list-item>
			<n-list-item>
				<div>{{ $t('Auto connect') }}</div>
				<template #suffix>
					<n-switch v-model:value="autoConnect" size="medium" />
				</template>
			</n-list-item>
		</n-list>
	</div>
</template>

<script setup>
const autoConnect = ref(false);
const staInfo = ref([]);
const staName = ['Address', 'Mask', 'Gateway', 'DNS'];
const {proxy} = getCurrentInstance();
const name = ref('Not connected');
const isconnect = ref(false);
function getNetworks() {
	proxy.$hiui.call('wireless', 'staInfo').then((element) => {
		if (Object.keys(element).length == 0) {
			return;
		}
		name.value = element.name;
		if (element.up) {
			isconnect.value = true;
		}
		console.log('1111111111111111', element);
		staInfo.value[0] = ['Address', element['ipv4-address'][0].address];
		let mask;
		if (element['ipv4-address'][0].mask === 24) {
			mask = '255.255.255.0';
		} else if (element['ipv4-address'][0].mask === 16) {
			mask = '255.255.0.0';
		}
		staInfo.value[1] = ['Mask', mask];
		staInfo.value[2] = ['Gateway', element.route.filter((r) => r.target === '0.0.0.0' && r.mask === 0).map((r) => r.nexthop)[0]];
		staInfo.value[3] = ['DNS', element['dns-server'].join(', ')];
	});
}
function disconnect() {
	proxy.$hiui.call('wireless', 'disStaConnect').then((element) => {});
}
onBeforeMount(() => {
	proxy.$timer.create('getNetworks', getNetworks, {repeat: true, immediate: true, time: 5000});
});
function pushRelayd(params) {
	let data;
	if (params === 'scan') {
		data = {action: 'scan'};
	} else if (params === 'check') {
		data = {action: 'check'};
	}
	proxy.$router.push({path: '/network/relayd', query: data});
}
</script>
<style scoped>
:deep(.n-divider.n-divider--vertical) {
	height: 200px;
	margin: 50px 30px;
}

.pd-30 {
	padding: 18px 30px 30px 30px;
}
.font-18 {
	font-size: 18px;
}
</style>
