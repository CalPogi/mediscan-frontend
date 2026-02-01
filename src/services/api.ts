import axios from 'axios'

const api = axios.create({
  baseURL: 'https://mediscan-backend-a9lx.onrender.com/api',
  headers: {
    'Content-Type': 'application/json',
    Accept: 'application/json',
  },
})

export default api
