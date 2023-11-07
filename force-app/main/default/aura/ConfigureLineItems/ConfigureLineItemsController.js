({
    doInit: function (component, event, helper) {
        debugger;
        helper.getFeatureList(component);
        //helper.getProductOption(component);
        helper.handleClickSelect(component);
    },
    handleClickSave:function (component, event, helper) {
        debugger;
        helper.handleSaveProduct(component);
    }
});