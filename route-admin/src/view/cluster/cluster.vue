<template>
  <addresses-input :value="addresses" :editable="editable"></addresses-input>
</template>
<script>
import addressesInput from '_c/addresses-input'

export default {
  data () {
    return {
      addresses: '192.168.1.1:1020,192.168.1.1:1021',
      editable: true
    }
  },
  components: {
    addressesInput
  },
  methods: {
  }
}
</script>
