<template>
  <div class="card">
    <slot></slot>
  </div>
</template>

<style scoped>
.card {
  background: var(--white);
  padding: 40px 30px;
  border-radius: 16px;
  box-shadow: 0 4px 6px -1px rgba(30, 58, 138, 0.1), 0 2px 4px -1px rgba(30, 58, 138, 0.06);
  text-align: center;
  border: 1px solid rgba(226, 232, 240, 0.8);
}
</style>
