<script setup lang="ts">
defineProps(['modelValue', 'placeholder', 'type']);
defineEmits(['update:modelValue']);
</script>

<template>
  <input :type="type || 'text'" :value="modelValue"
    @input="$emit('update:modelValue', ($event.target as HTMLInputElement).value)" :placeholder="placeholder"
    class="app-input" />
</template>

<style scoped>
.app-input {
  width: 100%;
  padding: 14px;
  border: 1.5px solid #e2e8f0;
  border-radius: 8px;
  font-size: 1rem;
  color: var(--text-main);
  outline: none;
  transition: border-color 0.2s;
  box-sizing: border-box;
  text-align: center;
}

.app-input:focus {
  border-color: var(--navy-primary);
  box-shadow: 0 0 0 3px rgba(30, 58, 138, 0.1);
}
</style>
