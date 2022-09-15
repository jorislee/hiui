<template>
	<n-list class="width-fill pd-30" :show-divider="false">
		<template #header>
			<n-space justify="space-between">
				<n-space class="font-18" align="center">
					<div class="circle"></div>
					{{ $t('2.4G WIFI') }}
				</n-space>
				<n-space align="center">
					<div>{{ $t('Enable wifi') }}</div>
					<n-switch :value="false" size="medium" />
				</n-space>
			</n-space>
		</template>
		<n-list-item>
			<n-input :value="wifiInfo.name" type="text" placeholder="" size="medium">
				<template #suffix>
					<div style="padding: 0 24px 0 0; color: #98a3b7">{{ $t('name') }}</div>
				</template>
			</n-input>
		</n-list-item>
		<n-list-item>
			<n-space justify="end" align="center" class="des __internal-selection-m">{{ $t('加密方式') }}</n-space>
			<n-select placeholder="" :default-value="wifiInfo.encrypt" @update:value="handleUpdateValue"></n-select>
		</n-list-item>
		<n-list-item>
			<n-input :value="wifiInfo.password" type="password" placeholder="密码" size="medium" show-password-on="mousedown" :minlenght="8">
				<template #suffix>
					<div style="padding: 0 8px 0 0; color: #98a3b7">{{ $t('password') }}</div>
				</template>
			</n-input>
		</n-list-item>
		<n-list-item>
			<n-space justify="end" align="center" class="des __internal-selection-m">{{ $t('模式') }}</n-space>
			<n-select placeholder="" :default-value="wifiInfo.encrypt" :options="options" @update:value="handleUpdateValue" />
		</n-list-item>
		<n-list-item>
			<n-space justify="end" align="center" class="des __internal-selection-m">{{ $t('频宽') }}</n-space>
			<n-select placeholder="" :default-value="wifiInfo.encrypt" :options="options" @update:value="handleUpdateValue" />
		</n-list-item>
		<n-list-item>
			<n-space justify="end" align="center" class="des __internal-selection-m">{{ $t('信道') }}</n-space>
			<n-select placeholder="" :default-value="wifiInfo.encrypt" :options="options" @update:value="handleUpdateValue" />
		</n-list-item>
		<n-list-item>
			<n-space justify="end" align="center" class="des __internal-selection-m">{{ $t('发射功率(dBm)') }}</n-space>
			<n-select placeholder="" :default-value="wifiInfo.encrypt" :options="options" @update:value="handleUpdateValue" />
		</n-list-item>
		<n-list-item>
			<n-space justify="space-between" align="center">
				<n-checkbox v-model:checked="value">复选框</n-checkbox>
				<n-space>
					<n-button type="text" ghost>{{ $t('信道优化') }}</n-button>
					<n-button type="info" round size="medium">{{ $t('save') }}</n-button>
				</n-space>
			</n-space>
		</n-list-item>
	</n-list>
</template>

<script setup>
defineProps({
	wifiInfo: Object
});
const options = reactive([
	{
		label: 'Drive My Car',
		value: 'song1'
	},
	{
		label: 'Norwegian Wood',
		value: 'song2'
	}
]);
function handleUpdateValue(params) {
	console.log(params);
}
</script>
<style scoped>
.font-18 {
	font-size: 18px;
}
:deep(.n-base-selection-placeholder) {
	display: flex;
	justify-content: flex-end;
}
.des {
	position: absolute;
	z-index: 500;
	pointer-events: none;
	width: 100%;
	right: 36px;
	height: var(--n-height);
	color: #98a3b7;
}
:deep(.__internal-selection-m) {
	--n-height: 48px !important;
}
:deep(.n-input__input-el) {
	height: 48px;
}
</style>
