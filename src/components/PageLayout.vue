<template>
  <div class="layout-container">
    <div class="content-width">
      <slot></slot>
    </div>
  </div>
</template>

<style scoped>
.layout-container {
  min-height: 100vh;
  display: flex;
  justify-content: center;
  align-items: center;
  padding: 20px;
}

.content-width {
  width: 100%;
  max-width: 400px;
}
</style>
