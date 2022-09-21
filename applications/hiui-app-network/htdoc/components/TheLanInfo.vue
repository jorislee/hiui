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
defineProps({
	lanInfo: Array,
	wanInfo: Array
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
