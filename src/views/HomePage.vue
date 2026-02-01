<template>
  <AppBackground>
    <AppCard class="glass-card">
      <div class="logo-area">
        <img src="@/assets/images/dhs.png" alt="DHS Logo" class="logo-img" />
      </div>

      <h1 class="brand">MEDiSCAN</h1>
      <p class="subtitle">School Clinic Assistant</p>

      <div class="divider"></div>

      <h3 class="card-title">Feeling unwell?</h3>
      <p class="card-text">Get instant assessment and medication dispensing.</p>

      <router-link to="/login" custom v-slot="{ navigate }">
        <AppButton @click="navigate">START CONSULTATION</AppButton>
      </router-link>
    </AppCard>
  </AppBackground>
</template>

<script setup lang="ts">
import AppBackground from '../components/AppBackground.vue';
import AppCard from '../components/AppCard.vue';
import AppButton from '../components/AppButton.vue';
</script>


<style scoped>
:deep(.glass-card) {
  background-color: rgba(255, 255, 255, 0.5) !important;
  backdrop-filter: blur(12px);
  border: 1px solid rgba(255, 255, 255, 0.3);
}

.logo-area {
  width: 90px;
  height: 90px;
  margin: 0 auto 15px;
  display: flex;
  align-items: center;
  justify-content: center;
}

.logo-img {
  width: 100%;
  height: 100%;
  object-fit: contain;
  filter: drop-shadow(0 4px 6px rgba(0, 0, 0, 0.1));
}

.brand {
  color: var(--navy-primary);
  font-size: 2.2rem;
  font-weight: 800;
  letter-spacing: 1px;
}

.subtitle {
  color: var(--text-sub);
  font-size: 1rem;
  margin-bottom: 25px;
  font-weight: 500;
}

.divider {
  height: 1px;
  background: rgba(30, 58, 138, 0.1);
  margin: 20px 0;
}

.card-title {
  color: var(--navy-primary);
  margin-bottom: 8px;
  font-size: 1.2rem;
  font-weight: 700;
}

.card-text {
  color: var(--text-main);
  font-size: 1rem;
  margin-bottom: 25px;
  line-height: 1.5;
}
</style>
