<template>
	<n-space class="components-bg pd-30" vertical>
		<n-layout>
			<n-space align="center">
				<div class="circle"></div>
				<div class="font-24-size">{{ $t('Upgrade') }}</div>
			</n-space>
		</n-layout>
		<n-divider />
		<div class="flex-hor bg-color bg-border">
			<n-list class="width-fill pd-30">
				<template #header>
					<div class="font-18">{{ $t('线上信息') }}</div>
				</template>
				<n-list-item>
					<n-thing :title="$t('当前版本')" :title-extra="remoteFrimwareInfo.curVer" />
				</n-list-item>
				<n-list-item>
					<n-thing :title="$t('编译时间')" :title-extra="remoteFrimwareInfo.compileTime" />
				</n-list-item>
				<n-list-item>
					<template v-if="remoteFrimwareInfo.ver" #suffix>
						<n-button text ghost style="padding-bottom: 8px" text-color="#0052D9">{{ $t('立即下载') }}</n-button>
					</template>
					<n-thing :title="$t('最新版本')" :title-extra="remoteFrimwareInfo.ver ?? remoteFrimwareInfo.curVer" />
				</n-list-item>
			</n-list>
			<n-divider vertical />

			<n-list class="width-fill pd-30">
				<template #header>
					<div class="font-18">{{ $t('软件信息') }}</div>
				</template>
				<n-list-item>
					<n-thing :title="$t('当前版本')" :title-extra="remoteWebUiInfo.curVer" />
				</n-list-item>
				<n-list-item>
					<n-thing :title="$t('CPU 架构')" :title-extra="remoteWebUiInfo.arch" />
				</n-list-item>
				<n-list-item>
					<template v-if="remoteWebUiInfo.ver" #suffix>
						<n-button text ghost>{{ $t('立即更新') }}</n-button>
					</template>
					<n-thing :title="$t('远程版本')" :title-extra="remoteWebUiInfo.ver" />
				</n-list-item>
			</n-list>
		</div>
		<div class="bg-border pd-30">
			<div v-if="progress > 0 && progress < 100">
				<n-progress type="line" :percentage="progress" :indicator-placement="'inside'" processing />
			</div>
			<div v-else>
				<h2>{{ $t('local upload') }}</h2>
				<n-upload ref="upload" directory-dnd action="/hiui-upload" :data="{path: '/tmp/firmware.bin'}" :on-finish="onUploadFinish" :show-file-list="false" :max="1" :on-change="handleChange">
					<n-upload-dragger>
						<div>
							<n-icon size="48"><arrow-up-circle-icon /></n-icon>
						</div>
						<n-text style="font-size: 16px">{{ $t('Click or drag files to this area to upload') }}</n-text>
					</n-upload-dragger>
				</n-upload>
			</div>
		</div>
		<div v-if="progress === 100" class="bg-border pd-30">
			<n-list class="width-fill">
				<template #header>
					<div class="font-18">{{ $t('固件验证') }}</div>
				</template>
				<n-list-item>
					<n-thing :title="$t('版本')" :title-extra="remoteFrimwareInfo.ver" />
				</n-list-item>
				<n-list-item>
					<n-thing :title="$t('MD5')" :title-extra="md5" />
				</n-list-item>
				<n-list-item>
					<n-thing :title="$t('验证结果')" :title-extra="verification" />
				</n-list-item>
				<n-list-item>
					<template #suffix>
						<n-switch v-model:value="keepConfig" size="medium" />
					</template>
					<n-thing :title="$t('保存配置')" />
				</n-list-item>
			</n-list>
			<n-button v-if="modalConfirm" type="info" size="large" @click="doUpgrade" style="width: 100%; padding-top: 20px">{{ $t('Upgrade') }}</n-button>
		</div>
	</n-space>

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
const remoteWebUiInfo = reactive({});
const verification = ref(false);
const progress = ref(0);
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
function doUpgrade() {
	proxy.$hiui.call('system', 'sysupgrade', {keep: keepConfig.value}).then(() => {
		modalSpin.value = true;
		proxy.$hiui.reconnect().then(() => {
			proxy.$router.push('/login');
		});
	});
}

function handleChange({file}) {
	progress.value = file.percentage;
	console.log(progress.value);
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
		remoteWebUiInfo.curVer = result.curVer;
		remoteWebUiInfo.arch = result.arch;
		remoteWebUiInfo.ver = result.ver;
	});
});
</script>

<i18n src="./locale.json" />
