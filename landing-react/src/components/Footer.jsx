const logo = <img src="/logo.png" alt="THStyle" style={{ width: 28, height: 28, borderRadius: 8, objectFit: 'cover' }} />

export default function Footer() {
  return (
    <footer id="contact">
      <div className="footer-grid">
        <div className="footer-brand">
          <div className="footer-logo">{logo}<span>THStyle</span></div>
          <p>Fashion at high speed. Shop the latest trends from top brands near you and get delivery in minutes.</p>
        </div>
        <div className="footer-col">
          <h4>Quick Links</h4>
          <a href="#features">Features</a>
          <a href="#about">How It Works</a>
          <a href="#store">For Stores</a>
          <a href="#faq">FAQ</a>
        </div>
        <div className="footer-col">
          <h4>Support</h4>
          <a href="#">Help Center</a>
          <a href="#">Privacy Policy</a>
          <a href="#">Terms of Service</a>
        </div>
        <div className="footer-col">
          <h4>Company</h4>
          <a href="#">About Us</a>
          <a href="#">Careers</a>
          <a href="#">Contact</a>
        </div>
      </div>
      <div className="footer-bottom">
        <p>&copy; 2026 THStyle. All rights reserved.</p>
        <div className="footer-social">
          <a href="#" aria-label="Facebook">
            <svg width="14" height="14" viewBox="0 0 24 24" fill="currentColor"><path d="M18 2h-3a5 5 0 0 0-5 5v3H7v4h3v8h4v-8h3l1-4h-4V7a1 1 0 0 1 1-1h3z"/></svg>
          </a>
          <a href="#" aria-label="Twitter">
            <svg width="14" height="14" viewBox="0 0 24 24" fill="currentColor"><path d="M22 4s-.7 2.1-2 3.4c1.6 10-9.4 17.3-18 11.6 2.2.1 4.4-.6 6-2C3 15.5.5 9.6 3 5c2.2 2.6 5.6 4.1 9 4-.9-4.2 4-6.6 7-3.8 1.1 0 3-1.2 3-1.2z"/></svg>
          </a>
          <a href="#" aria-label="Instagram">
            <svg width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2.5" strokeLinecap="round" strokeLinejoin="round"><rect x="2" y="2" width="20" height="20" rx="5" ry="5"/><path d="M16 11.37A4 4 0 1 1 12.63 8 4 4 0 0 1 16 11.37z"/><line x1="17.5" y1="6.5" x2="17.51" y2="6.5"/></svg>
          </a>
        </div>
      </div>
    </footer>
  )
}
