import useReveal from '../hooks/useReveal'

const items = [
  { icon: '&#128716;', bg: 'rgba(233,30,99,0.08)', color: '#e91e63', title: 'Onboarding', desc: 'Personalized gender-based experience with curated product feeds' },
  { icon: '&#128722;', bg: 'rgba(156,39,176,0.08)', color: '#9c27b0', title: 'Product Catalog', desc: 'Browse by category, with size/color variants and stock availability' },
  { icon: '&#128270;', bg: 'rgba(29,107,240,0.08)', color: '#1d6bf0', title: 'Smart Search', desc: 'Search across products, brands, categories with instant results' },
  { icon: '&#128722;', bg: 'rgba(76,175,80,0.08)', color: '#4caf50', title: 'Cart & Checkout', desc: 'Add to cart, manage quantities, and checkout with multiple payment options' },
  { icon: '&#128230;', bg: 'rgba(255,152,0,0.08)', color: '#ff9800', title: 'Order Tracking', desc: 'Real-time GPS tracking with live status updates and notifications' },
  { icon: '&#128100;', bg: 'rgba(233,30,99,0.08)', color: '#e91e63', title: 'Profile & History', desc: 'View your complete order history, manage addresses, and update profile' },
  { icon: '&#128176;', bg: 'rgba(156,39,176,0.08)', color: '#9c27b0', title: 'BHAV System', desc: 'Negotiate prices directly with store owners through our unique bargaining feature' },
  { icon: '&#128147;', bg: 'rgba(29,107,240,0.08)', color: '#1d6bf0', title: 'Wishlist', desc: 'Save favorites, get price alerts, and share your wishlist with friends' },
]

function ShowcaseItem({ item, delay }) {
  const [ref, visible] = useReveal()
  return (
    <div
      ref={ref}
      className={`showcase-item${visible ? ' visible' : ''}`}
      style={{ transitionDelay: `${delay}s` }}
    >
      <div className="icon" style={{ background: item.bg, color: item.color }} dangerouslySetInnerHTML={{ __html: item.icon }} />
      <h4 dangerouslySetInnerHTML={{ __html: item.title }} />
      <p>{item.desc}</p>
    </div>
  )
}

export default function Showcase() {
  return (
    <section className="showcase">
      <div className="section-label">App Features</div>
      <h2>What's <span className="gradient-text-2">Inside</span> the App</h2>
      <div className="showcase-grid">
        {items.map((item, i) => <ShowcaseItem key={i} item={item} delay={i * 0.05} />)}
      </div>
    </section>
  )
}
