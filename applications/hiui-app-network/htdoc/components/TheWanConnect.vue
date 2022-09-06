<template>
	<div class="bg-color bg-border">
		<n-list class="bg-color pd-30">
			<template #header>
				<n-space justify="space-between">
					<n-space class="font-18" align="center">
						<div class="circle"></div>
						{{ $t('广域网信息-WAN') }}
						<n-tag :bordered="false" size="small">{{ $t('current network') }}</n-tag>
					</n-space>
					<n-button ghost round color="red" size="medium">断开</n-button>
				</n-space>
			</template>
			<n-list-item v-for="i in 4" :key="i">
				<template #prefix>
					<n-button>{{ i }}</n-button>
				</template>
				<template #suffix>
					<n-button>Suffix</n-button>
				</template>
				<n-thing title="Thing" title-extra="extra" />
			</n-list-item>
		</n-list>
		<n-divider vertical />

		<n-list class="bg-color pd-30">
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
const {proxy} = getCurrentInstance();
function pushRelayd(params) {
	let data;
	if (params === 'scan') {
		data = {action: 'sacan'};
	} else if (params === 'check') {
		data = {action: 'check'};
	}
	proxy.$router.push({path: '/network/relayd', query: data});
}
</script>
<style scoped>
:deep(.n-divider.n-divider--vertical) {
	height: 200px;
	margin: 0 30px;
}

.pd-30 {
	padding: 18px 30px 30px 30px;
}
.font-18 {
	font-size: 18px;
}
</style>
