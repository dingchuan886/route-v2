<template>
  <div>
    <Tag v-if="editable" v-for="address in addressList" :key="address"
         :name="address" closable @on-close="handleDeleteAddress"> {{ address }}
    </Tag>
    <Tag v-if="!editable" v-for="address in addressList" :key="address" :name="address"> {{ address }} </Tag>
    <Button v-if="editable" icon="ios-plus-empty" type="dashed" size="small" @click="handleAddAddress">添加地址</Button>
    <Modal v-model="modal" :footer-hide="true" title="添加地址" @on-cancel="handleModalCancel">
      <Input v-model="inputStr" placeholder="地址格式IP:PORT" @on-enter="handleModalSubmit" />
    </Modal>
  </div>
</template>
<script>
export default {
  name: 'address-list',
  props: {
    value: {
      type: String,
      default: ''
    },
    editable: {
      type: Boolean,
      default: true
    }
  },
  data () {
    return {
      addresses: this.value,
      modal: false,
      inputStr: ''
    }
  },
  computed: {
    addressList () {
      return this.convert2Addresses(this.addresses)
    }
  },
  watch: {
    value (str) {
      this.addresses = str
    },
    addresses (str) {
      this.$emit('on-value-change', str)
    }
  },
  methods: {
    /**
       * 判断地址格式是否为IP:PORT格式的字符串
       * @param address
       * @returns {boolean}
       */
    isValidAddress (address) {
      const ADDRESS_REG = /^(\d{1,2}|1\d\d|2[0-4]\d|25[0-5])\.(\d{1,2}|1\d\d|2[0-4]\d|25[0-5])\.(\d{1,2}|1\d\d|2[0-4]\d|25[0-5])\.(\d{1,2}|1\d\d|2[0-4]\d|25[0-5]):\d+$$/
      return ADDRESS_REG.test(address)
    },
    /**
       * 将字符串格式的地址列表转换为地址数组
       * @param str
       * @returns {*}
       */
    convert2Addresses (str) {
      if (!str || str === '') {
        return []
      }
      return str.split(',')
    },
    /**
       * 将地址数组转换为地址列表字符串
       * @param addresses
       * @returns {string}
       */
    convert2Str (addresses) {
      if (addresses.length === 0) {
        return ''
      }
      return addresses.join(',')
    },
    /**
       * 触发删除地址
       * @param event
       * @param address
       */
    handleDeleteAddress (event, address) {
      let array = this.addressList
      for (let i = array.length - 1; i >= 0; --i) {
        if (address === array[i]) {
          array.splice(i, 1)
          break
        }
      }
      this.addresses = this.convert2Str(array)
    },
    /**
       * 触发添加地址
       */
    handleAddAddress () {
      this.modal = true
    },
    /**
       * 模态对话框触发关闭
       */
    handleModalCancel () {
      this.inputStr = ''
    },
    /**
       * 模态对话框提交
       */
    handleModalSubmit (event) {
      event.preventDefault()

      if (!this.isValidAddress(this.inputStr)) {
        this.$Message.warning('地址格式输入错误')
        return
      }

      if (this.addresses === '') {
        this.addresses = this.inputStr
        this.modal = false
        this.inputStr = ''
        return
      }

      let array = this.addressList
      if (array.indexOf(this.inputStr) !== -1) {
        this.$Message.warning('不能添加相同的地址')
        return
      }

      array.push(this.inputStr)
      this.addresses = this.convert2Str(array)
      this.modal = false
      this.inputStr = ''
    }
  }
}
</script>
