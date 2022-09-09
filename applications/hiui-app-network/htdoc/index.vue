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
			<n-space size="large" item-style="padding-top: 30px;" justify="space-between">
				<n-space vertical align="center" size="large">
					<img src="@/assets/router.png" height="157" />
					<div>{{ $t('Router') }}</div>
					<n-button type="default" @click="lanInfo('router')" class="bt-bg">
						<div class="circle"></div>
						<span>&ensp;5G:dddddfsfsdfs</span>
						<n-divider vertical />
						<div class="circle"></div>
						<span>&ensp;2.4G:ddddsfsdfsf</span>
					</n-button>
				</n-space>
				<div>
					<img v-if="conLocal" src="@/assets/connect-success.svg" />
					<div class="line" v-else></div>
				</div>
				<n-space vertical align="center" size="large">
					<img src="@/assets/internal.png" height="157" />
					<div>{{ $t('Internal') }}</div>
					<n-button type="default" @click="lanInfo('internal')" class="bt-bg">
						<div class="circle"></div>
						<span>&ensp;dddd</span>
					</n-button>
				</n-space>
				<div>
					<img v-if="conLocal" src="@/assets/connect-success.svg" />
					<div class="line" v-else></div>
				</div>
				<div style="width: 25%">
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

const conLocal = ref(true);
const conSpeed = ref(true);
const infoType = ref(2);
function lanInfo(params) {
	console.log(params);
}
</script>
<style scoped>
.line {
	width: 100%;
	height: 1px;
	border-top: 1px solid rgba(73, 87, 112, 0.15);
	padding-top: 55px;
}
.bt-bg {
	background: linear-gradient(180deg, #f3f5f8 0%, #ffffff 100%);
	box-sizing: border-box;
	border: 2px solid #ffffff;
	box-shadow: -4px -4px 10px 0px #ffffff, 4px 4px 10px 0px rgba(55, 99, 170, 0.05);
	width: 100%;
	height: 48px;
	border-radius: 110px;
	padding: 0 20px;
}
</style>
<i18n src="./locale.json" />
