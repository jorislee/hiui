<template>
	<n-form size="large" ref="form" label-placement="left" label-width="auto" :model="formValue" :rules="rules">
		<n-form-item :label="$t('Hostname')" path="hostname">
			<n-input v-model:value="formValue.hostname" />
		</n-form-item>
		<n-form-item :label="$t('Timezone')" path="zonename">
			<n-select v-model:value="formValue.zonename" :options="zoneinfo" filterable />
		</n-form-item>
	</n-form>
	<n-space justify="end" style="padding-right: 100px">
		<n-button type="primary" :loading="loading" @click="handleSubmit">{{ $t('Save & Apply') }}</n-button>
	</n-space>
</template>

<script setup></script>

<i18n src="./locale.json" />
