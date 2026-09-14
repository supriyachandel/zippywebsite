import { useState } from 'react'

const POPULAR_LOCATIONS = [
  { city: 'Bengaluru', area: 'Indiranagar (560038)', express: true, lat: 12.9716, lng: 77.5946 },
  { city: 'Bengaluru', area: 'Koramangala (560034)', express: true, lat: 12.9352, lng: 77.6245 },
  { city: 'Bengaluru', area: 'Whitefield (560066)', express: true, lat: 12.9698, lng: 77.7500 },
  { city: 'Mumbai', area: 'Bandra West (400050)', express: true, lat: 19.0596, lng: 72.8295 },
  { city: 'Mumbai', area: 'Andheri West (400058)', express: true, lat: 19.1136, lng: 72.8697 },
  { city: 'Delhi NCR', area: 'Connaught Place (110001)', express: true, lat: 28.6304, lng: 77.2177 },
  { city: 'Delhi NCR', area: 'Cyber Hub Gurugram (122002)', express: true, lat: 28.4905, lng: 77.0898 },
  { city: 'Hyderabad', area: 'Jubilee Hills (500033)', express: true, lat: 17.4319, lng: 78.4073 }
]

export default function LocationModal({ isOpen, onClose, currentLocation, onLocationSelect }) {
  const [pincode, setPincode] = useState('')
  const [locating, setLocating] = useState(false)
  const [errorMsg, setErrorMsg] = useState('')

  if (!isOpen) return null

  const handlePincodeSubmit = (e) => {
    e.preventDefault()
    setErrorMsg('')
    const cleanPin = pincode.trim()
    if (!/^\d{6}$/.test(cleanPin)) {
      setErrorMsg('Please enter a valid 6-digit Indian pincode.')
      return
    }

    const newLoc = {
      city: cleanPin.startsWith('56') ? 'Bengaluru' : cleanPin.startsWith('40') ? 'Mumbai' : cleanPin.startsWith('11') ? 'Delhi' : 'Local Zone',
      area: `Pincode (${cleanPin})`,
      express: true,
      lat: 12.9716,
      lng: 77.5946
    }
    onLocationSelect(newLoc)
    onClose()
  }

  const handleDetectGPS = () => {
    if (!navigator.geolocation) {
      setErrorMsg('Geolocation is not supported by your browser.')
      return
    }
    setLocating(true)
    setErrorMsg('')
    navigator.geolocation.getCurrentPosition(
      (pos) => {
        setLocating(false)
        const newLoc = {
          city: 'Current Location',
          area: `GPS (${pos.coords.latitude.toFixed(2)}, ${pos.coords.longitude.toFixed(2)})`,
          express: true,
          lat: pos.coords.latitude,
          lng: pos.coords.longitude
        }
        onLocationSelect(newLoc)
        onClose()
      },
      (err) => {
        setLocating(false)
        setErrorMsg('Unable to fetch GPS position. Please pick a city from below.')
      }
    )
  }

  return (
    <div className="location-modal-overlay" onClick={onClose}>
      <div className="location-modal-card" onClick={(e) => e.stopPropagation()}>
        <div className="location-modal-header">
          <div className="loc-badge">⚡ 2-Hour Express Delivery Zones</div>
          <h3>Select Delivery Location</h3>
          <p>Choose your area to see real product stock from the nearest boutiques.</p>
          <button className="loc-close-btn" onClick={onClose}>&times;</button>
        </div>

        <div className="location-modal-body">
          {/* Current Selection */}
          <div className="current-loc-badge">
            <span className="pin-icon">📍</span>
            <div>
              <span className="current-label">Currently Selected:</span>
              <strong>{currentLocation.city}, {currentLocation.area}</strong>
            </div>
          </div>

          {/* GPS Detector */}
          <button className="btn-detect-gps" onClick={handleDetectGPS} disabled={locating}>
            <span className="gps-icon">🎯</span>
            <span>{locating ? 'Detecting your coordinates...' : 'Detect Current Location (GPS)'}</span>
          </button>

          {/* Pincode Search */}
          <form className="pincode-form" onSubmit={handlePincodeSubmit}>
            <label>Or enter 6-digit Pincode:</label>
            <div className="pincode-input-row">
              <input
                type="text"
                placeholder="e.g. 560038"
                maxLength={6}
                value={pincode}
                onChange={(e) => setPincode(e.target.value.replace(/\D/g, ''))}
              />
              <button type="submit" className="btn-apply-pin">Check Pincode</button>
            </div>
          </form>

          {errorMsg && <div className="loc-error-banner">⚠️ {errorMsg}</div>}

          {/* Popular Cities */}
          <div className="popular-cities-section">
            <label>Popular Delivery Hubs:</label>
            <div className="cities-grid">
              {POPULAR_LOCATIONS.map((loc, idx) => (
                <div
                  key={idx}
                  className={`city-tile ${currentLocation.area === loc.area ? 'active' : ''}`}
                  onClick={() => {
                    onLocationSelect(loc)
                    onClose()
                  }}
                >
                  <div className="tile-main">
                    <strong>{loc.city}</strong>
                    <span>{loc.area}</span>
                  </div>
                  {loc.express && <span className="tag-express">⚡ 2-Hr Trial</span>}
                </div>
              ))}
            </div>
          </div>
        </div>
      </div>
    </div>
  )
}
