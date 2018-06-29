<template>
  <div>
    <input type="text" v-focus="focused" @focus="focused = true" @blur="focused = false"/>
    <input type="button" @click="focused = true;" value="切换1"/>
    <input type="button" @click="focused = false;" value="切换2"/>
  </div>
</template>
<script>
import {focus} from 'vue-focus'

export default {
  name: 'level-1',
  directives: {focus: focus},
  data: function () {
    return {
      focused: true
    }
  }
}
</script>
