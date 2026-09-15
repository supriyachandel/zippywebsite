import { useState, useEffect } from 'react'
import { submitToHubSpot, HUBSPOT_PORTAL_ID } from '../services/hubspotService'
import './ContactSection.css'

export default function ContactSection({ currentUser }) {
  const [formData, setFormData] = useState({
    name: '',
    email: '',
    phone: '',
    inquiryType: 'Customer Support',
    subject: '',
    message: ''
  })
  const [isSubmitting, setIsSubmitting] = useState(false)
  const [submitted, setSubmitted] = useState(false)
  const [errorMsg, setErrorMsg] = useState('')

  // Prefill user details if logged in
  useEffect(() => {
    if (currentUser) {
      setFormData(prev => ({
        ...prev,
        name: currentUser.name || prev.name,
        email: currentUser.email || prev.email,
        phone: currentUser.phone || prev.phone
      }))
    }
  }, [currentUser])

  const handleChange = (e) => {
    const { name, value } = e.target
    setFormData(prev => ({ ...prev, [name]: value }))
  }

  const handleSubmit = async (e) => {
    e.preventDefault()
    setErrorMsg('')

    if (!formData.name.trim() || !formData.email.trim() || !formData.message.trim()) {
      setErrorMsg('Please fill in your name, email, and message.')
      return
    }

    // Email format validation
    const emailRegex = /^[^\s@]+@[^\s@]+\.[^\s@]+$/
    if (!emailRegex.test(formData.email.trim())) {
      setErrorMsg('Please enter a valid email address.')
      return
    }

    setIsSubmitting(true)

    try {
      await submitToHubSpot({
        name: formData.name,
        email: formData.email,
        phone: formData.phone,
        inquiryType: formData.inquiryType,
        subject: formData.subject || `${formData.inquiryType} from ${formData.name}`,
        message: formData.message
      })

      setSubmitted(true)
      setIsSubmitting(false)
    } catch (err) {
      console.error('Submission error:', err)
      setErrorMsg('There was an issue sending your message. Please try again.')
      setIsSubmitting(false)
    }
  }

  const handleReset = () => {
    setSubmitted(false)
    setFormData({
      name: currentUser?.name || '',
      email: currentUser?.email || '',
      phone: currentUser?.phone || '',
      inquiryType: 'Customer Support',
      subject: '',
      message: ''
    })
  }

  return (
    <section className="contact-section" id="contact">
      <div className="contact-container">
        {/* Section Header */}
        <div className="contact-header">
          <span className="section-label">HubSpot Verified Support</span>
          <h2>Let's Start a <span>Conversation</span></h2>
          <p className="sub">
            Have questions about 2-hour home trials, store onboarding, or orders?
            Send us a message and our team will connect with you via HubSpot CRM in minutes.
          </p>
        </div>

        <div className="contact-grid">
          {/* Left Column: Direct Info & HubSpot Chat Hub */}
          <div className="contact-info-card">
            <div className="info-badge">
              <span className="live-dot"></span> 24/7 Priority Desk
            </div>
            <h3>Fast, Direct Support</h3>
            <p className="info-desc">
              Whether you are shopping the latest boutique collections or want to list your store on ZippyStyle, we're here to help.
            </p>

            <div className="contact-channels">
              <div className="channel-item">
                <div className="channel-icon">⚡</div>
                <div className="channel-details">
                  <h4>Express Order Help</h4>
                  <p>2-hour trial deliveries, size exchanges & returns</p>
                  <a href="mailto:support@zippystyle.com">support@zippystyle.com</a>
                </div>
              </div>

              <div className="channel-item">
                <div className="channel-icon">🏬</div>
                <div className="channel-details">
                  <h4>Store Partnerships</h4>
                  <p>List your local boutique on ZippyStyle</p>
                  <a href="mailto:partners@zippystyle.com">partners@zippystyle.com</a>
                </div>
              </div>

              <div className="channel-item">
                <div className="channel-icon">📍</div>
                <div className="channel-details">
                  <h4>Headquarters</h4>
                  <p>Mohali, Punjab</p>
                </div>
              </div>
            </div>


          </div>

          {/* Right Column: Contact Us Form */}
          <div className="contact-form-wrapper">
            {submitted ? (
              <div className="contact-success-state">
                <div className="success-icon-wrap">
                  <div className="success-icon">✓</div>
                </div>
                <h3>Message Sent Successfully!</h3>
                <p>
                  Thank you, <strong>{formData.name}</strong>. Your message has been saved to our <strong>HubSpot CRM</strong> portal.
                  Our team is reviewing your request and will respond to <strong>{formData.email}</strong> shortly.
                </p>
                <div className="success-actions">
                  <button type="button" className="btn-secondary" onClick={handleReset}>
                    Send Another Message
                  </button>
                </div>
              </div>
            ) : (
              <form
                className="contact-form"
                onSubmit={handleSubmit}
                id="zippy-hubspot-contact-form"
                data-hs-cf-bound="true"
              >
                <div className="form-heading">
                  <h3>Send a Direct Message</h3>
                  <p>Fill out the form below. Leads & tickets sync to HubSpot automatically.</p>
                </div>

                {errorMsg && <div className="form-error-banner">{errorMsg}</div>}

                {/* Inquiry Type Tabs */}
                <div className="form-group">
                  <label>I am contacting regarding</label>
                  <div className="inquiry-pills">
                    {[
                      'Customer Support',
                      'Store Partnership',
                      'Order & Returns',
                      'General Question'
                    ].map((type) => (
                      <button
                        key={type}
                        type="button"
                        className={`inquiry-pill ${formData.inquiryType === type ? 'active' : ''}`}
                        onClick={() => setFormData(prev => ({ ...prev, inquiryType: type }))}
                      >
                        {type}
                      </button>
                    ))}
                  </div>
                </div>

                <div className="form-row">
                  <div className="form-group">
                    <label htmlFor="hs-name">Your Full Name <span className="req">*</span></label>
                    <input
                      id="hs-name"
                      type="text"
                      name="name"
                      placeholder="e.g. Tanya Sharma"
                      value={formData.name}
                      onChange={handleChange}
                      required
                      autoComplete="name"
                    />
                  </div>

                  <div className="form-group">
                    <label htmlFor="hs-email">Email Address <span className="req">*</span></label>
                    <input
                      id="hs-email"
                      type="email"
                      name="email"
                      placeholder="tanya@example.com"
                      value={formData.email}
                      onChange={handleChange}
                      required
                      autoComplete="email"
                    />
                  </div>
                </div>

                <div className="form-row">
                  <div className="form-group">
                    <label htmlFor="hs-phone">Phone Number (Optional)</label>
                    <input
                      id="hs-phone"
                      type="tel"
                      name="phone"
                      placeholder="+91 98765 43210"
                      value={formData.phone}
                      onChange={handleChange}
                      autoComplete="tel"
                    />
                  </div>

                  <div className="form-group">
                    <label htmlFor="hs-subject">Subject</label>
                    <input
                      id="hs-subject"
                      type="text"
                      name="subject"
                      placeholder="e.g. 2-Hour Trial Inquiry"
                      value={formData.subject}
                      onChange={handleChange}
                    />
                  </div>
                </div>

                <div className="form-group">
                  <label htmlFor="hs-message">Your Message <span className="req">*</span></label>
                  <textarea
                    id="hs-message"
                    name="message"
                    rows="4"
                    placeholder="Tell us what you need help with or details about your boutique..."
                    value={formData.message}
                    onChange={handleChange}
                    required
                  ></textarea>
                </div>

                <div className="form-consent">
                  <small>
                    🔒 Your information is securely transmitted and saved into our HubSpot CRM system in accordance with our Privacy Policy.
                  </small>
                </div>

                <button
                  type="submit"
                  className="contact-submit-btn"
                  disabled={isSubmitting}
                >
                  {isSubmitting ? (
                    <span className="btn-loading">
                      <span className="spinner"></span> Syncing to HubSpot...
                    </span>
                  ) : (
                    <span>Send Message &rarr;</span>
                  )}
                </button>
              </form>
            )}
          </div>
        </div>
      </div>
    </section>
  )
}
