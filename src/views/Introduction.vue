<template>
  <b-container class="container">
    <b-card :img-src="require('@/assets/map_intro.jpeg')"
            img-alt="Image"
            img-height="300rem"
            img-top
            class="card"
            title="Plan your delivery with us!">

      <b-card-text>
        {{greeting}}
      </b-card-text>

      <b-card-text>
        Our study aims to provide new insights into how humans and AI systems collaborate in the area of logistical planning.
        Before you read more about this experiment, we'd like to draw your attention to four important points.
      </b-card-text>

      <b-card-text class="indent">
        1. We ask you to answer all of our questionnaires truthfully and to the best of your knowledge. We will not penalise
        you for getting a question incorrect. We are merely interested in investigating your experience of using our
        interface while doing the task.
      </b-card-text>

      <b-card-text class="indent">
        2. This study is divided into four sessions over two weeks. You are currently in the {{current_session}} session.
        We reward you for participating in all sessions in addition to the normal reimbursement. The reimbursement for
        each completed session will be [X], and the additional “return” bonus will be [X].
      </b-card-text>

      <b-card-text class="indent">
        3. In our study, you will be asked to solve five tasks (details on the task will follow on the next pages). For each
        task, there is a best answer from the five given options. The better you perform, the higher the additional task bonus
        will be. This bonus is again paid in addition to the normal study reimbursement.
      </b-card-text>

      <b-card-text class="indent">
        4. During the experiment, please refrain from pushing the back button in your browser. Instead, use the NEXT buttons found in our system’s interface.
      </b-card-text>

      <b-card-text>
        Completing this study session will take approximately [X] minutes.
      </b-card-text>

      <b-button class="mt-2" align-h="left" @click="gotoConsentForm()" variant="success">Continue</b-button>
    </b-card>

  </b-container>
</template>

<script>

export default {
  name: "Introduction",
  data() {
    return {
      greeting: this.$AppConfig.GREETING_TEXT,
      current_session: this.$AppConfig.CURRENT_SESSION_NUMBER_TEXT,
    }
  },
  methods: {
    gotoConsentForm: async function (){
      let url = '/consent-form';
      await this.$router.push(url);
    },
  },
  mounted: async function() {
    // todo uncomment the following line
    // localStorage.clear();
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