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
        <b> Voluntary Participation: </b>
        Your participation in this study is entirely voluntary, and you have the right to withdraw at any time without penalty or negative consequences. If you choose to withdraw, any data collected from you will be deleted and not included in the final analysis.

      </b-card-text>

      <b-card-text class="indent">
        <b> Confidentiality and Use, Storage, and Sharing of Data: </b>
        We will gather and analyse your questionnaire responses, main task completion, and interaction with our platform to improve the user experience. We assure you that no personal information will be collected or stored during this process. The anonymous information will be made available online in the interest of open source.
      </b-card-text>

      <b-input-group>
        <template #prepend>
          <b-input-group-text variant="outline-info" class="email">Prolific ID</b-input-group-text>
        </template>
        <b-form-input placeholder="Prolific ID" v-model="prolificId" required/>
      </b-input-group>

      <b-button class="mt-2" align-h="left" @click="proceedToTask()" variant="success">Agree and Continue</b-button>
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