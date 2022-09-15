<template>
	<div class="flex-hor bg-color bg-border">
		<n-list class="width-fill pd-30">
			<template #header>
				<div class="font-18">{{ $t('广域网信息-WAN') }}</div>
			</template>
			<n-list-item v-for="i in wanInfo" :key="i">
				<n-thing :title="i[0]" :title-extra="i[1]" />
			</n-list-item>
		</n-list>
		<n-divider vertical />

		<n-list class="width-fill pd-30">
			<template #header>
				<div class="font-18">{{ $t('局域网信息-LAN') }}</div>
			</template>
			<n-list-item v-for="i in lanInfo" :key="i">
				<n-thing :title="i[0]" :title-extra="i[1]" />
			</n-list-item>
		</n-list>
	</div>
</template>

<script setup>
const {proxy} = getCurrentInstance();
const lanInfo = ref([]);
const wanInfo = ref([]);

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
			for (const v of element.route) {
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
				}
			}
		});
	});
}
onBeforeMount(() => {
	proxy.$timer.create('getNetworks', getNetworks, {repeat: true, immediate: true, time: 5000});
});
</script>
<style scoped>
:deep(.n-divider.n-divider--vertical) {
	height: 200px;
	margin: 60px 30px;
	padding-top: 20%;
}
.pd-30 {
	padding: 18px 30px 30px 30px;
}
.font-18 {
	font-size: 18px;
}
</style>
