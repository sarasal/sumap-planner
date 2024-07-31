<template>
  <b-container class="container">
    <b-card :img-src="require('@/assets/delivery_planner.jpeg')"
            img-alt="Image"
            img-height="500rem"
            img-top
            class="card"
            title="Consent Form">

      <b-card-text>
        Please read the following information carefully. If you agree with the study terms, please enter your Prolific
        ID at the end of this page to continue with the study (if you do not agree, you will be guided to the end of this
        study without compensation).
      </b-card-text>

      <b-card-text class="indent">
        <b> Potential risks and Inconveniences: </b>
        Your participation in this research project does not involve any physical, legal, or economic risks. You do not have to answer questions that you do not wish to answer. Your participation is voluntary. This means that you may end your participation at any moment you choose by letting the researcher know this. You do not have to explain why you decided to end your participation in the research project. None of this will have any negative consequences for you whatsoever.
      </b-card-text>

      <b-card-text class="indent">
        <b> Confidentiality, Use, and Storage of Data: </b>
        We will do everything we can to protect your privacy as best as possible. The research results that will be published will not in any way contain confidential information or personal data from or about you through which anyone can recognize you. The experiment data gathered via Prolific will be stored on an encrypted server of the Human-Technology Interaction Group (Eindhoven University of Technology). The raw and processed research data will be retained for 10 years. The research data will be made available to persons outside the research group if necessary (e.g., to check on scientific integrity), but only in anonymous form.
      </b-card-text>


      <b-card-text class="indent">
        <b> Reimbursement: </b>
        Participation will take approximately 15 - 20 mins per session. For your participation in this research project, you will receive a compensation of £9,00 / hour. We will refrain from payments for participants who dropped out of the study.
      </b-card-text>


<!--      <b-card-text class="indent">-->
<!--        <b> Reimbursement: </b>-->
<!--        Participation will take approximately 15 - 20 mins per session. For your participation in this research project, you will receive a compensation of £9,00 / hour. In addition to this, we pay participants a return (for returning to the second, third and fourth round) & performance bonus, which will be calculated at the end of this study. Both bonus payments will be reimbursed once the study is completed. We will refrain from payments for participants who dropped out of the study.-->
<!--      </b-card-text>-->

      <b-input-group>
        <template #prepend>
          <b-input-group-text variant="outline-info" class="email">Prolific ID</b-input-group-text>
        </template>
        <b-form-input placeholder="Prolific ID" v-model="prolificId" required/>
      </b-input-group>

      <b-row align-h="end">
        <b-col cols="6">
          <b-button class="mt-3" align-h="left" @click="proceedToTask()" variant="success">I agree to the terms of conditions and continue with the study</b-button>
        </b-col>

      </b-row>

<!--      <b-button class="mt-2" align-h="left" @click="proceedToTask()" variant="success">Agree and Continue</b-button>-->
    </b-card>

  </b-container>
</template>

<script>
import {store} from "@/store";

export default {
  name: "Introduction",
  data() {
    return {
      prolificId: undefined,
      sessionId: Number(store.appConfig.CURRENT_SESSION_NUMBER),
      demoSession: store.appConfig.DEMO_SESSION.toLowerCase() === "enabled",
    }
  },
  methods: {
    selectNextPage: function (){
      if (this.sessionId === 1)
        return 'pretest';

      if(this.demoSession){
        return 'demo';
      }

      return 'tutorial';
    },
    proceedToTask: async function (){
      if (this.prolificId == null){
        this.$vs.notify({
          title:'Empty Prolific ID',
          text:'Please provide a valid Prolific ID address',
          color:`rgb(196, 74, 74)`
        });

        return;
      }

      const user_id = this.prolificId;
      this.saveUserId(user_id);

      let nextPage = this.selectNextPage() ;

      this.saveUserProgress(user_id, nextPage);

      const url = '/' + user_id + '/' + nextPage;

      await this.$router.push(url);
    },
    saveUserId(user_id) {
      const data = {
        user_id: user_id
      }
      localStorage.setItem(user_id, JSON.stringify(data));
    },
    saveUserProgress: function (userId, page){
      localStorage.setItem(`${userId}-progress`, page);
    },
  }
}
</script>

<style scoped>
.email{
  background-color: rgb(72, 162, 211);
  color: white;
}

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