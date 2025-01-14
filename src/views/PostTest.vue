<script setup>
import Radio from '../components/Radio.vue'
import Range from '../components/Range.vue'
import CheckBox from '../components/CheckBox.vue'
import ProgressBar from "@/components/ProgressBar.vue";
</script>

<template>
  <div>
    <b-row style="margin-bottom: 1rem" align-v="center">
      <b-col cols="3" v-if="demoSession">
        <b-button class="mt-2" align-h="right" @click="nextTab()" pill variant="outline-success" size="lg">Next Tab</b-button>
      </b-col>
      <b-col cols="3" v-if="!demoSession">
      </b-col>
      <b-col cols="6">
        <progress-bar :value="currentPage-1" :max="numberOfPages" :animated="false"></progress-bar>
      </b-col>
      <b-col cols="3" align="right" >
        <b-button v-if="currentPage !== numberOfPages" class="mt-2" align-h="right" @click="nextQuestions()" pill variant="outline-success" size="lg">Next</b-button>
        <b-button v-if="currentPage === numberOfPages" class="mt-2" align-h="right" @click="submit()" pill variant="outline-success" size="lg">Submit</b-button>
      </b-col>
    </b-row>

<!--    <b-row style="margin-bottom: 1rem">-->
<!--      <b-col>-->
<!--        <b-button v-if="currentPage !== numberOfPages" class="mt-2" align-h="right" @click="nextQuestions()" pill variant="outline-success" size="lg">Next</b-button>-->
<!--      </b-col>-->
<!--      <b-col align="right" v-if="demoSession">-->
<!--        <b-button class="mt-2" align-h="right" @click="nextTab()" pill variant="outline-success" size="lg">Next Tab</b-button>-->
<!--      </b-col>-->
<!--    </b-row>-->

    <b-card-text class="indent">
      <h4>
        Before completing this session, we ask you to answer the following questions.
      </h4>
    </b-card-text>

    <div v-if="currentPage !== numberOfPages +1" id="my-questions" v-for="(question, index) in questions.slice(currentQuestionsIndexes.first, currentQuestionsIndexes.last)" :key="question.question" >
      <Radio
          v-if="question.answer_list.length !== 2 && question.answer_list.length !== 0"
          :index="(currentPage-1)* 5 + index"
          :question="question.question"
          :options="question.answer_list"
          :becomeRedIfEmpty="becomeRedIfEmpty"
          @selectedChanged="selectedChanged">
      </Radio>
<!--      <Radio-->
<!--          v-if="question.answer_list.length !== 2 && question.answer_list.length !== 0"-->
<!--          :index="(currentPage-1)* 5 + index"-->
<!--          :question="question.question"-->
<!--          :options="question.answer_list"-->
<!--          :becomeRedIfEmpty="becomeRedIfEmpty"-->
<!--          @selectedChanged="selectedChanged">-->
<!--      </Radio>-->
      <Range
          v-else-if="question.answer_list.length === 2"
          :index="(currentPage-1)* 5 + index"
          :question="question.question"
          :max="question.likert_scale"
          :beginningLabel="question.answer_list[0]"
          :endLabel="question.answer_list[1]"
          :becomeRedIfEmpty="becomeRedIfEmpty"
          @selectedChanged="selectedChanged">
      </Range>
      <b-form-group style="font-size: 24px;" v-else-if="question.answer_list.length === 0" :label="`40. ${question.question}`" label-for="textarea-formatter" >
        <b-form-textarea
            id="textarea-formatter"
            v-model="text"
            size="lg"
            rows="5"
            max-rows="10"
            placeholder="Enter your feedback"
            @update="selectedChanged"
        ></b-form-textarea>
      </b-form-group>
    </div>

<!--    <CheckBox v-if="currentPage === 6" :questions="questions" @selectedArrayChanged="selectedArrayChanged"></CheckBox>-->

    <b-row style="margin-bottom: 1rem">
      <b-col v-if="demoSession">
        <b-button class="mt-2" align-h="right" @click="nextTab()" pill variant="outline-success" size="lg">Next Tab</b-button>
      </b-col>
      <b-col align="right">
        <b-button v-if="currentPage !== numberOfPages" class="mt-2" align-h="right" @click="nextQuestions()" pill variant="outline-success" size="lg">Next</b-button>
        <b-button v-if="currentPage === numberOfPages" class="mt-2" align-h="right" @click="submit()" pill variant="outline-success" size="lg">Submit</b-button>
      </b-col>
    </b-row>

<!--    <b-row style="margin-bottom: 1rem">-->
<!--      <b-col>-->
<!--        <b-button v-if="currentPage !== numberOfPages" class="mt-2" align-h="right" @click="nextQuestions()" pill variant="outline-success" size="lg">Next</b-button>-->
<!--        <b-button v-if="currentPage === numberOfPages" class="mt-2" align-h="right" @click="submit()" pill variant="outline-success" size="lg">Submit</b-button>-->
<!--      </b-col>-->
<!--      <b-col align="right" v-if="demoSession">-->
<!--        <b-button class="mt-2" align-h="right" @click="nextTab()" pill variant="outline-success" size="lg">Next Tab</b-button>-->
<!--      </b-col>-->
<!--    </b-row>-->

  </div>
</template>

<script>
import allQuestions from '../questions/questions.json';
import {store} from "@/store";


export default {
  name: "PreTest",
  props: {
    demoSession: {
      type: Boolean,
      required: true
    },
  },
  data() {
    return {
      currentPage: 1,
      becomeRedIfEmpty: false,
      sessionId: store.appConfig.CURRENT_SESSION_NUMBER,
      user_id: null,
      text: null,
      questions: [],
      answers: [],
      checkBoxInitialIndex: 21,
      numberOfPages: 0,
    }
  },
  methods:{
    updateBackend: async function (data){
      const requestOptions = {
        method: "POST",
        headers: {"Content-Type": "application/json"},
        body: JSON.stringify(data)
      };

      await fetch(`${window.location.origin}/api/submit_post_test`, requestOptions);
    },
    nextTab: function (){
      if(this.demoSession){
        const data = this.generateFinalAnswers();
        this.updateBackend(data);
        this.$emit('submit', data);
      }
    },
    nextQuestions: function (){
      const firstIndex = this.currentQuestionsIndexes.first;
      const lastIndex = this.currentQuestionsIndexes.last;
      if(!this.answeredAllQuestions(firstIndex,lastIndex)){
        this.becomeRedIfEmpty = true;
        this.$vs.notify({
          title:'Not completed',
          text:'Please answer all questions.',
          color:`rgb(211,72,93)`
        });
        return;
      }

      this.becomeRedIfEmpty = false;
      this.currentPage += 1;
    },
    selectedChanged: function (obj){
      if(obj.index === undefined){
        this.answers[39] = obj;
        return;
      }
      this.answers[obj.index] = (obj.type === 'Range')? parseInt(obj.answer) : obj.answer + 1;
      // console.log(this.answers);
    },
    selectedArrayChanged: function (obj){
      for (let i = 0; i < obj.length; i++) {
        this.answers[this.checkBoxInitialIndex + i] = (obj[i] === -1) ? -1 : 1;
      }
    },
    generateFinalAnswers: function (){
      const result = []

      for (let i=0; i< this.questions.length; i++){
        result.push({
          question_id: this.questions[i].question_id,
          answer: this.answers[i]
        });
      }

      return {
        "user_id": this.user_id,
        "session_id": this.sessionId,
        "post_test": result,
      };
    },
    submit: async function () {
      if(this.answeredAllQuestions(0,this.questions.length)){
        const data = this.generateFinalAnswers();
        await this.updateBackend(data);
        this.$emit('submit', data);
        return
      }

      this.becomeRedIfEmpty = true;
      this.$vs.notify({
        title:'Not completed',
        text:'Please answer all questions.',
        color:`rgb(211,72,93)`
      });
    },
    answeredAllQuestions: function (firstIndex, lastIndex){
      for (let i = firstIndex; i < lastIndex -1; i++) {
        if(this.answers[i] === -1){
          return false;
        }
      }
      return true;
    }
  },
  computed: {
    currentQuestionsIndexes: function (){
      const first = (this.currentPage-1) * 5;
      let last = (this.currentPage) * 5;

      if ( last > this.questions.length){
        last = this.questions.length;
      }

      return {
        first: first,
        last: last,
      }
    }
  },
  created: function () {
    this.user_id = this.$route.params.userId
    this.questions = allQuestions.post_task.filter(item => item.session_id.includes(this.sessionId));
    this.answers = new Array(this.questions.length).fill(-1);
    // this.numberOfPages = Math.floor(this.questions.length/5) + Math.floor(this.questions.length%5);
    this.numberOfPages = Math.ceil(this.questions.length/5);
  }
}
</script>

<style scoped>

</style>