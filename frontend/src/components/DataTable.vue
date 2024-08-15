<template>
  <div class="table">
    <v-table
      density="compact"
      ref="datatable"
      width="50%"
      hover
      :hide-default-footer="hideDefaultFooter"
      :items-per-page="10"
      >
      <thead class="table-header">
        <tr>
          <th v-for="header in tableHeaders" :key="header.text" class="text-left">
            {{header.text}}
          </th>
        </tr>
      </thead>
      <tbody>
        <tr v-for="item in tableItems" :key="item.name">
          <td class="text-xs-left"
            v-for="header in tableHeaders"
            :key="header.text"
            >
            {{ item[header.value] }}
          </td>
        </tr>
      </tbody>
    </v-table>
  </div>
</template>

<script>
export default {
  props: {
    tableHeaders: {
      required: true,
      type: Array
    },
    tableItems: {
      required: true,
      type: Array
    },
    hideDefaultFooter: {
      type: Boolean,
      default: true
    }
  }
}
</script>

<style>
.table-header {
  background-color: rgb(var(--v-theme-primary))
}
.table {
  width: 100%;
}
</style>
