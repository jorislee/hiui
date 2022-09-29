<template>
	<n-config-provider :theme-overrides="themeOverrides">
		<n-space vertical class="bg-border bg-color pd-30">
			<div class="flex-hor-ac h-bg">
				<div style="width: -webkit-fill-available">{{ $t('enter node') }}:&nbsp;&nbsp;&nbsp;&nbsp;{{ enode }}</div>
				<div style="width: -webkit-fill-available">{{ $t('rule number') }}:&nbsp;&nbsp;&nbsp;&nbsp;{{ ruleNum }}</div>
			</div>
			<n-data-table
				remote
				:bordered="false"
				ref="table"
				:columns="columnsRef"
				:data="dataRef"
				:loading="loadingRef"
				:pagination="paginationReactive"
				:row-key="rowKey"
				@update:sorter="handleSorterChange"
				@update:filters="handleFiltersChange"
				@update:page="handlePageChange"
			>
				<template #empty>
					<img src="../assets/empty__image.png" />
				</template>
			</n-data-table>
		</n-space>
	</n-config-provider>
</template>

<script setup>
const themeOverrides = {
	DataTable: {
		thColor: 'transparent',
		tdColor: 'transparent',
		borderRadius: '10px',
		thTextColor: '#98A3B7'
	}
};
const columns = [
	{
		title: 'Id',
		key: 'id',
		width: 100
	},
	{
		title: 'Shunt object',
		key: 'shunt_object',
		width: 200
	},
	{
		title: 'Rule',
		key: 'rule',
		width: 200
	},
	{
		title: 'Config',
		key: 'config',
		width: 200
	},
	{
		title: 'Prio',
		key: 'prio',
		width: 120
	},
	{
		title: 'Remark',
		key: 'remark',
		width: 200
	}
];
const {proxy} = getCurrentInstance();

const enode = ref('test');
const ruleNum = ref('');

const dataRef = ref([]);
const loadingRef = ref(false);
const columnsRef = ref(columns);
const paginationReactive = reactive({
	page: 1,
	pageCount: 1,
	pageSize: 10,
	showQuickJumper: true
});

onMounted(() => {
	proxy.$hiui.call('sdwan', 'getShunt').then((result) => {
		console.log(result);
	});
});
function rowKey(rowData) {
	console.log(rowData);
	return rowData.id;
}
function handleSorterChange(sorter) {}
function handleFiltersChange(filters) {}
function handlePageChange(currentPage) {}
</script>

<style scoped>
.h-bg {
	height: 42px;
	padding: 0px 20px;
	align-self: stretch;
	border-radius: 4px;
	background: rgba(0, 82, 217, 0.08);
	color: #495770;
}
:deep(.n-data-table .n-data-table-empty) {
	background: white;
	border-radius: 8px;
}
</style>
<style>
tbody {
	background: white;
}
table tbody tr:first-child td:first-child {
	border-top-left-radius: 8px;
}

table tbody tr:first-child td:last-child {
	border-top-right-radius: 8px;
}

table tbody tr:last-child td:first-child {
	border-bottom-left-radius: 8px;
}

table tbody tr:last-child td:last-child {
	border-bottom-right-radius: 8px;
}
</style>
