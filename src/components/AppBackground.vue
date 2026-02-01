<script setup lang="ts">
import PageLayout from './PageLayout.vue';
</script>

<template>
  <div class="landing-background">
    <PageLayout>
      <slot></slot>
    </PageLayout>
  </div>
</template>

<style scoped>
.landing-background {
  min-height: 100vh;
  width: 100%;
  background:
    linear-gradient(to bottom right, rgba(30, 58, 138, 0.9), rgba(23, 37, 84, 0.8)),
    url('@/assets/images/malupet.png') no-repeat center center;
  background-size: cover;
  background-blend-mode: multiply;
  padding: 20px 0;
  overflow-y: auto;
}
</style>
