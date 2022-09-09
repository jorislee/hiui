<template>
	<div class="components-bg-dark pd-30" vertical>
		<n-layout>
			<n-space align="center">
				<div class="circle"></div>
				<div class="font-24-size">{{ $t('Network Status') }}</div>
			</n-space>
		</n-layout>
		<n-divider />
		<n-space vertical :size="20">
			<div class="dis-flex-hor bg-color-dark bg-border-dark">
				<n-space vertical style="width: 100%" class="pd-30" size="large">
					<div class="font-18-size">{{ $t('管理员密码') }}</div>
					<n-input v-model:value="oldpd" type="password" placeholder="必填" size="medium" show-password-on="mousedown" :minlenght="8">
						<template #suffix>
							<div style="padding: 0 8px 0 0; color: #98a3b7">{{ $t('password') }}</div>
						</template>
					</n-input>
					<n-input v-model:value="newpd" type="password" placeholder="必填" size="medium" show-password-on="mousedown" @keydown.enter.prevent>
						<template #suffix>
							<div style="padding: 0 8px 0 0; color: #98a3b7">{{ $t('new password') }}</div>
						</template>
					</n-input>
					<n-form-item :rule="verifyPd" :show-label="false" :show-feedback="false">
						<n-input v-model:value="newpd1" type="password" placeholder="必填" size="medium" show-password-on="mousedown" @keydown.enter.prevent>
							<template #suffix>
								<div style="padding: 0 8px 0 0; color: #98a3b7">{{ $t('again new password') }}</div>
							</template>
						</n-input>
					</n-form-item>
					<n-button type="info" size="medium" round>{{ $t('save') }}</n-button>
				</n-space>
				<div class="pd-30"></div>
				<n-space justify="center" style="width: 100%" class="pd-30">
					<img src="@/assets/setting.png" />
				</n-space>
			</div>
			<n-space vertical class="bg-color-dark bg-border-dark pd-30" :size="15">
				<div class="font-18-size">{{ $t('Reset to defaults') }}</div>
				<div>
					<n-space class="tips-info-bg">
						<img src="@/assets/info.svg" />
						<div>
							<div>1、如果设备出现无法解法的故障，你可以选择恢复到出厂默认设置。</div>
							<div>2、恢复到出厂设置后，你当前的所有设置、应用程序和数据都将丢失。</div>
							<div>3、恢复过程大约需要3分钟，在恢复过程中不要让路由器断电。</div>
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
const oldpd = ref('');
const newpd = ref('');
const newpd1 = ref('');
const message = '它不在 Form 里面';
const verifyPd = {
	trigger: ['input', 'blur'],
	validator() {
		if (newpd.value !== newpd1.value) {
			return new Error(message);
		}
	}
};
function doReset() {
	// this.$dialog.warning({
	// 	title: this.$t('Reset to defaults'),
	// 	content: this.$t('ResettConfirm') + '?',
	// 	positiveText: this.$t('OK'),
	// 	onPositiveClick: () => {
	// 		this.$hiui.ubus('system', 'reset').then(() => {
	// 			this.modalSpin = true;
	// 			this.$hiui.reconnect().then(() => {
	// 				this.modalSpin = false;
	// 				this.$router.push('/login');
	// 			});
	// 		});
	// 	}
	// });
}
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
	--n-height: 48px;
}
.__input-m {
	--n-height: 48px;
}
</style>

<i18n src="./locale.json" />
