<template>
	<div class="components-bg pd-30" vertical>
		<n-layout>
			<n-space align="center">
				<div class="circle"></div>
				<div class="font-24-size">{{ $t('Settings') }}</div>
			</n-space>
		</n-layout>
		<n-divider />
		<n-space vertical :size="20">
			<div class="flex-hor-ac bg-color bg-border">
				<n-space vertical style="width: 100%" class="pd-30" size="large">
					<div class="font-18-size">{{ $t('Administrator password') }}</div>
					<n-input v-model:value="oldpd" type="password" placeholder="$t('Must -have')" show-password-on="mousedown" :minlenght="8">
						<template #suffix>
							<div style="padding: 0 8px 0 0; color: #98a3b7">{{ $t('password') }}</div>
						</template>
					</n-input>
					<n-input v-model:value="newpd" type="password" placeholder="$t('Must -have')" show-password-on="mousedown" @keydown.enter.prevent>
						<template #suffix>
							<div style="padding: 0 8px 0 0; color: #98a3b7">{{ $t('new password') }}</div>
						</template>
					</n-input>
					<n-form-item :rule="verifyPd" :show-label="false" :show-feedback="false">
						<n-input v-model:value="newpd1" type="password" placeholder="必填" show-password-on="mousedown" @keydown.enter.prevent>
							<template #suffix>
								<div style="padding: 0 8px 0 0; color: #98a3b7">{{ $t('again new password') }}</div>
							</template>
						</n-input>
					</n-form-item>
					<n-button type="info" size="medium" round @click="changePassword" :disabled="!verifyPd.validator()">{{ $t('save') }}</n-button>
				</n-space>
				<div class="pd-30"></div>
				<n-space justify="center" style="width: 100%" class="pd-30">
					<img src="@/assets/setting.png" />
				</n-space>
			</div>
			<n-space vertical class="bg-color bg-border pd-30" :size="15">
				<div class="font-18-size">{{ $t('Reset to defaults') }}</div>
				<div>
					<n-space class="tips-info-bg">
						<img src="@/assets/info.svg" />
						<div>
							<div>{{ $t('setting-tips1') }}</div>
							<div>{{ $t('setting-tips2') }}</div>
							<div>{{ $t('setting-tips3') }}</div>
						</div>
					</n-space>
				</div>
				<n-button round type="info" @click="doReset">{{ $t('Perform reset') }}</n-button>
			</n-space>
		</n-space>
	</div>
	<n-modal v-model:show="modalSpin" :close-on-esc="false" :mask-closable="false">
		<n-spin size="large">
			<template #description>
				<n-el style="color: var(--primary-color)">{{ $t('Rebooting') }}...</n-el>
			</template>
		</n-spin>
	</n-modal>
</template>

<script setup>
const {proxy} = getCurrentInstance();
const dialog = proxy.$dialog;
let user;
const oldpd = ref('');
const newpd = ref('');
const newpd1 = ref('');
const modalSpin = ref(false);
const verifyPd = {
	trigger: ['input', 'blur'],
	validator() {
		if (newpd.value === newpd1.value && newpd.value !== '') {
			return true;
		}
		if (newpd.value !== newpd1.value) {
			return false;
		}
	}
};

function changePassword() {
	proxy.$hiui
		.call('user', 'change_password', {
			oldpassword: oldpd.value,
			password: newpd1.value,
			id: user.id
		})
		.then((result) => {
			if (result.code !== 0) {
				proxy.$message.error(result.message);
			} else {
				proxy.$message.success(proxy.$t('success'));
			}
		});
}

function doReset() {
	dialog.warning({
		title: proxy.$t('Reset to defaults'),
		content: proxy.$t('ResettConfirm') + '?',
		positiveText: proxy.$t('comfirm reset'),
		onPositiveClick: () => {
			proxy.$hiui.ubus('system', 'reset').then(() => {
				modalSpin.value = true;
				proxy.$hiui.reconnect().then(() => {
					modalSpin.value = false;
					proxy.$router.push('/login');
				});
			});
		}
	});
}
onMounted(() => {
	proxy.$hiui.call('user', 'get_users').then(({users}) => {
		users.forEach((element) => {
			if (element.username === proxy.$hiui.username) {
				user = element;
			}
		});
	});
});
onBeforeMount(() => {});
</script>

<style scoped>
.font-18-size {
	font-size: 18px;
	font-weight: 500;
}
.tips-info-bg {
	padding: 20px;
	align-self: stretch;
	border-radius: 4px;
	background: rgba(0, 82, 217, 0.08);
}
.__input-dark-m {
	--n-height: 48px !important;
}
.__input-m {
	--n-height: 48px !important;
}
</style>

<i18n src="./locale.json" />
