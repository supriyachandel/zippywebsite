import { useState, useEffect } from 'react'
import { fetchUserProfile, fetchUserPurchases, fetchUserAddresses, updateUserProfile, createUserAddress, logoutUser } from '../services/apiService'

export default function ProfileModal({ isOpen, onClose, currentUser, onLogout, onProfileUpdated }) {
  const [activeTab, setActiveTab] = useState('orders') // 'orders' | 'profile' | 'addresses'
  const [profile, setProfile] = useState(currentUser || null)
  const [orders, setOrders] = useState([])
  const [addresses, setAddresses] = useState([])
  const [loading, setLoading] = useState(false)
  const [error, setError] = useState(null)
  const [successMsg, setSuccessMsg] = useState('')

  // Edit Profile Form State
  const [editName, setEditName] = useState('')
  const [editPhone, setEditPhone] = useState('')
  const [editCity, setEditCity] = useState('')
  const [savingProfile, setSavingProfile] = useState(false)

  // New Address Form State
  const [showAddAddress, setShowAddAddress] = useState(false)
  const [newAddrLabel, setNewAddrLabel] = useState('Home')
  const [newAddrLine, setNewAddrLine] = useState('')
  const [newAddrCity, setNewAddrCity] = useState('Bengaluru')
  const [newAddrZip, setNewAddrZip] = useState('560038')
  const [savingAddress, setSavingAddress] = useState(false)

  useEffect(() => {
    if (!isOpen) return
    let isMounted = true

    async function loadData() {
      setLoading(true)
      setError(null)
      setSuccessMsg('')
      try {
        const [profData, ordersData, addrData] = await Promise.allSettled([
          fetchUserProfile(),
          fetchUserPurchases(),
          fetchUserAddresses()
        ])

        if (isMounted) {
          if (profData.status === 'fulfilled' && profData.value) {
            setProfile(profData.value)
            setEditName(profData.value.name || '')
            setEditPhone(profData.value.phone || '')
            setEditCity(profData.value.city || 'Bengaluru')
          } else if (currentUser) {
            setProfile(currentUser)
            setEditName(currentUser.name || '')
            setEditPhone(currentUser.phone || '')
            setEditCity(currentUser.city || 'Bengaluru')
          }

          if (ordersData.status === 'fulfilled' && ordersData.value) {
            setOrders(ordersData.value)
          }

          if (addrData.status === 'fulfilled' && addrData.value) {
            setAddresses(addrData.value)
          }
        }
      } catch (err) {
        if (isMounted) setError(err.message)
      } finally {
        if (isMounted) setLoading(false)
      }
    }

    loadData()
    return () => { isMounted = false }
  }, [isOpen, currentUser])

  if (!isOpen) return null

  const handleSaveProfile = async (e) => {
    e.preventDefault()
    setSavingProfile(true)
    setSuccessMsg('')
    setError(null)
    try {
      if (profile?.id) {
        await updateUserProfile(profile.id, {
          name: editName,
          phone: editPhone,
          city: editCity
        })
      }
      const updated = { ...profile, name: editName, phone: editPhone, city: editCity }
      setProfile(updated)
      if (onProfileUpdated) onProfileUpdated(updated)
      setSuccessMsg('Profile updated successfully!')
      setTimeout(() => setSuccessMsg(''), 3000)
    } catch (err) {
      setError(err.message || 'Failed to update profile')
    } finally {
      setSavingProfile(false)
    }
  }

  const handleAddAddress = async (e) => {
    e.preventDefault()
    if (!newAddrLine) return
    setSavingAddress(true)
    setSuccessMsg('')
    setError(null)
    try {
      await createUserAddress({
        label: newAddrLabel,
        name: profile?.name || 'Customer',
        phone: profile?.phone || '9876543210',
        address: newAddrLine,
        city: newAddrCity,
        state: 'Karnataka',
        zip: newAddrZip,
        is_default: true,
        latitude: '12.9716',
        longitude: '77.5946'
      })
      const freshAddrs = await fetchUserAddresses().catch(() => [])
      setAddresses(freshAddrs)
      setShowAddAddress(false)
      setNewAddrLine('')
      setSuccessMsg('Address added successfully!')
      setTimeout(() => setSuccessMsg(''), 3000)
    } catch (err) {
      setError(err.message || 'Failed to save address')
    } finally {
      setSavingAddress(false)
    }
  }

  return (
    <div className="profile-modal-overlay" onClick={onClose}>
      <div className="profile-modal-card" onClick={(e) => e.stopPropagation()}>
        {/* Header with User Info summary */}
        <div className="profile-modal-header">
          <button className="profile-close-btn" onClick={onClose}>&times;</button>
          <div className="profile-avatar-banner">
            <div className="profile-avatar-circle">
              {profile?.name ? profile.name.charAt(0).toUpperCase() : '👤'}
            </div>
            <div className="profile-banner-info">
              <h3>{profile?.name || currentUser?.name || 'Zippy Customer'}</h3>
              <p className="profile-email">{profile?.email || currentUser?.email}</p>
              <span className="profile-badge-pill">⚡ Verified Member</span>
            </div>
          </div>
        </div>

        {/* Navigation Tabs */}
        <div className="profile-nav-tabs">
          <button
            className={`profile-tab-btn ${activeTab === 'orders' ? 'active' : ''}`}
            onClick={() => { setActiveTab('orders'); setError(null); setSuccessMsg('') }}
          >
            📦 My Orders & Trials {orders.length > 0 && <span className="tab-count">({orders.length})</span>}
          </button>
          <button
            className={`profile-tab-btn ${activeTab === 'profile' ? 'active' : ''}`}
            onClick={() => { setActiveTab('profile'); setError(null); setSuccessMsg('') }}
          >
            👤 Personal Info
          </button>
          <button
            className={`profile-tab-btn ${activeTab === 'addresses' ? 'active' : ''}`}
            onClick={() => { setActiveTab('addresses'); setError(null); setSuccessMsg('') }}
          >
            📍 Saved Addresses
          </button>
        </div>

        {successMsg && <div className="profile-alert success">✓ {successMsg}</div>}
        {error && <div className="profile-alert error">⚠️ {error}</div>}

        {/* Modal Body Content */}
        <div className="profile-modal-body">
          {loading ? (
            <div className="profile-loading-view">
              <div className="spinner"></div>
              <p>Loading your account details...</p>
            </div>
          ) : activeTab === 'orders' ? (
            /* ─── Orders & Home Trials Tab ─── */
            <div className="orders-tab-view">
              {orders.length === 0 ? (
                <div className="profile-empty-state">
                  <span className="empty-icon">🛍️</span>
                  <h4>No orders placed yet</h4>
                  <p>Browse live local boutiques and try your favorite clothes at home before buying!</p>
                </div>
              ) : (
                <div className="orders-list">
                  {orders.map((order) => (
                    <div key={order.id} className="order-history-card">
                      <div className="order-card-header">
                        <div>
                          <span className="order-id-label">{order.orderNumber}</span>
                          <span className="order-date-label">
                            {new Date(order.createdAt).toLocaleDateString('en-IN', {
                              day: 'numeric',
                              month: 'short',
                              year: 'numeric'
                            })}
                          </span>
                        </div>
                        <span className={`order-status-badge status-${(order.status || 'processing').toLowerCase()}`}>
                          {order.status || '⚡ Processing'}
                        </span>
                      </div>

                      <div className="order-items-preview">
                        {order.purchasedProducts.map((p, idx) => (
                          <div key={idx} className="order-item-row">
                            {p.imageUrl ? (
                              <img src={p.imageUrl} alt={p.name} className="order-item-thumb" />
                            ) : (
                              <div className="order-item-thumb-fallback">👕</div>
                            )}
                            <div className="order-item-meta">
                              <span className="item-name">{p.name}</span>
                              <span className="item-sub">
                                Qty: {p.quantity} {p.size && `• Size: ${p.size}`} {p.color && `• Color: ${p.color}`}
                              </span>
                            </div>
                            <span className="item-price">₹{p.paidPrice.toLocaleString()}</span>
                          </div>
                        ))}
                      </div>

                      <div className="order-card-footer">
                        <div className="order-payment-info">
                          <span>Payment: <strong>{order.paymentMethod}</strong></span>
                          {order.address && <span> • Deliver to: <strong>{order.address.city || 'Home'}</strong></span>}
                        </div>
                        <div className="order-total-price">
                          Total: <strong>₹{order.totalPaidPrice.toLocaleString()}</strong>
                        </div>
                      </div>
                    </div>
                  ))}
                </div>
              )}
            </div>
          ) : activeTab === 'profile' ? (
            /* ─── Profile Info Tab ─── */
            <form className="profile-form-view" onSubmit={handleSaveProfile}>
              <div className="form-group-row">
                <div className="form-group">
                  <label>Full Name</label>
                  <input
                    type="text"
                    value={editName}
                    onChange={(e) => setEditName(e.target.value)}
                    required
                  />
                </div>
                <div className="form-group">
                  <label>Email Address</label>
                  <input
                    type="email"
                    value={profile?.email || ''}
                    disabled
                    title="Email cannot be changed"
                  />
                </div>
              </div>

              <div className="form-group-row">
                <div className="form-group">
                  <label>Mobile Number</label>
                  <input
                    type="tel"
                    value={editPhone}
                    onChange={(e) => setEditPhone(e.target.value)}
                    placeholder="e.g. 9876543210"
                  />
                </div>
                <div className="form-group">
                  <label>Preferred City</label>
                  <input
                    type="text"
                    value={editCity}
                    onChange={(e) => setEditCity(e.target.value)}
                    placeholder="e.g. Bengaluru"
                  />
                </div>
              </div>

              <div className="profile-info-grid">
                <div className="info-pill">
                  <span className="info-label">Account Type</span>
                  <span className="info-val">Shopper / Home Trial</span>
                </div>
                <div className="info-pill">
                  <span className="info-label">Delivery Zone</span>
                  <span className="info-val">2-Hour Express Active</span>
                </div>
              </div>

              <div className="profile-form-actions">
                <button className="btn-save-profile" type="submit" disabled={savingProfile}>
                  {savingProfile ? 'Saving...' : '💾 Save Profile Changes'}
                </button>
              </div>
            </form>
          ) : (
            /* ─── Addresses Tab ─── */
            <div className="addresses-tab-view">
              <div className="address-header-row">
                <h4>Saved Delivery Locations</h4>
                {!showAddAddress && (
                  <button className="btn-add-address-trigger" onClick={() => setShowAddAddress(true)}>
                    + Add New Address
                  </button>
                )}
              </div>

              {showAddAddress && (
                <form className="add-address-form" onSubmit={handleAddAddress}>
                  <h5>New Delivery Address</h5>
                  <div className="form-group">
                    <label>Address Label (e.g. Home, Office, Work)</label>
                    <input
                      type="text"
                      value={newAddrLabel}
                      onChange={(e) => setNewAddrLabel(e.target.value)}
                      placeholder="Home / Work"
                      required
                    />
                  </div>
                  <div className="form-group">
                    <label>Street Address & Landmark</label>
                    <input
                      type="text"
                      value={newAddrLine}
                      onChange={(e) => setNewAddrLine(e.target.value)}
                      placeholder="Flat 4B, 100 Feet Road, Indiranagar"
                      required
                    />
                  </div>
                  <div className="form-group-row">
                    <div className="form-group">
                      <label>City</label>
                      <input
                        type="text"
                        value={newAddrCity}
                        onChange={(e) => setNewAddrCity(e.target.value)}
                        required
                      />
                    </div>
                    <div className="form-group">
                      <label>Pincode</label>
                      <input
                        type="text"
                        value={newAddrZip}
                        onChange={(e) => setNewAddrZip(e.target.value)}
                        required
                      />
                    </div>
                  </div>
                  <div className="address-form-btns">
                    <button className="btn-cancel-addr" type="button" onClick={() => setShowAddAddress(false)}>
                      Cancel
                    </button>
                    <button className="btn-save-addr" type="submit" disabled={savingAddress}>
                      {savingAddress ? 'Saving...' : 'Save Address'}
                    </button>
                  </div>
                </form>
              )}

              <div className="address-cards-grid">
                <div className="saved-addr-card default">
                  <div className="addr-top">
                    <span className="addr-tag">🏠 Home (Default)</span>
                    <span className="express-tag">⚡ 2-Hr Express</span>
                  </div>
                  <p className="addr-text">123, 100 Feet Road, Indiranagar, Bengaluru, KA 560038</p>
                </div>

                {addresses.map((a) => (
                  <div key={a.id} className="saved-addr-card">
                    <div className="addr-top">
                      <span className="addr-tag">📍 {a.label || a.name || 'Address'}</span>
                    </div>
                    <p className="addr-text">
                      {a.address}, {a.city}, {a.state} - {a.zip}
                    </p>
                  </div>
                ))}
              </div>
            </div>
          )}
        </div>

        {/* Modal Footer with Sign Out */}
        <div className="profile-modal-footer">
          <button
            className="btn-signout-profile"
            onClick={() => {
              if (onLogout) onLogout()
              onClose()
            }}
          >
            🚪 Sign Out of Account
          </button>
        </div>
      </div>
    </div>
  )
}
