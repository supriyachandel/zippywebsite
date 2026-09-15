
export default function Footer({ onNavigate }) {
  const handleLinkClick = (hash, e) => {
    if (onNavigate) {
      onNavigate('home')
    }
    setTimeout(() => {
      const id = hash.replace('#', '')
      const el = document.getElementById(id)
      if (el) el.scrollIntoView({ behavior: 'smooth' })
    }, 100)
  }

  return (
    <footer className="footer-site">
      <div className="footer-grid">
        <div className="footer-brand">
          <div className="footer-logo">
            <span style={{ fontSize: 24 }}>⚡</span>
            <span>ZippyStyle</span>
          </div>
          <p>Fashion at high speed. Experience express 2-hour home trial delivery from the best local boutiques & top brands near you.</p>
        </div>
        <div className="footer-col">
          <h4>Explore</h4>
          <a href="#shop" onClick={(e) => { e.preventDefault(); if (onNavigate) onNavigate('shop'); }}>Shop Collection</a>
          <a href="#features" onClick={(e) => handleLinkClick('#features', e)}>Express Features</a>
          <a href="#about" onClick={(e) => handleLinkClick('#about', e)}>How It Works</a>
          <a href="#store" onClick={(e) => handleLinkClick('#store', e)}>For Store Owners</a>
          <a href="#faq" onClick={(e) => handleLinkClick('#faq', e)}>FAQ</a>
        </div>
        <div className="footer-col">
          <h4>Support & Help</h4>
          <a href="#contact" onClick={(e) => handleLinkClick('#contact', e)}>Contact Us</a>
          <a href="#faq" onClick={(e) => handleLinkClick('#faq', e)}>Returns & Trial Policy</a>
          <a href="#contact" onClick={(e) => handleLinkClick('#contact', e)}>Partner Inquiries</a>
        </div>
        <div className="footer-col">
          <h4>Company</h4>
          <a href="#about" onClick={(e) => handleLinkClick('#about', e)}>About Us</a>
          <a href="#contact" onClick={(e) => handleLinkClick('#contact', e)}>Careers & Hiring</a>
          <a href="#contact" onClick={(e) => handleLinkClick('#contact', e)}>Get in Touch</a>
        </div>
      </div>
      <div className="footer-bottom">
        <p>&copy; {new Date().getFullYear()} ZippyStyle Inc. All rights reserved. • Powered by HubSpot CRM Integration</p>
        <div className="footer-social">
          <a href="#contact" aria-label="Facebook" onClick={(e) => handleLinkClick('#contact', e)}>
            <svg width="14" height="14" viewBox="0 0 24 24" fill="currentColor"><path d="M18 2h-3a5 5 0 0 0-5 5v3H7v4h3v8h4v-8h3l1-4h-4V7a1 1 0 0 1 1-1h3z"/></svg>
          </a>
          <a href="#contact" aria-label="Twitter" onClick={(e) => handleLinkClick('#contact', e)}>
            <svg width="14" height="14" viewBox="0 0 24 24" fill="currentColor"><path d="M22 4s-.7 2.1-2 3.4c1.6 10-9.4 17.3-18 11.6 2.2.1 4.4-.6 6-2C3 15.5.5 9.6 3 5c2.2 2.6 5.6 4.1 9 4-.9-4.2 4-6.6 7-3.8 1.1 0 3-1.2 3-1.2z"/></svg>
          </a>
          <a href="#contact" aria-label="Instagram" onClick={(e) => handleLinkClick('#contact', e)}>
            <svg width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2.5" strokeLinecap="round" strokeLinejoin="round"><rect x="2" y="2" width="20" height="20" rx="5" ry="5"/><path d="M16 11.37A4 4 0 1 1 12.63 8 4 4 0 0 1 16 11.37z"/><line x1="17.5" y1="6.5" x2="17.51" y2="6.5"/></svg>
          </a>
        </div>
      </div>
    </footer>
  )
}
