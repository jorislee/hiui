<template>
	<n-config-provider :theme-overrides="themeOverrides">
		<div>
			<div class="login">
				<img style="width: 400px; height: 480px; background: #253554" src="./assets/login-logo.png" alt="speedbox" />
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
							<n-input
								size="medium"
								v-model:value="formValue.password"
								:placeholder="$t('Please enter password')"
								type="password"
								show-password-on="mousedown"
								@keyup.enter="handleSubmit"
							>
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
			</div>
			<div class="copyright">
				<span>© 2021 SpeedBox版权所有</span>
				<n-divider vertical />
				<span class="copyright-icon">
					<n-icon size="large" :component="lg"></n-icon>
				</span>
				<n-popselect v-model:value="language" :options="languages" trigger="click" @update:value="setLocale">
					<n-button text ghost icon-placement="right">
						<template #icon>
							<n-icon size="small">
								<ChevronDownOutline />
							</n-icon>
						</template>
						{{ languageLabel }}
					</n-button>
				</n-popselect>
			</div>
		</div>
	</n-config-provider>
</template>

<script setup>
import {UserCircle, Lock} from '@vicons/tabler';
import {ChevronDownOutline, Language as lg} from '@vicons/ionicons5';
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

const titles = {
	'en-US': 'English',
	'ja-JP': '日本語',
	'zh-CN': '简体中文',
	'zh-TW': '繁體中文'
};
const language = ref(proxy.$hiui.state.locale);
const languageLabel = ref(titles[language.value] ?? 'Auto');
const languages = ref([]);

const localeOptions = () => {
	const options = proxy.$i18n.availableLocales.map((locale) => {
		let tmp = {
			label: titles[locale] ?? locale,
			value: locale
		};
		return tmp;
	});

	return options;
};

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

function setLocale(key) {
	languageLabel.value = titles[key];
	proxy.$i18n.locale = key;
}

onMounted(() => {
	rules.username = {
		required: true,
		trigger: 'blur',
		message: proxy.$t('Please enter username')
	};
	languages.value = localeOptions();
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
	position: absolute;
	left: 0;
	right: 0;
	bottom: 20px;
	text-align: center;
	vertical-align: center;
}

.copyright-icon {
	vertical-align: text-top;
	padding-right: 10px;
}

:deep(.n-input__input) {
	margin: 0 10px;
}
</style>

<i18n src="./locale.json" />
