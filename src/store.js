import Vue from 'vue';

export const store = Vue.observable({
    appConfig: {}
});

export const mutations = {
    setAppConfig(config) {
        store.appConfig = config;
    },
};