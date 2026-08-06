import useReveal from '../hooks/useReveal'

const features = [
  { icon: '&#9889;', bg: 'rgba(233,30,99,0.1)', color: '#e91e63', title: 'Lightning Delivery', desc: 'Get orders in 10-15 minutes. Our hyperlocal network of partner stores ensures speed without compromise.' },
  { icon: '&#9733;', bg: 'rgba(156,39,176,0.1)', color: '#9c27b0', title: 'Curated Collections', desc: 'Trending fashion, beauty essentials, and lifestyle products curated just for your taste and style.' },
  { icon: '&#128274;', bg: 'rgba(29,107,240,0.1)', color: '#1d6bf0', title: 'Secure Payments', desc: 'Pay via Razorpay, UPI, Credit/Debit Card, or Cash on Delivery. Your transactions are always protected.' },
  { icon: '&#128230;', bg: 'rgba(76,175,80,0.1)', color: '#4caf50', title: 'Real-Time Tracking', desc: 'Track every order from shop to doorstep with live GPS tracking and push notification updates.' },
  { icon: '&#128176;', bg: 'rgba(233,30,99,0.1)', color: '#e91e63', title: 'BHAV Bargaining', desc: 'Found a better price? Use our unique BHAV system to negotiate directly with sellers and get the best deal.' },
  { icon: '&#128722;', bg: 'rgba(156,39,176,0.1)', color: '#9c27b0', title: 'Smart Search', desc: 'Search by product, brand, category, or even upload a photo. Our smart engine finds exactly what you want.' },
  { icon: '&#128147;', bg: 'rgba(255,152,0,0.1)', color: '#ff9800', title: 'Wishlist &amp; Favorites', desc: 'Save your favorite items, get price drop alerts, and never miss out on limited-time deals.' },
  { icon: '&#128100;', bg: 'rgba(76,175,80,0.1)', color: '#4caf50', title: 'Google Sign-In', desc: 'One-tap login with your Google account. No passwords to remember — just fast, secure access.' },
]

function FeatureCard({ f, delay }) {
  const [ref, visible] = useReveal()
  return (
    <div
      ref={ref}
      className={`feature-card${visible ? ' visible' : ''}`}
      style={{ transitionDelay: `${delay}s` }}
    >
      <div className="feature-icon" style={{ background: f.bg, color: f.color }} dangerouslySetInnerHTML={{ __html: f.icon }} />
      <h3 dangerouslySetInnerHTML={{ __html: f.title }} />
      <p>{f.desc}</p>
    </div>
  )
}

export default function Features() {
  return (
    <section className="features" id="features">
      <div className="features-bg"></div>
      <div className="features-header">
        <div className="section-label">Features</div>
        <h2>Packed with powerful features</h2>
        <p className="sub">Everything you need for a seamless shopping and selling experience.</p>
      </div>
      <div className="features-grid">
        {features.map((f, i) => <FeatureCard key={i} f={f} delay={i * 0.05} />)}
      </div>
    </section>
  )
}
