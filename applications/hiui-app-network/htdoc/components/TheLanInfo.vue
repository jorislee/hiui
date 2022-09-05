<template>
	<div class="bg-list bg-border">
		<n-list class="bg-list pd-30">
			<template #header>
				<div class="font-18">{{ $t('广域网信息-WAN') }}</div>
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

		<n-list class="bg-list pd-30">
			<template #header>
				<div class="font-18">{{ $t('局域网信息-LAN') }}</div>
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
	</div>
</template>

<script setup></script>
<style scoped>
:deep(.n-divider.n-divider--vertical) {
	height: 200px;
	margin: 0 30px;
}
.bg-list {
	width: -webkit-fill-available;
	align-self: stretch;
	background: linear-gradient(180deg, #f3f5f8 0%, #ffffff 100%);
}
.pd-30 {
	padding: 18px 30px 30px 30px;
}
.font-18 {
	font-size: 18px;
}
</style>
