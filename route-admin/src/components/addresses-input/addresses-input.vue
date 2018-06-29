<template>
  <div>
    <Tag v-if="editable" v-for="address in (this.addresses === '' ? [] : this.addresses.split(','))" :key="address"
         :name="address" closable @on-close="handleDeleteAddress"> {{ address }}
    </Tag>
    <Tag v-if="!editable" v-for="address in (this.addresses === '' ? [] : this.addresses.split(','))" :key="address"
         :name="address"> {{ address }}
    </Tag>
    <Button v-if="editable" icon="ios-plus-empty" type="dashed" size="small" @click="handleAddAddress">添加地址</Button>
    <Modal v-model="modal" :footer-hide="true" title="添加地址" @on-cancel="handleModalCancel">
      <Input v-model="addressInput" :autofocus="true" placeholder="输入 IP:PORT 格式的地址" @on-enter="handleModalSubmit"/>
    </Modal>
  </div>
</template>
<script>
function isValidAddress (address) {
  var reg = /^(\d{1,2}|1\d\d|2[0-4]\d|25[0-5])\.(\d{1,2}|1\d\d|2[0-4]\d|25[0-5])\.(\d{1,2}|1\d\d|2[0-4]\d|25[0-5])\.(\d{1,2}|1\d\d|2[0-4]\d|25[0-5]):\d+$$/
  return reg.test(address)
}

export default {
  props: {
    value: {
      type: String,
      default: () => {
        return ''
      }
    },
    editable: {
      type: Boolean,
      default: () => {
        return true
      }
    }
  },
  data () {
    return {
      addresses: this.value,
      modal: false,
      addressInput: ''
    }
  },
  watch: {
    value (val) {
      this.addresses = val
    },
    addresses (val) {
      this.$emit('on-value-change', val)
    }
  },
  methods: {
    handleDeleteAddress (event, name) {
      let array = this.addresses.split(',')
      for (let i = array.length - 1; i >= 0; --i) {
        if (name === array[i]) {
          array.splice(i, 1)
          break
        }
      }
      this.addresses = array.join(',')
    },
    handleAddAddress () {
      this.modal = true
    },
    handleModalSubmit (event) {
      event.preventDefault()

      if (!isValidAddress(this.addressInput)) {
        this.$Message.warning('地址格式输入错误')
        return
      }

      if (this.addresses === '') {
        this.addresses = this.addressInput
        this.modal = false
        this.addressInput = ''
        return
      }

      let array = this.addresses.split(',')
      if (array.indexOf(this.addressInput) !== -1) {
        this.$Message.warning('不能添加相同的地址')
        return
      }
      array.push(this.addressInput)
      this.addresses = array.join(',')
      this.modal = false
      this.addressInput = ''
    },
    handleModalCancel () {
      this.addressInput = ''
    }
  }
}
</script>
