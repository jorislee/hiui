<template>
	<div class="components-bg pd-30">
		<n-layout>
			<n-space align="center">
				<div class="circle"></div>
				<div class="font-24-size">{{ $t('Upgrade') }}</div>
			</n-space>
		</n-layout>
		<n-divider />
		<n-space vertical :size="20">
			<div class="flex-hor bg-color bg-border">
				<n-list class="width-fill pd-30">
					<template #header>
						<div class="font-18">{{ $t('Online information') }}</div>
					</template>
					<n-list-item>
						<n-thing :title="$t('Current version')" :title-extra="remoteFrimwareInfo.curVer" />
					</n-list-item>
					<n-list-item>
						<n-thing :title="$t('Compile time')" :title-extra="remoteFrimwareInfo.compileTime" />
					</n-list-item>
					<n-list-item>
						<template v-if="remoteFrimwareInfo.ver" #suffix>
							<n-button text ghost style="padding-bottom: 8px" text-color="#0052D9">{{ $t('download now') }}</n-button>
						</template>
						<n-thing :title="$t('The latest version of')" :title-extra="remoteFrimwareInfo.ver ?? remoteFrimwareInfo.curVer" />
					</n-list-item>
				</n-list>
				<n-divider vertical />

				<n-list class="width-fill pd-30">
					<template #header>
						<div class="font-18">{{ $t('Software information') }}</div>
					</template>
					<n-list-item>
						<n-thing :title="$t('Module name')" />
						<template #suffix>
							<n-select v-model:value="ipkInfo.name" size="small" :options="localWebUiInfo" @update:value="selectIpk" style="width: 180px" />
						</template>
					</n-list-item>
					<n-list-item>
						<n-thing :title="$t('Current version')" :title-extra="ipkInfo.curVer" />
					</n-list-item>

					<n-list-item>
						<template v-if="ipkInfo.remoteVer > ipkInfo.curVer" #suffix>
							<n-button text ghost style="padding-bottom: 8px" @click="ipkUpgrade">{{ remoteWebUiInfo.lenght > 6 ? $t('update all') : $t('update immediately') }}</n-button>
						</template>
						<n-thing :title="$t('Remote version')" :title-extra="ipkInfo.remoteVer" />
					</n-list-item>
				</n-list>
			</div>
			<div class="bg-border bg-color pd-30">
				<div v-if="progress > 0 && progress < 100">
					<n-progress type="line" :percentage="progress" :indicator-placement="'inside'" processing />
				</div>
				<n-space vertical v-else>
					<div class="font-18">{{ $t('local upload') }}</div>
					<n-upload
						ref="upload"
						directory-dnd
						action="/hiui-upload"
						:data="{path: '/tmp/firmware.bin'}"
						:on-finish="onUploadFinish"
						:show-file-list="false"
						:max="1"
						:on-change="uploadProgress"
					>
						<n-upload-dragger class="upload-bg">
							<div>
								<n-icon size="48"><arrow-up-circle-icon /></n-icon>
							</div>
							<n-text style="font-size: 16px">{{ $t('Click or drag files to this area to upload') }}</n-text>
						</n-upload-dragger>
					</n-upload>
				</n-space>
			</div>
			<div v-if="progress === 100" class="bg-border pd-30">
				<n-list class="width-fill">
					<template #header>
						<div class="font-18">{{ $t('Firmware verification') }}</div>
					</template>
					<n-list-item>
						<n-thing :title="$t('Version')" :title-extra="remoteFrimwareInfo.ver" />
					</n-list-item>
					<n-list-item>
						<n-thing :title="$t('MD5')" :title-extra="md5" />
					</n-list-item>
					<n-list-item>
						<n-thing :title="$t('Validation results')" :title-extra="verification" />
					</n-list-item>
					<n-list-item>
						<template #suffix>
							<n-switch v-model:value="keepConfig" size="medium" />
						</template>
						<n-thing :title="$t('Save configuration')" />
					</n-list-item>
				</n-list>
				<div style="padding-top: 20px">
					<n-button v-if="modalConfirm" type="info" size="large" style="width: 100%" @click="firmwareUpgrade">{{ $t('Upgrade') }}</n-button>
				</div>
			</div>
		</n-space>
	</div>

	<!-- <n-modal v-model:show="modalConfirm" preset="dialog" :title="$t('Upgrade')" :positive-text="$t('OK')" :negative-text="$t('Cancel')" @positive-click="doUpgrade">
		<n-space vertical>
			<p>{{ $t('flash-confirm', {btn: this.$t('OK')}) }}</p>
			<n-text type="info">{{ this.$t('Size') + ': ' + bytesToHuman(this.size) }}</n-text>
			<n-text type="info">{{ 'MD5: ' + this.md5 }}</n-text>
			<n-checkbox v-model:checked="keepConfig">{{ $t('Keep settings and retain the current configuration') }}</n-checkbox>
		</n-space>
	</n-modal> -->
	<n-modal v-model:show="modalSpin" :close-on-esc="false" :mask-closable="false">
		<n-spin size="large">
			<template #description>
				<div style="color: var(--primary-color)">{{ $t('Upgrading') }}...</div>
			</template>
		</n-spin>
	</n-modal>
</template>

<script setup>
import {ArrowUpCircle as ArrowUpCircleIcon} from '@vicons/ionicons5';
const {proxy} = getCurrentInstance();
const upload = ref(null);
const modalConfirm = ref(false);
const modalSpin = ref(false);
const size = ref(0);
const md5 = ref('');
const keepConfig = ref(true);
const remoteFrimwareInfo = reactive({});
const remoteWebUiInfo = ref([]);
const localWebUiInfo = ref([]);
const verification = ref(false);
const progress = ref(0);
const ipkInfo = reactive({});

function bytesToHuman(bytes) {
	if (isNaN(bytes)) {
		return '';
	}

	if (bytes < 0) {
		return '';
	}

	let units = '';

	const k = Math.floor(Math.log2(bytes) / 10);
	if (k > 0) units = 'KMGTPEZY'[k - 1] + 'iB';

	return (bytes / Math.pow(1024, k)).toFixed(2) + ' ' + units;
}

function selectIpk(params, option) {
	ipkInfo.curVer = option.ver;
	remoteWebUiInfo.value?.forEach((item) => {
		if (item.name === params) {
			ipkInfo.remoteVer = item.curVer;
			if (params === 'hiui-rpc-core') {
				if (item.downloadUrl.includes(ipkInfo.arch)) {
					ipkInfo.downloadUrl = item.downloadUrl;
				}
			} else {
				ipkInfo.downloadUrl = item.downloadUrl;
			}
		}
	});
}

function ipkUpgrade() {
	let params = [];
	if (params === 'all') {
		remoteWebUiInfo.value?.forEach((item) => {
			if (params === 'hiui-rpc-core') {
				if (item.downloadUrl.includes(ipkInfo.arch)) {
					params.push(item.downloadUrl);
				}
			} else {
				params.push(item.downloadUrl);
			}
		});
	} else {
		params.push(ipkInfo.downloadUrl);
	}
	proxy.$hiui.call('upgrade', 'ipkUpgrade', params).then((result) => {});
}

function onUploadFinish({event, file}) {
	const response = JSON.parse(event.target.response);
	size.value = response.size;
	md5.value = response.md5;
	console.log(file);
	upload.value.clear();

	proxy.$hiui.ubus('system', 'validate_firmware_image', {path: '/tmp/firmware.bin'}).then(({valid}) => {
		verification.value = valid;
		if (!valid) {
			proxy.$dialog.error({
				content: proxy.$t('Firmware verification failed. Please upload the firmware again')
			});
		} else {
			keepConfig.value = true;
			modalConfirm.value = true;
		}
	});
}
function firmwareUpgrade() {
	proxy.$hiui.call('system', 'sysupgrade', {keep: keepConfig.value}).then(() => {
		modalSpin.value = true;
		proxy.$hiui.reconnect().then(() => {
			proxy.$router.push('/login');
		});
	});
}

function uploadProgress({file}) {
	progress.value = file.percentage;
}

onBeforeMount(() => {
	proxy.$hiui.call('upgrade', 'checkFirmwareVersion').then((result) => {
		console.log(result);
		remoteFrimwareInfo.curVer = result.curVer;
		remoteFrimwareInfo.compileTime = result.compileTime;
		remoteFrimwareInfo.ver = result.ver;
	});
	proxy.$hiui.call('upgrade', 'checkWebVersion').then((result) => {
		console.log(result);
		result.loc?.forEach((item) => {
			let tmp = {};
			tmp.value = item.name;
			tmp.label = item.name;
			tmp.ver = item.curVer;
			localWebUiInfo.value.push(tmp);
		});
		ipkInfo.name = localWebUiInfo.value[0].label;
		ipkInfo.curVer = localWebUiInfo.value[0].ver;
		ipkInfo.arch = result.arch;
		remoteWebUiInfo.value = result.remote;
		remoteWebUiInfo.value?.forEach((item) => {
			if (item.name === ipkInfo.name) {
				ipkInfo.remoteVer = item.curVer;
			}
		});
	});
});
</script>
<style scoped>
.upload-bg {
	border-radius: 8px;
	background: #ffffff;
	border: 1px dashed rgba(73, 87, 112, 0.15);
	box-shadow: -4px -4px 10px 0px rgba(255, 255, 255, 0.3), 4px 4px 10px 0px rgba(55, 99, 170, 0.1);
}
</style>

<i18n src="./locale.json" />
