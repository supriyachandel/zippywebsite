import { useState } from 'react'
import { loginUser, registerUser } from '../services/apiService'

export default function AuthModal({ isOpen, onClose, onSuccess, pendingItemName }) {
  const [activeTab, setActiveTab] = useState('login') // 'login' | 'register'
  const [email, setEmail] = useState('')
  const [password, setPassword] = useState('')
  const [name, setName] = useState('')
  const [phone, setPhone] = useState('')
  const [loading, setLoading] = useState(false)
  const [errorMsg, setErrorMsg] = useState('')

  if (!isOpen) return null

  const handleLogin = async (e) => {
    e.preventDefault()
    setErrorMsg('')
    if (!email || !password) {
      setErrorMsg('Please enter both email and password.')
      return
    }

    setLoading(true)
    try {
      const res = await loginUser({ email, password })
      if (res && res.token) {
        onSuccess(res.user, res.token)
        onClose()
      } else {
        setErrorMsg(res?.message || 'Invalid credentials.')
      }
    } catch (err) {
      setErrorMsg(err.message || 'Login failed. Please check credentials.')
    } finally {
      setLoading(false)
    }
  }

  const handleRegister = async (e) => {
    e.preventDefault()
    setErrorMsg('')
    if (!name || !email || !password) {
      setErrorMsg('Please fill in your name, email and password.')
      return
    }

    const regPhone = phone.trim() || ('9' + Math.floor(100000000 + Math.random() * 900000000))

    setLoading(true)
    try {
      const res = await registerUser({
        name,
        email,
        password,
        phone: regPhone,
        gender: 'unisex',
        address: 'MG Road, Indiranagar',
        city: 'Bengaluru'
      })

      if (res && res.token) {
        onSuccess(res.user, res.token)
        onClose()
      } else {
        setErrorMsg(res?.message || 'Registration failed. Try again.')
      }
    } catch (err) {
      setErrorMsg(err.message || 'Registration failed. Try again.')
    } finally {
      setLoading(false)
    }
  }

  // Quick guest login helper for instant testing
  const handleQuickGuest = async () => {
    setLoading(true)
    setErrorMsg('')
    try {
      const guestEmail = `customer_${Date.now()}@zippystyle.com`
      const guestPhone = '9' + Math.floor(100000000 + Math.random() * 900000000)
      const res = await registerUser({
        name: 'Tanya (App User)',
        email: guestEmail,
        password: 'Password123',
        phone: guestPhone,
        gender: 'female',
        address: 'MG Road, Indiranagar',
        city: 'Bengaluru'
      })

      if (res && res.token) {
        onSuccess(res.user, res.token)
        onClose()
      }
    } catch (err) {
      setErrorMsg('Quick login error: ' + err.message)
    } finally {
      setLoading(false)
    }
  }

  return (
    <div className="auth-modal-overlay" onClick={onClose}>
      <div className="auth-modal-card" onClick={(e) => e.stopPropagation()}>
        <button className="auth-close-btn" onClick={onClose}>&times;</button>

        <div className="auth-modal-header">
          <div className="auth-brand-logo">
            <span className="logo-badge">⚡ Zippystyle</span>
          </div>
          <h3>{activeTab === 'login' ? 'Welcome Back' : 'Create Account'}</h3>
          <p className="auth-sub">
            {pendingItemName 
              ? `Please authenticate to add "${pendingItemName}" to your shopping bag.` 
              : 'Sign in to access 2-Hour Home Trials, Express Orders & Saved Bags.'}
          </p>
        </div>

        {/* Tabs: Sign In / Sign Up */}
        <div className="auth-tabs">
          <button
            className={`auth-tab-btn ${activeTab === 'login' ? 'active' : ''}`}
            onClick={() => { setActiveTab('login'); setErrorMsg('') }}
          >
            Sign In
          </button>
          <button
            className={`auth-tab-btn ${activeTab === 'register' ? 'active' : ''}`}
            onClick={() => { setActiveTab('register'); setErrorMsg('') }}
          >
            Create Account
          </button>
        </div>

        {errorMsg && <div className="auth-error-banner">⚠️ {errorMsg}</div>}

        {activeTab === 'login' ? (
          <form className="auth-form" onSubmit={handleLogin}>
            <div className="form-group">
              <label>Email Address</label>
              <input
                type="email"
                placeholder="e.g. user@example.com"
                value={email}
                onChange={(e) => setEmail(e.target.value)}
                required
              />
            </div>

            <div className="form-group">
              <label>Password</label>
              <input
                type="password"
                placeholder="Enter password"
                value={password}
                onChange={(e) => setPassword(e.target.value)}
                required
              />
            </div>

            <button className="auth-submit-btn" type="submit" disabled={loading}>
              {loading ? 'Authenticating...' : 'Sign In & Continue'}
            </button>
          </form>
        ) : (
          <form className="auth-form" onSubmit={handleRegister}>
            <div className="form-group">
              <label>Full Name</label>
              <input
                type="text"
                placeholder="e.g. Tanya Sharma"
                value={name}
                onChange={(e) => setName(e.target.value)}
                required
              />
            </div>

            <div className="form-group">
              <label>Email Address</label>
              <input
                type="email"
                placeholder="e.g. tanya@example.com"
                value={email}
                onChange={(e) => setEmail(e.target.value)}
                required
              />
            </div>

            <div className="form-group">
              <label>Mobile Phone</label>
              <input
                type="tel"
                placeholder="e.g. 9876543210"
                value={phone}
                onChange={(e) => setPhone(e.target.value)}
              />
            </div>

            <div className="form-group">
              <label>Create Password</label>
              <input
                type="password"
                placeholder="Minimum 6 characters"
                value={password}
                onChange={(e) => setPassword(e.target.value)}
                required
              />
            </div>

            <button className="auth-submit-btn" type="submit" disabled={loading}>
              {loading ? 'Creating Account...' : 'Register & Continue'}
            </button>
          </form>
        )}

        <div className="auth-divider">
          <span>OR</span>
        </div>

        <button className="quick-guest-btn" onClick={handleQuickGuest} disabled={loading}>
          ⚡ 1-Click Instant Guest Sign In
        </button>
      </div>
    </div>
  )
}
