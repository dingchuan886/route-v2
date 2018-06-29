<template>
  <div>
    <Tag v-if="editable" v-for="address in (this.addresses === '' ? [] : this.addresses.split(','))" :key="address"
         :name="address" closable @on-close="handleDeleteAddress"> {{ address }}
    </Tag>
    <Tag v-if="!editable" v-for="address in (this.addresses === '' ? [] : this.addresses.split(','))" :key="address"
         :name="address"> {{ address }}
    </Tag>
    <Button v-if="editable" icon="ios-plus-empty" type="dashed" size="small" @click="handleAddAddress">添加地址</Button>
    <Modal v-model="modal" title="提示" @on-ok="handleModalSubmit" @on-cancel="handleModalCancel">
      <p>ddd</p>
    </Modal>
  </div>
</template>
<script>
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
      modal: false
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
    handleModalSubmit () {
      this.$Message.info('Clicked ok')
    },
    handleModalCancel () {
      this.$Message.info('Clicked cancel')
    }
  }
}
</script>
