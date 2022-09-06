<template>
	<n-space class="components-bg pd-30" vertical size="large">
		<n-layout>
			<n-space align="center">
				<div class="circle"></div>
				<div class="font-24-size">{{ $t('Network Status') }}</div>
			</n-space>
		</n-layout>
		<n-divider />
		<n-layout embedded>
			<n-space size="large" item-style="padding-top: 30px">
				<n-space vertical align="center" size="large">
					<img src="@/assets/router.png" height="157" />
					<div>{{ $t('Router') }}</div>
					<n-button type="default" @click="lanInfo('router')" class="bt-bg bt-w-300">
						<div class="circle"></div>
						<span>&ensp;5G:dddd</span>
						<n-divider vertical />

						<div class="circle"></div>
						<span>&ensp;2.4G:dddd</span>
					</n-button>
				</n-space>
				<div style="width: 170px">
					<img v-if="conLocal" src="@/assets/connect-success.svg" alt="" />
					<n-divider v-else style="padding-top: 55px" />
				</div>
				<n-space vertical align="center" size="large">
					<img src="@/assets/internal.png" height="157" />
					<div>{{ $t('Internal') }}</div>
					<n-button type="default" @click="lanInfo('internal')" class="bt-bg bt-w-120">
						<div class="circle"></div>
						<span>&ensp;dddd</span>
					</n-button>
				</n-space>
				<div style="width: 170px">
					<img v-if="conLocal" src="@/assets/connect-success.svg" alt="" />
					<n-divider v-else style="padding-top: 55px" />
				</div>
				<div>
					<n-space v-if="conSpeed" vertical align="center" size="large">
						<img src="@/assets/speedserver.png" height="157" />
						<div>{{ $t('Internal') }}</div>
						<n-button ghost round type="info" @click="lanInfo('internal')">{{ $t('设置') }}</n-button>
					</n-space>
					<n-space v-else vertical align="center" size="large" style="padding-top: 40px">
						<n-ellipsis style="max-width: 190px" :line-clamp="2">您可以开通互联网加速模块，以便更快速地访问互联网。</n-ellipsis>
						<n-button type="info" @click="lanInfo('speed')" color="#0052D9" round size="medium">{{ $t('开通加速') }}</n-button>
					</n-space>
				</div>
			</n-space>
		</n-layout>
		<n-layout>
			<the-lan-info v-if="infoType === 1"></the-lan-info>
			<the-wan-connect v-else-if="infoType === 2"></the-wan-connect>
		</n-layout>
	</n-space>
</template>
<script setup>
import TheLanInfo from './components/TheLanInfo.vue';
import TheWanConnect from './components/TheWanConnect.vue';

const conLocal = ref(false);
const conSpeed = ref(true);
const infoType = ref(2);
function lanInfo(params) {
	console.log(params);
}
</script>
<style scoped>
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
