<template>
  <b-container class="container">
    <b-card :img-src="require('@/assets/delivery_planner.jpeg')"
            img-alt="Image"
            img-height="500rem"
            img-top
            class="card"
            title="Plan your delivery with us!">

      <b-card-text>
        {{greeting}}
      </b-card-text>

      <b-card-text>
        Our study aims to gain new insights into how humans collaborate with AI systems in the area of logistical planning.
      </b-card-text>

<!--      <b-card-text class="indent">-->
<!--        This study is divided into four sessions over two weeks. You are currently in the {{current_session}} session.-->
<!--        We reward you for participating in all sessions in addition to the normal reimbursement. The reimbursement for-->
<!--        each completed session will be <b> [X] </b>, and the additional “return” bonus will be <b> [X] </b>.-->
<!--      </b-card-text>-->

      <b-card-text class="indent">
        You will be asked to solve five delivery tasks (details on the task will follow on the next pages).
        For each task, there is a best answer from the five given options. The better you perform, the higher the additional task bonus will be.
        This bonus is paid *in addition to* the base payment you will receive on successful completion.
      </b-card-text>

      <b-card-text class="indent">
        We would like to draw your attention to the following important points:
      </b-card-text>

      <b-card-text class="indent">
        <b>For an optimal study experience, please maximize the size of your browser window.</b>
      </b-card-text>

      <b-card-text class="indent">
        During the experiment, please refrain from clicking the <b>*** BACK ***</b> button in your browser. Instead, use the <b>*** NEXT ***</b> buttons provided in the interface.
      </b-card-text>

      <b-card-text class="indent">
        In the study, we will also gather information about your experience with the system. We encourage you to respond to all questions truthfully and to the best of your knowledge and ability.
      </b-card-text>


      <b-card-text>
        Completing this study session will take approximately <b>*** 15 - 20  ***</b> minutes.
      </b-card-text>
      <b-row align-h="end">
        <b-col cols="2">
          <b-button @click="gotoConsentForm()" variant="success">Continue</b-button>
        </b-col>

      </b-row>
<!--      <b-button class="mt-2" align-h="around"  @click="gotoConsentForm()" variant="success">Continue</b-button>-->
    </b-card>

  </b-container>
</template>

<script>

import {store} from "@/store";

export default {
  name: "Introduction",
  data() {
    return {
      greeting: store.appConfig.GREETING_TEXT,
      current_session: store.appConfig.CURRENT_SESSION_NUMBER_TEXT,
    }
  },
  methods: {
    gotoConsentForm: async function (){
      let url = '/consent-form';
      await this.$router.push(url);
    },
  },
  mounted: async function() {
    localStorage.clear();
  }
}
</script>

<style scoped>
.card{
  max-width: 70rem;
  margin-top: 0px;
  left:3%;
  border: 1px solid rgba(0, 0, 0, 0.125);
}

.card img{
  object-fit: cover;
}

.container{
  text-align: left;
  margin-top: 30px;
  width: 100%;
  border: none;
}

.indent {
  margin-left: 3rem;
}
</style>