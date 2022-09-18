import hiui from '../hiui';
import {
	NA,
	NBackTop,
	NButton,
	NCard,
	NCheckbox,
	NConfigProvider,
	NDataTable,
	NDescriptions,
	NDescriptionsItem,
	NDialogProvider,
	NDivider,
	NDropdown,
	NEl,
	NEllipsis,
	NForm,
	NFormItem,
	NH2,
	NH3,
	NIcon,
	NInput,
	NLayout,
	NLayoutContent,
	NLayoutFooter,
	NLayoutHeader,
	NLayoutSider,
	NList,
	NListItem,
	NMessageProvider,
	NModal,
	NPageHeader,
	NProgress,
	NRadioButton,
	NRadioGroup,
	NSelect,
	NSpace,
	NSpin,
	NSwitch,
	NTag,
	NText,
	NThing,
	NTooltip,
	NUpload,
	NUploadDragger,
	NTime,
	NTimePicker,
	NUploadTrigger,
	NUploadFileList,
	create,
	darkTheme,
	createDiscreteApi
} from 'naive-ui';

const naive = create({
	components: [
		NA,
		NBackTop,
		NButton,
		NCard,
		NCheckbox,
		NConfigProvider,
		NDataTable,
		NDescriptions,
		NDescriptionsItem,
		NDialogProvider,
		NDivider,
		NDropdown,
		NEl,
		NEllipsis,
		NForm,
		NFormItem,
		NH2,
		NH3,
		NIcon,
		NInput,
		NLayout,
		NLayoutContent,
		NLayoutFooter,
		NLayoutHeader,
		NLayoutSider,
		NList,
		NListItem,
		NMessageProvider,
		NModal,
		NPageHeader,
		NProgress,
		NRadioButton,
		NRadioGroup,
		NSelect,
		NSpace,
		NSpin,
		NSwitch,
		NTag,
		NText,
		NThing,
		NTooltip,
		NUpload,
		NUploadDragger,
		NTag,
		NTime,
		NTimePicker,
		NTooltip,
		NUpload,
		NUploadDragger,
		NUploadTrigger,
		NUploadFileList
	]
});
const {message, notification, dialog, loadingBar} = createDiscreteApi(['message', 'dialog', 'notification', 'loadingBar'], {
	configProviderProps: computed(() => ({
		theme: hiui.state.theme === 'light' ? undefined : darkTheme
	}))
});
export default {
	install(app) {
		app.config.globalProperties.$message = message;
		app.config.globalProperties.$notification = notification;
		app.config.globalProperties.$dialog = dialog;
		app.config.globalProperties.$loadingBar = loadingBar;
		app.use(naive);
	}
};
