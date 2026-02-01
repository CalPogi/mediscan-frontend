<template>
  <AppBackground>
    <AppCard class="glass-card">
      <h2 class="title">Student Registration</h2>
      <p class="subtitle">First time? Please fill in your details.</p>

      <form @submit.prevent="registerStudent">

        <AppFormGroup label="LRN">
          <AppInput v-model="form.lrn" readonly class="readonly-input" />
        </AppFormGroup>

        <AppFormGroup label="Full Name">
          <AppInput v-model="form.name" placeholder="Juan Dela Cruz" required />
        </AppFormGroup>

        <AppFormGroup label="Grade Level">
          <select v-model="selectedGradeId" @change="filterSections" class="app-select" required>
            <option disabled value="">Select Grade</option>
            <option v-for="grade in schoolData" :key="grade.id" :value="grade.id">{{ grade.name }}</option>
          </select>
        </AppFormGroup>

        <AppFormGroup label="Section">
          <select v-model="form.section_id" class="app-select" :disabled="!selectedGradeId" required>
            <option disabled value="">Select Section</option>
            <option v-for="section in filteredSections" :key="section.id" :value="section.id">{{ section.name }}
            </option>
          </select>
        </AppFormGroup>

        <AppFormGroup label="Guardian Name">
          <AppInput v-model="form.guardian_name" required />
        </AppFormGroup>

        <AppFormGroup label="Guardian Contact">
          <AppInput v-model="form.guardian_contact" placeholder="+639..." required />
        </AppFormGroup>

        <div v-if="error" class="error-msg">{{ error }}</div>

        <AppButton type="submit" :disabled="isSubmitting">
          {{ isSubmitting ? 'Registering...' : 'Complete Registration' }}
        </AppButton>

        <router-link to="/login" custom v-slot="{ navigate }">
          <AppButton variant="secondary" @click="navigate">Cancel</AppButton>
        </router-link>
      </form>
    </AppCard>
  </AppBackground>
</template>

<script setup lang="ts">
import { ref, onMounted } from 'vue';
import { useRoute, useRouter } from 'vue-router';
import api from '../services/api';
import AppBackground from '../components/AppBackground.vue';
import AppCard from '../components/AppCard.vue';
import AppButton from '../components/AppButton.vue';
import AppInput from '../components/AppInput.vue';
import AppFormGroup from '../components/AppFormGroup.vue';

const route = useRoute();
const router = useRouter();

const schoolData = ref<any[]>([]);
const filteredSections = ref<any[]>([]);
const selectedGradeId = ref('');
const isSubmitting = ref(false);
const error = ref('');

const form = ref({
  lrn: (route.params.lrn as string) || '',
  name: '',
  section_id: '',
  guardian_name: '',
  guardian_contact: '+63'
});

onMounted(async () => {
  try {
    const response = await api.get('/school-data');
    schoolData.value = response.data;
  } catch (err) { error.value = "Failed to load school data."; }
});

const filterSections = () => {
  const grade = schoolData.value.find(g => g.id === selectedGradeId.value);
  filteredSections.value = grade ? grade.sections : [];
  form.value.section_id = '';
};

const registerStudent = async () => {
  isSubmitting.value = true;
  error.value = '';
  try {
    await api.post('/register', form.value);
    alert("Registration Successful!");
    router.push({ name: 'assessment', params: { lrn: form.value.lrn } });
  } catch (err: any) {
    error.value = err.response?.data?.message || "Registration failed.";
  } finally {
    isSubmitting.value = false;
  }
};
</script>


<style scoped>
:deep(.glass-card) {
  background-color: rgba(255, 255, 255, 0.9) !important;
  backdrop-filter: blur(12px);
  border: 1px solid rgba(255, 255, 255, 0.3);
}

.title {
  color: var(--navy-primary);
  font-size: 1.5rem;
  margin-bottom: 5px;
  font-weight: 800;
}

.subtitle {
  color: var(--text-sub);
  font-size: 0.9rem;
  margin-bottom: 25px;
}

.app-select {
  width: 100%;
  padding: 14px;
  border: 1.5px solid #e2e8f0;
  border-radius: 8px;
  font-size: 1rem;
  color: var(--text-main);
  background-color: white;
  outline: none;
  transition: border-color 0.2s;
  cursor: pointer;
}

.app-select:focus {
  border-color: var(--navy-primary);
}

.app-select:disabled {
  background-color: #f1f5f9;
  cursor: not-allowed;
  color: #94a3b8;
}

:deep(.readonly-input) {
  background-color: #f1f5f9;
  color: #64748b;
  cursor: not-allowed;
  border-color: #e2e8f0;
}

.error-msg {
  color: #ef4444;
  background: #fee2e2;
  padding: 10px;
  border-radius: 6px;
  font-size: 0.85rem;
  text-align: center;
}
</style>
