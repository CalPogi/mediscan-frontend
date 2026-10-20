<template>
  <AppBackground>
    <AppCard class="glass-card wide-card">

      <div class="header">
        <h2>Medical Assessment</h2>
        <p class="lrn">{{ lrn }}</p>
        <p v-if="studentName" class="greeting">
          Hello, <span class="name">{{ studentName }}</span>
        </p>
      </div>

      <div v-if="!recommendation" class="form-content">

        <AppFormGroup label="Symptoms">
          <div class="checkbox-list">
            <label v-for="sym in availableSymptoms" :key="sym" class="checkbox-item">
              <input type="checkbox" :value="sym" v-model="symptoms">
              <span>{{ sym }}</span>
            </label>
          </div>
        </AppFormGroup>

        <AppFormGroup label="Pain Level (1 - Mild, 5 - Severe)">
          <div class="pain-scale">
            <button v-for="num in 5" :key="num" type="button" :class="['pain-btn', { active: painLevel === num }]"
              @click="painLevel = num">
              {{ num }}
            </button>
          </div>
        </AppFormGroup>

        <div class="grid-row">
          <AppFormGroup label="Sleep (Hours)">
            <AppInput type="number" v-model="sleepHours" placeholder="e.g. 6" />
          </AppFormGroup>

          <AppFormGroup label="Water (Glasses)">
            <AppInput type="number" v-model="waterIntake" placeholder="Today" />
          </AppFormGroup>
        </div>

        <AppFormGroup label="Last Meal">
          <select v-model="lastMeal" class="app-select">
            <option disabled value="">Select...</option>
            <option value="skipped">Skipped Meal / Empty Stomach</option>
            <option value="recent">Less than 2 hours ago</option>
            <option value="regular">More than 4 hours ago</option>
          </select>
        </AppFormGroup>

        <div v-if="error" class="error-msg">{{ error }}</div>

        <AppButton @click="submitAssessment" :disabled="symptoms.length === 0 || isLoading">
          {{ isLoading ? 'Analyzing...' : 'Get Recommendation' }}
        </AppButton>
      </div>

      <div v-else>
        <h3 class="rec-label">Recommendation</h3>

        <div v-if="recommendation.advice" class="advice-box">
          <p><strong>Note:</strong> {{ recommendation.advice }}</p>
        </div>

        <div class="med-box">
          <h1 :class="{ 'text-gray': recommendation.name === 'None' }">
            {{ recommendation.name === 'None' ? 'Consultation Required' : recommendation.name }}
          </h1>
          <p>{{ recommendation.name === 'None' ? 'No medication dispensed.' : recommendation.dosage }}</p>
        </div>

        <p class="disclaimer">By dispensing, you confirm this is for personal use.</p>

        <AppButton v-if="recommendation.name !== 'None'" @click="dispenseMedicine" :disabled="isDispensing">
          {{ isDispensing ? 'Dispensing...' : 'DISPENSE NOW' }}
        </AppButton>

        <AppButton variant="secondary" @click="recommendation = null" :disabled="isDispensing">
          Back
        </AppButton>
      </div>

    </AppCard>
  </AppBackground>
</template>

<script setup lang="ts">
import { ref, onMounted, computed } from 'vue';
import { useRoute, useRouter } from 'vue-router';
import api from '../services/api';
import AppBackground from '../components/AppBackground.vue';
import AppCard from '../components/AppCard.vue';
import AppButton from '../components/AppButton.vue';
import AppInput from '../components/AppInput.vue';
import AppFormGroup from '../components/AppFormGroup.vue';

const route = useRoute();
const router = useRouter();
const lrn = ref(route.params.lrn as string);

const studentName = ref('');
const studentSex = ref('');

const symptoms = ref<string[]>([]);
const painLevel = ref(0);
const sleepHours = ref<number | null>(null);
const waterIntake = ref<number | null>(null);
const lastMeal = ref('');

const recommendation = ref<{ name: string; dosage: string; advice?: string } | null>(null);
const isLoading = ref(false);
const isDispensing = ref(false);
const error = ref('');

const availableSymptoms = computed(() => {
  const baseSymptoms = ['Headache', 'Fever', 'Cough', 'Colds', 'Stomach Pain', 'Dizziness'];

  if (studentSex.value === 'Female') {
    baseSymptoms.push('Menstrual Cramps');
  }

  return baseSymptoms;
});

onMounted(async () => {
  try {
    const { data, error: rpcError } = await api.rpc('check_lrn', { p_lrn: lrn.value });
    if (rpcError) throw rpcError;
    const student = data as { found: boolean; name: string; sex: string };
    if (student.found) {
      studentName.value = student.name;
      studentSex.value = student.sex;
    }
  } catch {
    console.error("Could not fetch student details");
  }
});

const submitAssessment = async () => {
  if (symptoms.value.length === 0) return;

  isLoading.value = true;
  error.value = '';
  recommendation.value = null;

  try {
    const { data, error: rpcError } = await api.rpc('assess', {
      p_symptoms: symptoms.value,
      p_pain_level: painLevel.value
    });
    if (rpcError) throw rpcError;
    const res = data as { recommendation: string; dosage: string; advice?: string };

    recommendation.value = {
      name: res.recommendation,
      dosage: res.dosage,
      advice: res.advice
    };

  } catch (err) {
    error.value = (err as Error).message || "Assessment failed. Please try again.";
  } finally {
    isLoading.value = false;
  }
};

const dispenseMedicine = async () => {
  if (!recommendation.value) return;
  isDispensing.value = true;

  try {
    const { error: rpcError } = await api.rpc('request_dispense', {
      p_lrn: lrn.value,
      p_symptoms: symptoms.value,
      p_pain_level: painLevel.value
    });
    if (rpcError) throw rpcError;

    alert(`Success! Dispensing ${recommendation.value.name}.`);
    router.push('/');
  } catch {
    alert("Hardware timeout.");
  } finally {
    isDispensing.value = false;
  }
};
</script>

<style scoped>
:deep(.glass-card) {
  background-color: rgba(255, 255, 255, 0.95) !important;
  backdrop-filter: blur(12px);
  border: 1px solid rgba(255, 255, 255, 0.3);
  max-width: 500px;
}

.header {
  margin-bottom: 20px;
  border-bottom: 1px solid #e2e8f0;
  padding-bottom: 10px;
  text-align: center;
}

.header h2 {
  color: var(--navy-primary);
  margin: 0;
}

.greeting {
  color: var(--text-main);
  margin-top: 5px;
}

.name {
  color: var(--navy-primary);
  font-weight: bold;
}

.lrn {
  font-family: monospace;
  color: var(--text-sub);
}

.checkbox-list {
  display: grid;
  grid-template-columns: 1fr 1fr;
  gap: 8px;
}

.checkbox-item {
  display: flex;
  align-items: center;
  padding: 10px;
  background: #f1f5f9;
  border-radius: 6px;
  cursor: pointer;
  transition: 0.2s;
}

.checkbox-item:hover {
  background: #e2e8f0;
}

.checkbox-item input {
  margin-right: 8px;
  accent-color: var(--navy-primary);
}

.pain-scale {
  display: flex;
  gap: 8px;
  justify-content: space-between;
}

.pain-btn {
  flex: 1;
  padding: 10px;
  border: 1px solid #cbd5e1;
  background: white;
  border-radius: 6px;
  cursor: pointer;
  font-weight: bold;
  color: #64748b;
}

.pain-btn.active {
  background: var(--navy-primary);
  color: white;
  border-color: var(--navy-primary);
  transform: scale(1.05);
}

.grid-row {
  display: flex;
  gap: 15px;
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

.rec-label {
  color: var(--text-sub);
  font-size: 0.9rem;
  text-transform: uppercase;
  letter-spacing: 1px;
  margin-bottom: 10px;
}

.med-box {
  background: #eff6ff;
  border: 1px solid #dbeafe;
  padding: 20px;
  border-radius: 12px;
  margin: 15px 0;
  text-align: center;
}

.med-box h1 {
  color: var(--navy-primary);
  margin: 0;
  font-size: 1.8rem;
}

.text-gray {
  color: #64748b !important;
  font-size: 1.4rem !important;
}

.advice-box {
  background: #fff7ed;
  border-left: 4px solid #f97316;
  padding: 12px;
  text-align: left;
  font-size: 0.9rem;
  color: #9a3412;
  margin-bottom: 15px;
  border-radius: 4px;
}

.disclaimer {
  font-size: 0.8rem;
  color: #94a3b8;
  margin-bottom: 10px;
}

.error-msg {
  background: #fee2e2;
  color: #ef4444;
  padding: 8px;
  border-radius: 6px;
  margin-top: 10px;
  text-align: center;
}
</style>
