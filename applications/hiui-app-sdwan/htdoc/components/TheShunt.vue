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

const enode = ref('test');
const ruleNum = ref('');

const data = Array.apply(null, {length: 987}).map((_, index) => {
	return {
		column1: index,
		column2: (index % 2) + 1,
		column3: 'a' + index
	};
});

function query(page, pageSize = 10, order = 'ascend', filterValues = []) {
	return new Promise((resolve) => {
		const copiedData = data.map((v) => v);
		const orderedData = order === 'descend' ? copiedData.reverse() : copiedData;
		const filteredData = filterValues.length ? orderedData.filter((row) => filterValues.includes(row.column2)) : orderedData;
		const pagedData = filteredData.slice((page - 1) * pageSize, page * pageSize);
		const total = filteredData.length;
		const pageCount = Math.ceil(filteredData.length / pageSize);
		setTimeout(
			() =>
				resolve({
					pageCount,
					data: pagedData,
					total
				}),
			1500
		);
	});
}
const dataRef = ref([]);
const loadingRef = ref(true);
const columnsRef = ref(columns);
const paginationReactive = reactive({
	page: 1,
	pageCount: 1,
	pageSize: 10,
	showQuickJumper: true
});

onMounted(() => {
	query(paginationReactive.page, paginationReactive.pageSize).then((data) => {
		// dataRef.value = data.data;
		paginationReactive.pageCount = data.pageCount;
		paginationReactive.itemCount = data.total;
		loadingRef.value = false;
	});
});
function rowKey(rowData) {
	return rowData.column1;
}
function handleSorterChange(sorter) {
	if (!sorter || sorter.columnKey === 'column1') {
		if (!loadingRef.value) {
			loadingRef.value = true;
			query(paginationReactive.page, paginationReactive.pageSize, !sorter ? false : sorter.order).then((data) => {
				dataRef.value = data.data;
				paginationReactive.pageCount = data.pageCount;
				paginationReactive.itemCount = data.total;
				loadingRef.value = false;
			});
		}
	}
}
function handleFiltersChange(filters) {
	if (!loadingRef.value) {
		loadingRef.value = true;
		const filterValues = filters.column2 || [];
		query(paginationReactive.page, paginationReactive.pageSize, filterValues).then((data) => {
			dataRef.value = data.data;
			paginationReactive.pageCount = data.pageCount;
			paginationReactive.itemCount = data.total;
			loadingRef.value = false;
		});
	}
}
function handlePageChange(currentPage) {
	if (!loadingRef.value) {
		loadingRef.value = true;
		query(currentPage, paginationReactive.pageSize).then((data) => {
			dataRef.value = data.data;
			paginationReactive.page = currentPage;
			paginationReactive.pageCount = data.pageCount;
			paginationReactive.itemCount = data.total;
			loadingRef.value = false;
		});
	}
}
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
