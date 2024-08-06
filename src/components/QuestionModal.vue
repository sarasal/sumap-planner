<script setup>
import Radio from "@/components/Radio.vue";
</script>

<template>
  <b-modal size="xl" centered :id="id" no-close-on-backdrop no-close-on-esc hide-header-close @ok="submit">
    <div v-for="(question, index) in questions">
      <Radio
          :index="index"
          :question="question.question"
          :options="question.answer_list"
          :becomeRedIfEmpty="becomeRedIfEmpty"
          @selectedChanged="selectedChanged">
      </Radio>
    </div>

    <template #modal-footer="{ ok }">
      <!-- Emulate built in modal footer ok and cancel button actions -->
      <b-button variant="success" @click="ok">
        Next
      </b-button>
    </template>
  </b-modal>
</template>

<script>
import allQuestions from '@/questions/questions.json';
const questions = allQuestions.per_task;

export default {
  name: "QuestionModal",
  props: {
    id: {
      type: String,
      required: true
    },
  },
  data() {
    return {
      questions: questions,
      selected:  Array(questions.length).fill(-1),
      becomeRedIfEmpty: false,
    }
  },
  methods: {
    checkAllSelected: function (){
      for (let i = 0; i < this.selected.length; i++) {
        if(this.selected[i] === -1){
          return false;
        }
      }
      return true;
    },
    submit: function (bvModalEvent){
      if(!this.checkAllSelected()){
        bvModalEvent.preventDefault();
        this.becomeRedIfEmpty = true;
        this.$vs.notify({
          title:'Empty Feedback',
          text:'You did not submit your response yet. Please give your feedback and then click the Submit button.',
          color:`rgb(211,72,93)`
        });
        return;
      }
      const val = this.selected;
      this.$emit('submit', val);
      this.becomeRedIfEmpty = false;
      this.selected = Array(this.questions.length).fill(-1);
    },
    selectedChanged: function (val){
      this.selected[val.index] = val.answer;
    },
  }
}
</script>

<style scoped>

</style>