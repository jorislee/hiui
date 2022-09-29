<template>
	<n-el style="background-color: #f5f7fa; opacity: 0.8; width: 100%">
		<div class="login">
			<img src="./assets/login-logo.jpg" />
			<n-form size="large" ref="form" :model="formValue" :rules="rules">
				<n-form-item path="username">
					<n-input v-model:value="formValue.username" :placeholder="$t('Please enter username')">
						<template #prefix>
							<n-icon size="18" color="#808695">
								<person-outline />
							</n-icon>
						</template>
					</n-input>
				</n-form-item>
				<n-form-item path="password">
					<n-input v-model:value="formValue.password" :placeholder="$t('Please enter password')" type="password" show-password-on="mousedown">
						<template #prefix>
							<n-icon size="18" color="#808695">
								<lock-closed-outline />
							</n-icon>
						</template>
					</n-input>
				</n-form-item>
				<n-form-item>
					<n-button type="primary" block :loading="loading" @click="handleSubmit">{{ $t('Login') }}</n-button>
				</n-form-item>
			</n-form>
		</div>
	</n-el>
</template>

<script setup>
import {PersonOutline, LockClosedOutline} from '@vicons/ionicons5';
const loading = false;
const formValue = {
	username: '',
	password: ''
};
const rules = {
	username: {
		required: true,
		trigger: 'blur',
		message: () => this.$t('Please enter username')
	}
};
function handleSubmit() {
	this.$refs.form.validate(async (errors) => {
		if (errors) return;

		this.loading = true;

		try {
			await this.$hiui.login(this.formValue.username, this.formValue.password);
			this.$router.push('/');
		} catch {
			this.$message.error(this.$t('wrong username or password'));
		}

		this.loading = false;
	});
}
</script>

<style scoped>
.login {
	position: absolute;
	height: 100%;
	width: 100%;
	display: flex;
}

.copyright {
	text-align: center;
	font-size: medium;
}

.copyright .n-a {
	font-size: 1.2em;
}
</style>

<i18n src="./locale.json" />
