import {NIcon, NSpace, NButton, NSwitch, NDynamicTags, create} from 'naive-ui';

const naive = create({
	components: [NIcon, NSpace, NButton, NSwitch, NDynamicTags]
});

export default {
	install(app) {
		app.use(naive);
	}
};
