<script setup>
import PreTest from './PreTest.vue'
import Test from './Test.vue'
import Quiz from './Quiz.vue'
import PostTest from './PostTest.vue'
import WaitingRoom from "./WaitingRoom.vue";
</script>

<template>
  <b-card class="my-card" no-body>
    <b-tabs v-if="currentPage" card>
      <b-tab :title="this.currentPage.title" >
        <PreTest v-if="pages.pretest.show" :demoSession="demoSession" @submit="done"></PreTest>
        <Test v-else-if="pages.demo.show" :demoSession="demoSession" :demoTab="true" :groupDecisionMaking="groupDecisionMaking" @nextTab="done"></Test>
<!--        <Test v-else-if="pages.onboarding.show" :demoSession="demoSession" :onBoarding="true" :groupDecisionMaking="groupDecisionMaking" @onBoardingFinished="done"></Test>-->
        <Test v-else-if="pages.tutorial.show" :demoSession="demoSession" :tutorial="true" :groupDecisionMaking="groupDecisionMaking" @tutorialFinished="done"></Test>
        <Test v-else-if="pages.training.show" :demoSession="demoSession" :training="true" :groupDecisionMaking="groupDecisionMaking" @trainingFinished="done"></Test>
        <Quiz v-else-if="pages.quiz.show" :demoSession="demoSession" :userId="userId" :studyCondition="studyCondition" @submit="done"></Quiz>
        <WaitingRoom v-else-if="pages.waitingroom.show" :demoSession="demoSession" :userId="userId" @submit="done"></WaitingRoom>
        <Test v-else-if="pages.maintask.show" :demoSession="demoSession" :mainTasks="true" :groupDecisionMaking="groupDecisionMaking" @mainTasksFinished="done"></Test>
        <PostTest v-else-if="pages.posttest.show" :demoSession="demoSession" @submit="done"></PostTest>
        <div v-else-if="pages.score.show">
          <b-row>
            <b-text style="font-size: 24px">
              Thank you again for participating in this study session.
            </b-text>

            <br/>
            <br/>

<!--            <b-text style="font-size: 24px">-->
<!--              As mentioned earlier, this study includes <b> four sessions </b>. Please make sure that you return to complete-->
<!--              all four sessions. We offer a <b>RETURN BONUS </b> that increases with each session:-->
<!--              <b> £0.50 </b> for session 2, <b> £0.75 </b> for session 3, <b> £1.00 </b> for session 4.-->
<!--            </b-text>-->

            <b-text style="font-size: 24px">
              Thank you for completing all four sessions of our study. We appreciate your effort and would like to
              share some more insights.
            </b-text>

            <br/>

<!--            <b-text style="font-size: 24px">-->
<!--              In addition, you will also receive a <b>PERFORMANCE BONUS</b> based on your task results:-->
<!--              <b> £0.50 </b> for finding the best route per task (<b>max. £10.00</b> for all sessions).-->
<!--              The performance bonus will be paid after all four sessions are completed, and the return bonus will-->
<!--              be paid with your base participation payment shortly after each session.-->
<!--            </b-text>-->

            <b-text style="font-size: 24px">
              Here is how you performed during the tasks:
              You selected the best route in {{this.finalScore.performance}} out of 20 times.
              You followed the AI's advice {{this.finalScore.ai_agreement}}% of the time. This improved your performance by {{this.finalScore.correct_ai_agreement}}% when the advice was correct and reduced it by {{this.finalScore.incorrect_ai_agreement}}% when the advice was incorrect.
            </b-text>

            <br/>

            <b-text style="font-size: 24px">
              We hope you enjoyed participating in this study. Your contributions will help us better understand how
              people collaborate with AI systems, which could inform the design of future AI technologies.
            </b-text>

<!--            <b-text style="font-size: 24px">-->
<!--              Participating in Session 1 enabled you to participate and the following sessions. We will contact you via Prolific once the next session is ready.-->
<!--              <b>Session 4</b> will be launched on <b>Jan 28-30</b>.-->
<!--            </b-text>-->

          </b-row>
          <b-row>
            <b-button  style="margin-top: 1rem; font-size: 24px; padding: 6px 16px 6px;" @click="backToProlificAccepted" pill variant="outline-success" size="lg">Return to Prolific</b-button>
          </b-row>
        </div>
      </b-tab>
    </b-tabs>
  </b-card>
</template>

<script>
import get_user_training_task from '../samples/requests/get_user_training_task.json';
import {store} from "@/store";

const sampleResponses = {
  get_user_training_task : get_user_training_task,
}

export default {
  name: "MainWindow",
  data() {
    return {
      userId: undefined,
      currentPage: undefined,
      studyCondition: undefined,
      sessionId: Number(store.appConfig.CURRENT_SESSION_NUMBER),
      complexity: undefined,
      taskType: undefined,
      demoSession: store.appConfig.DEMO_SESSION.toLowerCase() === "enabled",
      groupDecisionMaking: String(import.meta.env.VITE_GROUP_DECISION_MAKING).toLowerCase() === "enabled",
      finalScore: {
        performance: null,
        ai_agreement: null,
        correct_ai_agreement: null,
        incorrect_ai_agreement: null,
      },
      pages: { // todo move it to file
        pretest:{
          show: false,
          title: 'Pre Task',
          next: 'unknown',
        },
        demo:{
          show: false,
          title: 'Demo',
          next: 'tutorial',
        },
        tutorial:{
          show: false,
          title: 'Tutorial',
          next: 'training',
        },
        training:{
          show: false,
          title: 'Training',
          next: 'mainTask',
        },
        quiz:{
          show: false,
          title: 'Quiz',
          next: 'waitingRoom',
        },
        waitingroom: {
          show: false,
          title: 'Lobby',
          next: 'mainTask',
        },
        maintask:{
          show: false,
          title: 'Main Tasks',
          next: 'postTest',
        },
        posttest:{
          show: false,
          title: 'Post Task',
          next: 'score',
        },
        score:{
          show: false,
          title: 'End',
        },
      },
    }
  },
  methods :{
    fakeRequest: function (url) {
      return sampleResponses[url];
    },
    updateBackend: async function (url, body) {
      // if (this.demoSession){
      //   return this.fakeRequest(url);
      // }
      const requestOptions = {
        method: "POST",
        headers: {"Content-Type": "application/json"},
        body: JSON.stringify(body)
      };
      const res = await fetch(`${window.location.origin}/api/${url}`, requestOptions);
      return await res.json();
    },
    getScore: function (userId){
      return JSON.parse(localStorage.getItem(`${userId}-score`));
    },
    saveTrainingTask: function ( res , userId ){
      const info = {
        session_id: res.session_id,
        task_id: res.task_id,
        study_condition: res.study_condition,
        task_scenario: res.task_scenario,
        uncertainty: res.uncertainty,
        ai_scenario: res.ai_scenario,
        best_transport: res.best_transport,
        best_route_index: res.best_route_index,
        best_cost: res.best_cost,
        ai_route_index: res.ai_route_index,
        ai_cost: res.ai_cost,
        ai_transport: res.ai_transport,
        route_data_list: res.route_data_list,
        route_quality_list: res.route_quality_list,
      }
      localStorage.setItem(`${userId}-info`, JSON.stringify(info));
    },
    done: async function ( body ){
      // TODO loading
      let next = this.currentPage.next;

      if (this.currentPage.next === 'mainTask' ){
        localStorage.setItem('room-id', body);
      }

      if (this.currentPage.next === 'unknown'){
        const res = await this.updateBackend('get_user_training_task', body);
        if (res.status !== 'passed'){
          localStorage.setItem('failed', 'true');
          await this.failed();
          return
        }
        this.saveTrainingTask(res, this.userId);
        next = (this.demoSession)? 'demo' : 'tutorial';
      }

      if (this.currentPage.next === 'mainTask'){
        const res = await this.updateBackend('get_user_task_instances', body);
        localStorage.setItem(`${this.userId}-user-tasks`, JSON.stringify(res));
      }

      localStorage.setItem(`${this.userId}-progress`, next);

      await this.$router.push(`/${this.userId}/${next}`);
    },
    failed: async function(){
      this.$vs.dialog({
        type: 'confirm',
        color: 'danger',
        title: 'Failed',
        text: 'As you did not answer the attention check questions in the pre-task questionnaire correctly, you are not eligible to continue our study. Please click on the Accept button to return to Prolific.',
        accept:this.backToProlificRejected,
        close:this.failed,
        cancel:this.failed,
      })
    },
    backToProlificAccepted: function (){
      window.location.href = String(store.appConfig.PROLIFIC_ACCEPT_LINK.toLowerCase());
    },
    backToProlificRejected: function (){
      window.location.href = String(store.appConfig.PROLIFIC_REJECT_LINK.toLowerCase());
    }
  },
  mounted: async function (){
    const failed = localStorage.getItem('failed');
    if (failed === 'true'){
      await this.failed();
    }

    const page = this.$route.path.split('/')[2].toLowerCase(); // todo, this line may cause bug in the future.
    const userId = this.$route.params.userId;

    const progress = localStorage.getItem(`${userId}-progress`);

    if (progress === 'tutorial' && this.sessionId !== 1){
      const body = {
        'session_id' : `${this.sessionId}`,
        'user_id': userId
      }
      const res = await this.updateBackend('get_user_training_task',body);
      this.saveTrainingTask(res, userId);
    }

    if (progress === 'score' && this.sessionId === 4){
      this.finalScore = this.getScore(userId);
    }

    // todo You may remove the following lines
    const userInfo = JSON.parse(localStorage.getItem(`${userId}-info`));
    if(userInfo !== null){
      this.studyCondition= parseInt(userInfo.study_condition);
      this.complexity= userInfo.complexity;
      this.taskType= userInfo.task_type;
    }

    if (progress.toLowerCase() !== page.toLowerCase()){
      await this.$router.push(`/${userId}/${progress}`);
      return;
    }

    this.userId = userId;
    this.currentPage = this.pages[page];

    if (this.currentPage === undefined || this.userId === undefined){
      await this.$router.push('/');
      this.$vs.notify({
        title:'Invalid URL',
        text:'You don\'t have access to this url',
        color:`rgb(72, 162, 211)`
      });
    }

    this.currentPage.show = true;
  }
}
</script>

<style scoped>
.my-card {
  margin: 2%;
}

</style>