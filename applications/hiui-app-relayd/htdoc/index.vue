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
				<div>{{ $t('Nearby available network') }}</div>
				<div>{{ $t('Join network') }}</div>
			</n-space>
			<n-list bordered>
				<n-space vertical>
					<n-list-item v-for="(item, index) in historyDatas" :key="index" class="bg-border bg">
						<n-space justify="space-between" align="center">
							<n-space>
								<n-icon size="24" :component="MdWifi"></n-icon>
								<span>openwrt-5g</span>
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
		<n-input type="password" show-password-on="mousedown" placeholder="密码" :minlength="8" />
		<template #action>
			<n-space align="center" :size="30">
				<n-button text ghost @click="removeWifi">{{ $t('移除网络') }}</n-button>
				<n-button type="primary" size="small" round>{{ $t('join') }}</n-button>
			</n-space>
		</template>
	</n-modal>
</template>

<script setup>
import {MdWifi} from '@vicons/ionicons4';
const dialog = useDialog();
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
const showModal = ref(false);
const modalTitle = ref('111111111');
function handleBack() {
	console.log('2222222');
}
function handleChange(item) {
	showModal.value = item.auto;
	console.log(item);
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
</script>
<style scoped>
.bg {
	background-color: red;
}
</style>

<i18n src="./locale.json" />
