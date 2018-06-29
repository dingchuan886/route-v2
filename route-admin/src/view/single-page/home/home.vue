<template>
  <div>
    <address-list :value="addresses" :editable="true"></address-list>
  </div>
</template>

<script>
import addressList from '_c/address-list'

export default {
  components: {
    addressList
  },
  name: 'home',
  data () {
    return {
      addresses: '192.168.1.1:10,192.168.1.2:20'
    }
  }
}
</script>

<style>

</style>
