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
			<n-radio-group v-model:value="cur" name="curpage">
				<n-space>
					<n-radio-button class="bt-radio" key="online" value="online" :label="$t('online')" />
					<n-radio-button class="bt-radio" key="offline" value="offline" :label="$t('offline')" />
				</n-space>
			</n-radio-group>
			<n-space>
				{{ $t('开启实时') }}
				<n-switch v-model:value="traffic" size="medium" @update:value="handleChange(item)" />
			</n-space>
		</n-space>
		<div class="bg-color bg-border">
			<div class="bg pd-8-20">
				<n-list class="bg">
					<template #header>
						<n-space justify="space-between" class="pd-0-15">
							<div>{{ $t('wired device') }}</div>
							<n-space :size="50">
								<n-tooltip trigger="hover">
									<template #trigger>
										<div>{{ $t('internet') }}</div>
									</template>
									如果它长得像鸭子，走起来像鸭子，叫起来也像鸭子，那它一定是个鸭子。
								</n-tooltip>
								<div v-if="cur == 'offline'">{{ $t('operate') }}</div>
							</n-space>
						</n-space>
					</template>
					<n-list-item v-for="(item, index) in 4" :key="index" class="list-item-border mg-bt-10">
						<n-space align="center" justify="space-between">
							<n-space>
								<n-icon size="40" :component="AndroidFilled"></n-icon>
								<n-space vertical size="small">
									<div>{{ $t('iphone13 mini') }}</div>
									<n-space :size="50">
										<div>{{ $t('IP地址') }}:&nbsp;&nbsp;173.20.2.2</div>
										<div>{{ $t('mac地址') }}:&nbsp;&nbsp;ff:ff:ff:ff:ff:ff</div>
										<div>{{ $t('speed') }}:&nbsp;&nbsp;ff:ff:ff:ff:ff:ff</div>
										<div>{{ $t('total') }}:&nbsp;&nbsp;ff:ff:ff:ff:ff:ff</div>
										<div>{{ $t('Qos') }}:&nbsp;&nbsp;ff:ff:ff:ff:ff:ff</div>
									</n-space>
								</n-space>
							</n-space>
							<n-space :size="50">
								<n-switch v-model:value="item.block" size="medium" @update:value="handleChange(item)" />
								<n-button text v-if="cur == 'offline'" @click="delClient(item)">
									<n-icon size="18"><DeleteFilled /></n-icon>
								</n-button>
							</n-space>
						</n-space>
					</n-list-item>
				</n-list>
				<n-list class="bg">
					<template #header>
						<n-space justify="space-between" class="pd-0-15">
							<div>{{ $t('wireless device') }}</div>
							<n-space :size="50">
								<n-tooltip trigger="hover">
									<template #trigger>
										<div>{{ $t('internet') }}</div>
									</template>
									如果它长得像鸭子，走起来像鸭子，叫起来也像鸭子，那它一定是个鸭子。
								</n-tooltip>
								<div v-if="cur == 'offline'">{{ $t('operate') }}</div>
							</n-space>
						</n-space>
					</template>
					<n-list-item v-for="(item, index) in 4" :key="index" class="list-item-border mg-bt-10">
						<n-space align="center" justify="space-between">
							<n-space>
								<n-icon size="40" :component="AppleFilled"></n-icon>
								<n-space vertical size="small">
									<div>{{ $t('iphone13 mini') }}</div>
									<n-space :size="50">
										<div>{{ $t('IP地址') }}:&nbsp;&nbsp;173.20.2.2</div>
										<div>{{ $t('mac地址') }}:&nbsp;&nbsp;ff:ff:ff:ff:ff:ff</div>
									</n-space>
								</n-space>
							</n-space>
							<n-space :size="50">
								<n-switch v-model:value="item.block" size="medium" @update:value="handleChange(item)" />
								<n-button text v-if="cur == 'offline'" @click="delClient(item)">
									<n-icon size="18"><DeleteFilled /></n-icon>
								</n-button>
							</n-space>
						</n-space>
					</n-list-item>
				</n-list>
			</div>
		</div>
	</div>
</template>

<script setup>
import {AndroidFilled, AppleFilled, DeleteFilled} from '@vicons/antd';
defineProps({
	datas: Object
});
const dialog = useDialog();
const traffic = ref(false);
const cur = ref('online');
function handleChange(item) {
	console.log(item);
}
function delClient(params) {
	dialog.warning({
		title: '警告',
		content: '你确定？',
		positiveText: '确定',
		negativeText: '不确定',
		onPositiveClick: () => {},
		onNegativeClick: () => {}
	});
}
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
