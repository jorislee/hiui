<template>
	<n-config-provider :theme-overrides="themeOverrides" class="login">
		<img style="width: 400px; height: 480px; background: #253554" src="./assets/login-logo.png" />
		<div class="login-input">
			<div style="font-size: 24px">{{ $t('Login') }}</div>
			<n-form size="large" ref="formRef" :model="formValue" :rules="rules">
				<n-form-item path="username">
					<n-input v-model:value="formValue.username" size="medium" :placeholder="$t('Please enter username')">
						<template #prefix>
							<n-icon size="18" color="#808695">
								<UserCircle />
							</n-icon>
						</template>
					</n-input>
				</n-form-item>
				<n-form-item path="password">
					<n-input size="medium" v-model:value="formValue.password" :placeholder="$t('Please enter password')" type="password" show-password-on="mousedown">
						<template #prefix>
							<n-icon size="18" color="#808695">
								<Lock />
							</n-icon>
						</template>
					</n-input>
				</n-form-item>
				<n-form-item>
					<n-button type="info" block :loading="loading" @click="handleSubmit">{{ $t('Login') }}</n-button>
				</n-form-item>
			</n-form>
		</div>
	</n-config-provider>
</template>

<script setup>
import {UserCircle, Lock} from '@vicons/tabler';
const themeOverrides = {
	Button: {
		colorInfo: '#0052D9',
		textColorHover: '#0052D9',
		textColorFocus: '#0052D9',
		borderHover: '1px solid #0052D9',
		borderFocus: '1px solid #0052D9'
	},
	Input: {
		heightMedium: '48px',
		borderHover: '1px solid #0052D9',
		borderFocus: '1px solid #0052D9'
	}
};
const loading = ref(false);
const formRef = ref(null);
const {proxy} = getCurrentInstance();
const formValue = reactive({
	username: '',
	password: ''
});
const rules = reactive({});
function handleSubmit() {
	console.log(formRef);
	formRef.value?.validate(async (errors) => {
		if (errors) return;
		loading.value = true;
		try {
			await proxy.$hiui.login(formValue.username, formValue.password);
			proxy.$router.push('/');
		} catch {
			proxy.$message.error(proxy.$t('wrong username or password'));
		}
		loading.value = false;
	});
}
onMounted(() => {
	rules.username = {
		required: true,
		trigger: 'blur',
		message: proxy.$t('Please enter username')
	};
});
</script>

<style scoped>
.login {
	position: absolute;
	height: 100%;
	width: 100%;
	display: flex;
	justify-content: center;
	align-items: center;
	background: #f3f5f8;
}

.login-input {
	width: 400px;
	height: 480px;
	padding: 50px 40px 60px 40px;
	border-radius: 8px;
	/* S_渐变色 */
	background: linear-gradient(180deg, #f3f5f8 0%, #ffffff 99%);
	box-sizing: border-box;
	/* 纯白 */
	border: 2px solid #ffffff;
	transform: translateX(-5px);
}

.copyright {
	text-align: center;
	font-size: medium;
}

.copyright .n-a {
	font-size: 1.2em;
}
:deep(.n-input__input) {
	margin: 0 10px;
}
</style>

<i18n src="./locale.json" />
