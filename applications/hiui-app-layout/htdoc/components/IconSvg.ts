import {defineComponent, resolveComponent, h} from 'vue';
export const IconSvg = defineComponent({
	props: {
		opt: {
			type: Object
		}
	},
	setup(props) {
		function renderSvg(el: string, opt: Record<string, any>) {
			const props = {};
			let children = [];
			Object.keys(opt).forEach((key) => {
				if (key.startsWith('-')) {
					props[key.substring(1)] = opt[key];
				} else {
					if (Array.isArray(opt[key])) opt[key].forEach((item) => children.push(renderSvg(key, item)));
					else children.push(renderSvg(key, opt[key]));
				}
			});
			return h(el, props, children);
		}
		return () => h(resolveComponent('n-icon'), () => renderSvg('svg', props.opt ?? {}));
	}
});
