<template>
  <AppBackground>
    <AppCard>
      <h2 class="title">Find Student</h2>
      <p class="subtitle">Enter LRN manually to proceed.</p>


      <AppInput v-model="lrn" placeholder="Enter LRN..." @keyup.enter="checkLRN"
        @input="showRegisterOption = false; error = ''" />


      <div v-if="error" class="error-msg" :class="{ 'info-msg': showRegisterOption }">{{ error }}</div>

      <AppButton @click="checkLRN" :disabled="loading || !lrn" v-if="!showRegisterOption">
        {{ loading ? 'Searching...' : 'Enter' }}
      </AppButton>

      <AppButton @click="goToRegister" v-if="showRegisterOption" class="btn-register">
        Register New Student
      </AppButton>

      <router-link to="/" custom v-slot="{ navigate }">
        <AppButton variant="secondary" @click="navigate">Cancel</AppButton>
      </router-link>
    </AppCard>
  </AppBackground>
</template>

<script setup lang="ts">
import { ref } from 'vue';
import { useRouter } from 'vue-router';
import api from '../services/api';
import AppBackground from '../components/AppBackground.vue';
import AppCard from '../components/AppCard.vue';
import AppButton from '../components/AppButton.vue';
import AppInput from '../components/AppInput.vue';
import AppFormGroup from '../components/AppFormGroup.vue';

const router = useRouter();
const lrn = ref('');
const loading = ref(false);
const error = ref('');
const showRegisterOption = ref(false);

const checkLRN = async () => {
  if (!lrn.value) return;
  loading.value = true;
  error.value = '';
  showRegisterOption.value = false;

  try {
    const response = await api.get(`/check-lrn/${lrn.value}`);
    if (response.data.action === 'go_to_symptoms') {
      router.push({ name: 'assessment', params: { lrn: lrn.value } });
    } else {
      error.value = `LRN ${lrn.value} is not registered.`;
      showRegisterOption.value = true;
    }
  } catch (err: any) {
    if (err.response?.status === 404) {
      error.value = `Student with LRN ${lrn.value} not found.`;
      showRegisterOption.value = true;
    } else {
      error.value = "Connection Error. Please try again.";
    }
  } finally {
    loading.value = false;
  }
};

const goToRegister = () => router.push({ name: 'register', params: { lrn: lrn.value } });
</script>

<style scoped>
.title {
  color: var(--navy-primary);
  font-size: 1.5rem;
  margin-bottom: 5px;
  font-weight: 700;
}

.subtitle {
  color: var(--text-sub);
  font-size: 0.9rem;
  margin-bottom: 30px;
}

.error-msg {
  color: var(--danger);
  font-size: 0.9rem;
  margin-top: 15px;
  padding: 10px;
  background-color: #fee2e2;
  border-radius: 6px;
}

.info-msg {
  color: var(--navy-primary);
  background-color: var(--blue-light);
  border: 1px solid #dbeafe;
}

.btn-register {
  background-color: var(--success) !important;
}

.btn-register:hover {
  background-color: #059669 !important;
}
</style>
