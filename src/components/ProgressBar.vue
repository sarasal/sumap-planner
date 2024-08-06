<template>
  <b-progress :max="max" height="30px" :animated="animated">
    <b-progress-bar :value="value + finished" height="30px" variant="success" >
      <span>Finished: <strong>{{ value + finished}} / {{ max }}</strong></span>
    </b-progress-bar>
    <b-progress-bar :value="1-finished" variant="warning">
      <span>Current: <strong>{{ value + 1 }}</strong></span>
    </b-progress-bar>
  </b-progress>
</template>

<script>
export default {
  name: "ProgressBar",
  props:{
    animated:{
      type: Boolean,
      default: false,
    },
    max: {
      type: Number,
      required: true,
    },
    value: {
      type: Number,
      required: true
    },
    finished: {
      type: Number,
      required: false,
      default: 0,
    }
  },
}
</script>