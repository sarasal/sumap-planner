<script setup>
import ProgressBar from '../components/ProgressBar.vue'
import Clock from '../components/Clock.vue'
import GeneralInfoCard from '../components/test/GeneralInfoCard.vue'
import Chat from "../components/Chat.vue"
import Quiz from "@/views/Quiz.vue";
</script>

<template>
  <div v-if="finishedLoaded">
    <b-container style="min-width: 100%">
      <b-row v-if="!tutorial && !training" align-h="end" class="pb-1">
        <b-col v-if="progressBarSize === 7">
          <b-button v-if="demoTab" style="top: 0; font-size: 13px; padding: 4px 8px 4px;" @click="nextTab()" pill variant="outline-success">Next Tab</b-button>
        </b-col>
        <b-col :cols="progressBarSize" ref="progressBar" class="pr-1 pl-0">
          <ProgressBar v-if="!mainTasks" :max="3" :value="1" :animated="animatedProgressBar" />
          <ProgressBar v-if="mainTasks" :max="this.user_tasks.length" :value="this.current_task_index" :animated="animatedProgressBar"/>
        </b-col>
        <b-col cols="1">
        </b-col>
        <b-col cols="1" ref="clock">
          <Clock v-if="userId && timerEnabled" :paused="false" :user-id="userId" />
        </b-col>
      </b-row>
      <b-row>
        <b-col cols="12">
          <b-card class="custom-task-card">
            <h4 class="task-card-title">You are tasked to ...</h4>
            <p class="task-card-text">{{you_are_tasked_to}}</p>
          </b-card>
        </b-col>
      </b-row>
      <b-row>
        <b-col cols="8" class="pr-0 pl-0">
          <b-row>
            <b-embed
                ref="map"
                type="iframe"
                aspect="16by9"
                :src="this.map_url"
                allowfullscreen
                v-on:load="mapLoaded()"
                @mouseover="hover.map = true"
                @mouseleave="hover.map = false"
            ></b-embed>
          </b-row>
          <b-row ref="mapControlPanel" class="d-flex justify-content-center align-items-center">
            <b-row>
              <b-pagination
                v-model="userFriendlyRouteIndex"
                :total-rows="map_id_list.length"
                :per-page="1"
                :limit="map_id_list.length"
                :hide-goto-end-buttons="true"
                align="fill"
                size="lg"
                @change="routeChanged"
              ></b-pagination>
              <span style="margin-left: 1rem; padding-top: 5px; font-size: 2rem">{{ route_name }}</span>
            </b-row>
          </b-row>
        </b-col>
        <b-col cols="4" class="pr-0 pl-0">
          <div ref="generalInfo" @mouseover="hover.generalInfo = true" @mouseleave="hover.generalInfo = false">
            <b-card ref="scenario" title="Task Scenario" style="font-size: 14px; margin-bottom: 1rem" class="custom-card">
              <img :src="iconsSrc.deliveryManager" alt="Icon" class="icon-small" /> As a delivery manager, you manage the delivery of multiple parcels. Your main task is choosing delivery routes associated with the lowest costs. You do this by comparing five available delivery routes from which you need to pick the best one. To identify the optimal route, you must consider the following criteria: <br/>
              <b-list-group class="custom-list-group">
                <b-list-group-item>
                  <img :src="iconsSrc.package" alt="Icon" class="icon-small" /> <b>Number of Parcels</b>: Each parcel delivery is rewarded with <b>100</b> points. The routes may vary in the number of parcels (between <b>1</b> and <b>10</b>).
                </b-list-group-item>
                <b-list-group-item>
                  <img :src="iconsSrc.car" alt="Icon" class="icon-small" /> / <img :src="iconsSrc.eBike" alt="Icon" class="icon-small" /> <b>Delivery Vehicle</b>: Parcels are delivered by either <b>car</b> or <b>e-bike</b>. Deliveries by e-bike are rewarded with <b>50</b> points for each traveled kilometer. Deliveries by car, in contrast, are faster and save time. <br/>
                </b-list-group-item>
                <b-list-group-item>
                  <img :src="iconsSrc.distance" alt="Icon" class="icon-small" /> <b>Distance</b>: Delivering the parcels creates costs. The longer deliveries are, the more costs are created. The length of a sub-route is displayed when hovering over a particular route. The speed of the car and e-bike is constant, with the car traveling at <b>70 km/h</b> and the e-bike at <b>45 km/h</b>. <br/>
                </b-list-group-item>
                <b-list-group-item>
                  <img :src="iconsSrc.deliveryTime" alt="Icon" class="icon-small" /> <b>Delivery handling time</b>: {{this.delivery_handling_time}}
                </b-list-group-item>
              </b-list-group>
              <b-card ref="ai-info" title="DeliveryPlanner AI System" style="font-size: 14px" class="delivery-card">
                {{this.current_task.ai_scenario}}
              </b-card>
            </b-card>
          </div>
        </b-col>
      </b-row>

      <b-row>

        <b-card style="width:100%; padding: 0" no-body ref="chat" v-if="groupDecisionMaking && (roomId !== null || onBoarding)">
          <template #header>
            <h1 style="font-size: 28px">Chat</h1>
          </template>
          <Chat :demoSession="demoSession" :onBoarding="onBoarding" :userId="userId" :roomId="roomId" :taskIdList="taskIdList" @nextTask="gotoNextTask" @finished="emitMainTaskFinished" />
        </b-card>

        <b-card v-if="!groupDecisionMaking || this.training" style="width:100%; padding: 0" no-body ref="decisions">
          <template #header>
            <h1 style="font-size: 28px">Initial Decision</h1>
          </template>

          <div class="no-padding">
            <b-input-group v-if="initialDecision.enabled">

              <template #prepend>
                <b-input-group-text >What is the best delivery plan?</b-input-group-text>
              </template>

              <b-form-select v-model="initialDecision.value" :options="route_options">
                <template #first>
                  <b-form-select-option :value="null" disabled>Choose a route</b-form-select-option>
                </template>

              </b-form-select>

              <template #append>
                <b-button @click="submitInitialDecision()" ref="submitButton">submit</b-button>
              </template>
            </b-input-group>

            <b-text v-if="!initialDecision.enabled">
              You initially selected <span style="background-color: yellow;">{{initialDecision.value}}</span> as the best plan.
            </b-text>
          </div>
        </b-card>

        <b-card v-if="!initialDecision.enabled && (!groupDecisionMaking || this.training)" style="width:100%; padding: 0; margin-top: 1rem; margin-bottom: 1rem">
          <template #header>
            <h1 style="font-size: 28px">DeliveryPlanner Suggestion</h1>
          </template>
          <b-text>
            DeliveryPlanner suggests that the <span style="background-color: yellow;">{{`Route ${Number(this.current_task.best_route_id) +1}`}}</span> is the best plan.
          </b-text>
        </b-card>

        <b-card v-if="!initialDecision.enabled && (!groupDecisionMaking || this.training)" style="width:100%; padding: 0;">
          <template #header>
            <h1 style="font-size: 28px">Final decision</h1>
          </template>

          <div class="no-padding">
            <b-input-group>

              <template #prepend>
                <b-input-group-text >What is the best delivery plan?</b-input-group-text>
              </template>

              <b-form-select v-model="finalDecision" :options="route_options">
                <template #first>
                  <b-form-select-option :value="null" disabled>Choose a route</b-form-select-option>
                </template>

              </b-form-select>

              <template #append>
                <b-button @click="submitFinalDecision()">submit</b-button>
              </template>
            </b-input-group>
          </div>

        </b-card>

      </b-row>
    </b-container>
  </div>
</template>

<script>
import "intro.js/minified/introjs.min.css";
import introJS from 'intro.js';
import sample1 from '../samples/sample_tasks_1.json';
import sample2 from '../samples/sample_tasks_2.json';
import sample3 from '../samples/sample_tasks_3.json';
import sample4 from '../samples/sample_tasks_4.json';
import sample5 from '../samples/sample_tasks_5.json';
import sample6 from '../samples/sample_tasks_6.json';
import {store} from "@/store";

import carIcon from '@/assets/icons/car.png';
import eBikeIcon from '@/assets/icons/e-bike.png';
import deliveryTimeIcon from '@/assets/icons/delivery-time.png';
import deliveryManagerIcon from '@/assets/icons/delivery-manager.png';
import distanceIcon from '@/assets/icons/distance.png';
import packageIcon from '@/assets/icons/package.png';

const samples = [sample1,sample2,sample3,sample4,sample5,sample6];
const transportMap = {
  train: {
    icon: "train",
    color: "#4361ee",
  },
  taxi: {
    icon: "local_taxi",
    color: "#7b2cbf",
  },
  bus: {
    icon: "directions_bus",
    color: "#61a5c2",
  }
};

const capacityLevelMap = {
  green: {
    text: "Seats Available",
    color: "#1D931DFF",
  },
  orange: {
    text: "Limited Seats",
    color: "#ffa500",
  },
  red: {
    text: "No Seats",
    color: "#dc0c0c",
  },
};

export default {
  name: "Test",
  props: {
    onBoarding: {
      type: Boolean,
      default: false,
    },
    demoTab: {
      type: Boolean,
      default: false,
    },
    demoSession: {
      type: Boolean,
      default: false,
    },
    groupDecisionMaking: {
      type: Boolean,
      default: false,
    },
    tutorial: {
      type: Boolean,
      default: false,
    },
    training: {
      type: Boolean,
      default: false,
    },
    mainTasks: {
      type: Boolean,
      default: false,
    }
  },
  data() {
    return {
      iconsSrc : {
        car: carIcon,
        eBike: eBikeIcon,
        deliveryTime: deliveryTimeIcon,
        deliveryManager: deliveryManagerIcon,
        distance: distanceIcon,
        package: packageIcon,
      },
      animatedProgressBar: store.appConfig.ANIMATED_PROGRESS_BAR.toLowerCase() === "enabled",
      timerEnabled: store.appConfig.TIMER_ENABLED.toLowerCase() === "enabled",
      finishedLoaded: false,
      currentSample: 1,
      readMe: !this.mainTasks,
      current_task_index: 0,
      userFriendlyRouteIndex: 1,
      current_map_index: 0,
      task_info: null,
      initialDecision: {
        enabled: true,
        value: "",
        timestamp: 0,
      },
      finalDecision: "",
      route_info_styles:[],
      userId: null,
      roomId: null,
      user_tasks: null,
      route_options: [],
      taskIdList: [],
      showTrainingPopup: true,
      studyCondition: null,
      result: {
        user_id: null,
        study_condition: null,
        start_time: null,
        end_time: null,
        user_study: [],
        decision_times: [],
      },
      hover:{
        map: false,
        generalInfo: false,
        routeInfo: false,
      }
    }
  },
  methods: {
    handleMessageFromIframe(event) {
      // Always check the origin for security reasons!
      // if (event.origin === 'http://the-iframe-origin.com') {
      console.log('Received message from iframe:', event.data);
        // Here you can react to the message, update data properties, call methods, etc.
      // }
    },
    nextTab: function () {
      if(this.training){
        this.$emit('trainingFinished')
      } else {
        this.$emit('nextTab');
      }
    },
    nextSample: function (bvEvent, page){
      this.user_tasks = samples[page-1];
      this.finalDecision = "";
      this.initialDecision = {
        enabled: true,
        value: "",
        timestamp: 0,
      }
    },
    routeChanged: function (page) {
      this.showTrainingPopup = false;
      this.emitBackendEvent('CLICK', this.getCurrentTimestamp(), (page-1));
      this.current_map_index = page -1;
    },
    extract_task_ids: function (){
      let ids = [];
      for (let i = 0; i < this.user_tasks.length; i++) {
        ids.push(this.user_tasks[i].task_id)
      }
      return ids
    },
    gotoNextTask: function (){
      this.finalDecision = "";
      this.initialDecision = {
        enabled: true,
        value: "",
        timestamp: 0,
      }
      this.current_task_index++;
      this.current_map_index=0;
      this.userFriendlyRouteIndex=1;
      this.readMe = false;
      localStorage.current_task_index = this.current_task_index;
    },
    emitMainTaskFinished: function (){
      this.$emit('mainTasksFinished');
    },
    submitInitialDecision: function (){
      if(this.initialDecision.value === ""){
        this.$vs.notify({
          title:'Empty Initial Decision',
          text:'You didn\'t make your initial decision. Please identify your choice and then click on submit.',
          color:`rgb(211,72,93)`
        });
        return;
      }
      this.initialDecision.timestamp = this.getCurrentTimestamp();
      this.initialDecision.enabled = false;
      this.emitBackendEvent('INITIAL_SUBMISSION', this.initialDecision.timestamp, this.routeNameToIndex(this.initialDecision.value));
    },
    routeNameToIndex: function (name){
      return `${parseInt(name.replace('Route ', '')) -1}`;
    },
    submitFinalDecision: async function (){
      if(this.finalDecision === ""){
        this.$vs.notify({
          title:'Empty Final Decision',
          text:'You didn\'t make your final decision. Please identify your choice and then click on submit.',
          color:`rgb(211,72,93)`
        });
        return;
      }

      const finalSubmissionTimestamp = this.getCurrentTimestamp();

      this.result.user_study.push({
        task_id: this.current_task.task_id,
        initial_decision: this.routeNameToIndex(this.initialDecision.value),
        final_decision: this.routeNameToIndex(this.finalDecision),
      });

      this.emitBackendEvent('FINAL_SUBMISSION', finalSubmissionTimestamp, this.routeNameToIndex(this.finalDecision));

      this.result.decision_times.push({
        task_id: this.current_task.task_id,
        start_decision: this.initialDecision.timestamp,
        end_decision: finalSubmissionTimestamp,
      });

      if(this.training){
        this.$emit('trainingFinished');
        return;
      }

      if(this.current_task_index === this.user_tasks.length -1) {
        this.result.end_time = finalSubmissionTimestamp;
        const res = await this.updateBackend('submit_user_study', this.result);
        localStorage.setItem(`${this.userId}-score`, res.score);
        this.$emit('mainTasksFinished');
        return;
      }

      this.gotoNextTask();
    },
    emitBackendEvent: function (type, timestamp, value){
      if (!this.mainTasks){
        return;
      }

      const body = {
        user_id: this.userId,
        study_condition: `${this.studyCondition}`,
        task_id: this.current_task.task_id,
        event_type: type,
        timestamp: `${timestamp}`,
        event_value: `${value}`
      };

      // TODO uncomment the following line
      // this.updateBackend('submit_event', body);
    },
    updateBackend: async function (url, newBody){
      const rawBody = {
        "user_id": this.userId,
        "group_id": this.roomId,
        "study_condition": this.studyCondition,
      };

      const body = (newBody === undefined)? rawBody: newBody;

      const requestOptions = {
        method: "POST",
        headers: {"Content-Type": "application/json"},
        body: JSON.stringify(body)
      };

      const res = await fetch(`${window.location.origin}/api/${url}`, requestOptions);
      if (url !== 'submit_event'){
        return await res.json();
      }
    },
    getCurrentTimestamp: function () {
      return Date.now();
    },
    trainingPopup: function (){
      const intro = introJS()

      const steps = [
        {
          id: 0,
          title: '',
          intro: 'Now you have all the information on the task procedure and the AI system, let’s start with the training task!'
        }
      ]

      intro.addSteps(steps);

      intro.setOptions({
        'disableInteraction': true,
        'exitOnOverlayClick': false,
        'exitOnEsc': false,
        'doneLabel': 'OK'
      });

      intro.start();
    },
    mapLoaded: function (){
      if(this.training && this.showTrainingPopup){
        this.trainingPopup()
        return
      }

      if (!this.tutorial && !this.onBoarding){
        return
      }

      if(this.onBoarding){
        this.run_introJS();
        return;
      }


      const task = this;
      const intro = introJS()
      let finished = false;

      intro.oncomplete(function () {
        task.$emit('tutorialFinished');
        finished = true;
        intro.exit(true);
      });

      // console.log("inside on load");
      // In Chrome console use:
      // document.getElementById('my_map_1191').contentWindow.document.getElementById('tooltip_13748ca0330647a2b0314a22ebc069ae')
      // const el = this.$refs.map.firstChild.contentWindow.document.getElementById('html_8bfdd3523d246ca66b7ff7e4b254b1a8');
      // const el2 = this.$refs.myTestRef;
      // console.log(el2)

      // intro.addStep({
      //   element: el,
      //   intro: "Ok, wasn't that fun?",
      //   position: 'right'
      // });
      // this.intro.addStep({
      //   element: el2,
      //   intro: "Ok, wasn't that fun?",
      //   position: 'right'
      // });

      // todo use this trick to access child
      // console.log(this.$refs.generalInfo.children);
      // const generalInfoRefs = this.$refs.generalInfo.children[0].__vue__.$refs;
      // const transportFareEl = generalInfoRefs.costCard.$refs.transportFare.$el;

      // let subscriptionEl, rainEl, trafficEl, capacityLevel, capacityEl, peakFaresEl, peakFares, distanceBasedDiscount, distanceBasedDiscountEl, limitedTransfersEl, stopEL;

      // if (this.studyCondition >= 3 ){
      //   subscriptionEl = generalInfoRefs.costCard.$refs.subscription.$el;
      //   capacityLevel = this.$refs.capacityLevel[0];
      // }


      // if(this.studyCondition === 4 || this.studyCondition === 6){
      //
        // rain
        // if(parseInt(this.chance_list[0]['chance']) >= 60){
        //   rainEl = generalInfoRefs.rainHigh;
        // }
        // if(parseInt(this.chance_list[0]['chance']) < 60){
        //   rainEl = generalInfoRefs.rainLow;
        // }


        // traffic
        // if(parseInt(this.chance_list[1]['chance']) >= 60){
        //   trafficEl = generalInfoRefs.trafficHigh;
        // }
        //
        // if(parseInt(this.chance_list[1]['chance']) < 60){
        //   trafficEl = generalInfoRefs.trafficLow;
        // }
        //
        //
        // capacity
        // if(parseInt(this.chance_list[2]['chance']) >= 60){
        //   capacityEl = generalInfoRefs.capacityHigh;
        // }

        // if(parseInt(this.chance_list[2]['chance']) < 60){
        //   capacityEl = generalInfoRefs.capacityLow;
        // }


        // pick-up point
        // if(parseInt(this.chance_list[3]['chance']) >= 60){
        //   stopEL = generalInfoRefs.stopHigh;
        // }

        // if(parseInt(this.chance_list[3]['chance']) < 60){
        //   stopEL = generalInfoRefs.stopLow;
        // }

      // }



      // if(this.studyCondition === 3 || this.studyCondition === 5){
      //   rainEl = generalInfoRefs.rainFixed;
      //   capacityEl = generalInfoRefs.capacityFixed;
      //   trafficEl = generalInfoRefs.trafficFixed;
      // }

      // if(this.studyCondition === 5){
      //   stopEL = generalInfoRefs.stopFixed;
      // }

      // peak fares, distance-based discount, limited transfers
      // if (this.studyCondition >= 5 ){
      //   peakFaresEl = generalInfoRefs.peakFares;
      //   peakFares = generalInfoRefs.costCard.$refs.peakFare.$el;
      //
      //   distanceBasedDiscountEl = generalInfoRefs.distantBasedFare;
      //   distanceBasedDiscount = generalInfoRefs.costCard.$refs.distanceBasedDiscount.$el;
      //   limitedTransfersEl = generalInfoRefs.limitedTransfers;
      // }


      const steps = [
        {
          title: 'Welcome',
          intro: 'Before we start with the main study tasks, we want you to familiarize yourself with a training task. Take the time to read through the descriptions and task features before moving on to the main tasks.',
          studyConditions: [1,2,3,4,5,6],
        },
        {
          title: this.$refs.scenario,
          position: 'bottom',
          intro: 'In this study, your main task is finding the best delivery route out of five options. For this task, you always follow the same four steps:',
          studyConditions: [1,2,3,4,5,6],
        },
        {
          element: this.$refs.decisions,
          intro: 'Step 1: You screen the five route options and submit your initial decision',
          position: 'right',
          studyConditions: [1,3,5],
        },
        {
          element: this.$refs.map,
          intro: 'The Map includes information about the number of parcels, delivery handling time, distances, and vehicle type (which is also visualized by colors and icons in the map). You can access more information by hovering over the parcels or sub-routes.',
          position: 'right',
          studyConditions: [1,2,3,4,5,6],
        },
        {
          element: this.$refs.mapControlPanel,
          intro: 'With the control buttons, you can change the highlighted route on the map.',
          position: 'top',
          studyConditions: [1,2,3,4,5,6],
        },
        {
          title: 'AI Suggestion',
          intro: 'Step 2: You receive new information about the AI suggestion.',
          studyConditions: [1,2,3,4,5,6],
        },
        {
          element: this.$refs.submitButton,
          intro: 'Step 3: You finally submit the route that you believe is the best option. This means you can adjust or confirm your initial decision from Step 1.',
          position: 'right',
          studyConditions: [1,2,3,4,5,6],
        },
        {
          title: 'Short Questionnaire',
          intro: 'Step 4: You finish this task with a short questionnaire before you go to the next task.',
          studyConditions: [1,2,3,4,5,6],
        },

        {
          element: this.$refs.scenario,
          intro: "The mode of transportation includes a train, taxi, and bus. Each sub-route is indicated by a distinct logo to identify it.",
          position: 'bottom',
          studyConditions: [1,2,3,4,5,6],
        },
        {
          element: this.$refs["ai-info"],
          intro: 'During the study task, you are supported by an AI system. Find some details on it here:',
          position: 'right',
          studyConditions: [1,2,3,4,5,6],
        },

        {
          title: 'Tutorial Completed',
          intro: 'Here is where the tasks start. The first task with be training, which can be clicked through for the second/third/last session',
          studyConditions: [1,2,3,4,5,6],
        },
      ];

      intro.addSteps(steps);

      intro.setOptions({
        'disableInteraction': true,
        'exitOnOverlayClick': false,
        'exitOnEsc': false
      });

      intro.onbeforeexit(function() {
        if(task.demoSession){
          task.$emit('tutorialFinished');
          return true;
        }
        if(!finished) {
          task.$vs.notify({
            title: 'It is not possible to exit',
            text: 'Please follow all the steps',
            color: `rgb(255, 165, 0)`
          });
          return false;
        }
      });

      intro.start();
    },
    run_introJS: function () {
      const task = this;
      let finished = false;

      const intro = introJS()

      intro.oncomplete(function () {
        task.$emit('onBoardingFinished');
        finished = true;
        intro.exit(true);
      });

      const steps = [
        {
          id: 0,
          title: 'Welcome',
          intro: 'This is the interface tutorial to get to know the different components on the screen. Click on the next button to start.'
        },
        {
          id: 1,
          element: this.$refs.scenario,
          intro: "Please take a minute to read your task description. Note that you do not have to memorize the task description.",
          position: 'bottom'
        },
        {
          id: 2,
          element: this.$refs.map,
          intro: "For each route, the details of the commute plan are presented on the map. Their colors distinguish sub-routes. You can click on each sub-route to see more information. You can hover over the sub-route to show its name.",
          position: 'right'
        },
        {
          id: 3,
          element: this.$refs.mapControlPanel,
          intro: "You can use these buttons to change the highlighted route on the map.",
          position: 'top'
        },
        {
          id: 4,
          element: this.$refs.routeInfo,
          intro: "You can also see the details of the commute plan for the highlighted route here.",
          position: 'right'
        },
        {
          id: 5,
          element: this.$refs.generalInfo,
          intro: "You can view available information regarding all routes.",
          position: 'left'
        },
        {
          id: 6,
          element: this.$refs.decisions,
          intro: "You should answer this question twice. After you make the initial decision, the AI suggestion is shown. You can then submit your final decision.",
          position: 'top'
        },
        {
          id: 7,
          element: this.$refs.progressBar,
          intro: "You can view the progress here.",
          position: 'bottom'
        },
        {
          id: 8,
          element: this.$refs.clock,
          intro: "The timer starts when you enter the main study.",
          position: 'left'
        },
        {
          id: 9,
          title: 'congratulation',
          intro: 'By now, you should be acquainted with the elements displayed on your screen. To deep dive into a tutorial on utilizing the study\'s task features, simply click on the Done button.'
        },
      ];

      if (this.groupDecisionMaking) {
        for (let i = 0; i < steps.length; i++) {
          if (steps[i].id === 6) {
            steps[i] = {
              id: 6,
              element: this.$refs.chat,
              intro: "You can chat with your partner here to discuss and collaborate on making the initial and final decisions for the task. Both initial and final decisions should be submitted here using the corresponding commands.",
              position: 'top'
            }
          }
        }
      }

      intro.addSteps(steps);

      intro.setOptions({
        'disableInteraction': true,
        'exitOnOverlayClick': false,
        'exitOnEsc': false
      });

      intro.onbeforeexit(function() {
        if(task.demoSession){
          task.$emit('onBoardingFinished');
          return true;
        }

        if(!finished){
          task.$vs.notify({
            title:'It is not possible to exit',
            text:'Please follow all the steps',
            color:`rgb(255, 165, 0)`
          });
          return false;
        }
      });

      intro.start();
    },
    generate_route_options: function () {
      let options = [];
      for (let i = 0; i < this.map_id_list.length; i++) {
        options.push(`Route ${i+1}`)
      }
      return options
    },
  },
  watch:{
    'hover.map'(newValue){
      const type = (newValue)? 'HOVER_IN' : 'HOVER_OUT';
      this.emitBackendEvent(type, this.getCurrentTimestamp(), 'map');
    },
    'hover.routeInfo'(newValue){
      const type = (newValue)? 'HOVER_IN' : 'HOVER_OUT';
      this.emitBackendEvent(type, this.getCurrentTimestamp(), 'route_information');
    },
    'hover.generalInfo'(newValue){
      const type = (newValue)? 'HOVER_IN' : 'HOVER_OUT';
      this.emitBackendEvent(type, this.getCurrentTimestamp(), 'general_information');
    },
  },
  computed: {
    delivery_handling_time: function (){
      const scenario = this.user_tasks != null ? this.user_tasks[this.current_task_index].task_scenario : {};
      return scenario.split(" You are tasked to ")[0];
    },
    you_are_tasked_to: function (){
      const scenario = this.user_tasks != null ? this.user_tasks[this.current_task_index].task_scenario : {};
      return `You are tasked to ${scenario.split(" You are tasked to ")[1]}`;
    },
    current_task: function () {
      return this.user_tasks != null ? this.user_tasks[this.current_task_index] : {};
    },
    map_url: function () {
      return this.user_tasks != null ? `${window.location.origin}/maps/${this.current_task.map_id_list[this.current_map_index]}.html` : "";
    },
    map_id_list: function () {
      return this.user_tasks != null ? this.user_tasks[this.current_task_index].map_id_list : [];
    },
    route_start_time: function () {
      return this.user_tasks != null ? JSON.parse(this.user_tasks[this.current_task_index].route_start_time.replace(/'/g, '"')) : [];
    },
    static_info: function (){
      return this.user_tasks != null ? JSON.parse(this.user_tasks[this.current_task_index].static_info.replace(/'/g, '"')) : [];
    },
    chance_list: function (){
      return this.user_tasks != null ? JSON.parse(this.user_tasks[this.current_task_index].chance_list.replace(/'/g, '"')) : [];
    },
    current_route: function () {
      return this.user_tasks != null ? this.map_id_list[this.current_map_index].route : {};
    },
    route_name: function () {
      return `Route ${this.userFriendlyRouteIndex}`
    },
    progressBarSize: function () {
      return (this.demoTab)? 7 : 8;
    }
  },
  created: async function() {
    window.addEventListener('message', this.handleMessageFromIframe);
    this.userId =  this.$route.params.userId;

    if(this.demoTab || this.tutorial || this.training || this.mainTasks){
      this.user_tasks = sample1;
      this.task_info = JSON.parse(localStorage.getItem(`${this.userId}-info`));
    }

    // this.studyCondition = parseInt(JSON.parse(localStorage.getItem(`${this.userId}-info`)).study_condition);
    // this.roomId = localStorage.getItem('room-id');

    // if (this.training){
    //   const res = await this.updateBackend('get_user_training_task');
    //   this.user_tasks = [res]
    // }

    // if (this.mainTasks){
    //   const tasks = localStorage.getItem('user-tasks');
    //   if(tasks === null){
    //     this.result.user_id = this.userId;
    //     this.result.study_condition = this.studyCondition;
    //     this.result.start_time = this.getCurrentTimestamp();
    //     this.user_tasks = await this.updateBackend('get_group_task_instances');
    //     this.current_task_index = 0;
    //     localStorage.setItem('user-tasks', JSON.stringify(this.user_tasks));
    //     localStorage.current_task_index = this.current_task_index;
    //   } else {
    //     this.user_tasks =  JSON.parse(tasks);
    //     this.current_task_index = parseInt(localStorage.current_task_index);
    //   }
    // }

    this.taskIdList = this.extract_task_ids()
    this.route_options = this.generate_route_options();
    this.finishedLoaded=true;
  },
}
</script>

<style scoped>
div {
  padding: 5px;
  margin: 0px;
}

.progress-bar {
  min-height: 10%;
}

.vertical-line {
  border-left: 4px dashed #1d931d;
  display: block;
  height: 100%;
  position: absolute;
  margin-left: 10px;
  margin-right: 5px;
}

.transport-icon {
  z-index: 10;
  position: absolute;
  margin-left: -88%;
  margin-top: -21%;
}

.my-icon {
  z-index: 9;
  position: absolute;
  margin-left: 15%;
  margin-top: -50%;
}

.no-padding {
  padding: 1rem;
}

.no-padding >>> div{
  padding: 0;
}

.custom-list-group .list-group-item {
  position: relative;
  padding-left: 1.5em;
  border: none;
  background-color: #f5f5f5; /* Custom background color */
}

.custom-list-group .list-group-item::before {
  content: '\2022';
  color: black;
  font-weight: bold;
  display: inline-block;
  width: 1em;
  margin-left: -1.5em;
  background-color: #f5f5f5; /* Custom background color */
}

.icon-small {
  width: 1.5rem;
  height: 1.5rem;
}

.custom-task-card {
  border: 2px solid #1e5e29; /* Warmer green border color */
  background-color: #f2fff2; /* Custom background color */
  border-radius: 10px; /* Optional: Rounded corners for a more stylish look */
  padding: 10px; /* Optional: Padding for better content spacing */
  box-shadow: 0 4px 8px rgba(0, 0, 0, 0.1); /* Optional: Add a subtle shadow for depth */
}

.task-card-title {
  color: #2c3e50; /* Navy blue color for the title */
  font-weight: bold;
}

.task-card-text {
  font-size: 16px;
  color: #34495e; /* Slightly lighter blue-grey color for the text */
}

.custom-card {
  border: 0.1rem solid #424244; /* Custom border color */
  background-color: #f5f5f5; /* Custom background color */
  border-radius: 10px; /* Optional: Rounded corners for a more stylish look */
  box-shadow: 0 4px 8px rgba(0, 0, 0, 0.1); /* Optional: Add a subtle shadow for depth */
}

.delivery-card {
  border: 2px solid #3f51b5; /* Professional blue border color */
  background-color: #e8eaf6; /* Light blue-grey background color */
  border-radius: 10px; /* Optional: Rounded corners for a more stylish look */
  box-shadow: 0 4px 8px rgba(0, 0, 0, 0.1); /* Optional: Add a subtle shadow for depth */
}
</style>