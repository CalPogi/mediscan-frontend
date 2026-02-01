<script setup lang="ts">
defineProps<{
  disabled?: boolean;
  variant?: 'primary' | 'secondary';
}>();
</script>

<template>
  <button :class="['btn', variant || 'primary']" :disabled="disabled">
    <slot></slot>
  </button>
</template>

<style scoped>
.btn {
  width: 100%;
  padding: 14px;
  border-radius: 8px;
  border: none;
  font-size: 1rem;
  font-weight: 600;
  cursor: pointer;
  transition: all 0.2s ease;
  margin-top: 15px;
}

.btn:disabled {
  opacity: 0.6;
  cursor: not-allowed;
}

/* Primary: Navy Blue */
.primary {
  background-color: var(--navy-primary);
  color: white;
}

.primary:hover:not(:disabled) {
  background-color: var(--navy-hover);
  transform: translateY(-1px);
}

/* Secondary: Ghost/Outline */
.secondary {
  background-color: transparent;
  color: var(--text-sub);
}

.secondary:hover:not(:disabled) {
  color: var(--navy-primary);
  text-decoration: underline;
}
</style>
