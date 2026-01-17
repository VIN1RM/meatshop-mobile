import axios from 'axios'
import { getToken } from '../storage/auth_storage'

const api = axios.create({
  baseURL: 'http://localhost:3000', // ajuste depois
  timeout: 10000,
})

api.interceptors.request.use(async config => {
  const token = await getToken()

  if (token) {
    config.headers.Authorization = `Bearer ${token}`
  }

  return config
})

export default api
