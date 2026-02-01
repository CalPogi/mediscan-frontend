<script setup lang="ts">
defineProps<{ label: string }>();
</script>

<template>
  <div class="form-group">
    <label>{{ label }}</label>
    <slot></slot>
  </div>
</template>

<style scoped>
.form-group {
  margin-bottom: 15px;
  width: 100%;
  text-align: left;
}

label {
  font-size: 0.85rem;
  font-weight: 600;
  color: var(--navy-primary);
  margin-bottom: 6px;
  display: block;
  margin-left: 2px;
}
</style>
