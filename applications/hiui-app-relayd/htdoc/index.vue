<template>
	<n-page-header @back="handleBack" class="components-bg">
		<template #title>
			{{ $t('Relayd Settings') }}
		</template>
		<n-space vertical class="pd-20 components-bg">
			<n-space justify="space-between" class="pd-0-15">
				{{ $t('History connect network') }}
				<div>
					{{ $t('auto connect') }}
					<n-switch v-model:value="autoConnect" size="medium" />
				</div>
			</n-space>
			<n-list bordered>
				<n-list-item v-for="(item, index) in datas" :key="index">
					<n-space justify="space-between" align="center">
						<n-space>
							<n-icon size="24" :component="MdWifi"></n-icon>
							<span>openwrt-5g</span>
							<n-tag type="info" size="small">current</n-tag>
						</n-space>
						<div>
							<n-switch v-model:value="item.auto" size="medium" />
						</div>
					</n-space>
				</n-list-item>
			</n-list>
		</n-space>
		<n-space vertical class="pd-20 components-bg">
			<n-space justify="space-between" class="pd-0-15">
				{{ $t('Nearby available network') }}
			</n-space>
			<n-list bordered>
				<n-space vertical>
					<n-list-item v-for="(item, index) in historyDatas" :key="index" class="bg-border">
						<n-space justify="space-between" align="center">
							<n-space>
								<n-icon size="24" :component="MdWifi"></n-icon>
								<span>openwrt-5g</span>
							</n-space>
							<div>
								<n-switch v-model:value="item.auto" size="medium" />
							</div>
						</n-space>
					</n-list-item>
				</n-space>
			</n-list>
		</n-space>
	</n-page-header>
</template>

<script setup>
import {MdWifi} from '@vicons/ionicons4';
const datas = reactive([
	{
		name: '1111',
		auto: true,
		connecting: 'true',
		password: '2323232322'
	},
	{
		name: '2222',
		auto: false,
		connecting: 'false',
		password: '2323232322'
	},
	{
		name: '3333',
		auto: false,
		connecting: 'false',
		password: '2323232322'
	}
]);
const historyDatas = reactive([
	{
		name: '1111',
		auto: true,
		connecting: 'true',
		password: '2323232322'
	},
	{
		name: '2222',
		auto: false,
		connecting: 'false',
		password: '2323232322'
	},
	{
		name: '3333',
		auto: false,
		connecting: 'false',
		password: '2323232322'
	}
]);
const {proxy} = getCurrentInstance();
const {autoConnect} = ref(false);
console.log(proxy.$route.query);
function handleBack() {
	console.log('2222222');
}
</script>
<style scoped>
.bg {
	background-color: red;
}
</style>

<i18n src="./locale.json" />
