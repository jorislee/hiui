<template>
	<n-space class="components-bg" vertical size="large" style="padding: 0 30px">
		<n-layout>
			<n-space align="center">
				<div class="circle"></div>
				<h2>{{ $t('Network Status') }}</h2>
			</n-space>
		</n-layout>
		<n-layout embedded>
			<n-space size="large" align="center" item-style="padding-top: 30px">
				<n-space vertical align="center" size="large">
					<img src="@/assets/router.png" height="157" />
					<div>{{ $t('Router') }}</div>
					<n-button type="default" @click="lanInfo('router')" class="bt-bg bt-w-300"></n-button>
				</n-space>
				<div></div>
				<n-space vertical align="center" size="large">
					<img src="@/assets/internal.png" height="157" />
					<div>{{ $t('Internal') }}</div>
					<n-button type="default" @click="lanInfo('internal')" class="bt-bg bt-w-120"></n-button>
				</n-space>
				<n-space vertical align="center" size="large" style="padding-bottom: 75px">
					<n-ellipsis style="max-width: 190px" :line-clamp="2">您可以开通互联网加速模块，以便更快速地访问互联网。</n-ellipsis>
					<n-button type="info" @click="lanInfo('speed')" color="#0052D9" round size="medium">{{ $t('开通加速') }}</n-button>
				</n-space>
			</n-space>
		</n-layout>
		<n-layout>成府路</n-layout>
	</n-space>
</template>
<script setup>
function lanInfo(params) {
	console.log(params);
}
</script>
<style scoped>
.circle {
	width: 8px;
	height: 8px;
	-moz-border-radius: 4px;
	-webkit-border-radius: 4px;
	border-radius: 4px;
	background: #1cc198;
}
.bt-bg {
	/* S_渐变色 */
	background: linear-gradient(180deg, #f3f5f8 0%, #ffffff 100%);
	box-sizing: border-box;

	/* White */
	border: 2px solid #ffffff;

	/* S_外投影 */
	box-shadow: -4px -4px 10px 0px #ffffff, 4px 4px 10px 0px rgba(55, 99, 170, 0.05);
}
.bt-w-300 {
	width: 300px;
	height: 48px;
	border-radius: 110px;
}
.bt-w-120 {
	width: 120px;
	height: 48px;
	border-radius: 110px;
}
</style>
<i18n src="./locale.json" />
