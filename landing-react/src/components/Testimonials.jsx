import useReveal from '../hooks/useReveal'

const testimonials = [
  { stars: 5, text: 'Amazing app! I ordered a dress and it arrived in just 12 minutes. The quality was perfect. Love the BHAV feature too — saved ₹200 on my sneakers!', initial: 'A', name: 'Ananya Sharma', role: 'Fashion Enthusiast' },
  { stars: 5, text: 'As a store owner, the dashboard is a game changer. Managing inventory and tracking orders has never been this easy. My revenue doubled in 3 months.', initial: 'R', name: 'Rahul Verma', role: 'Store Partner' },
  { stars: 4, text: 'Love the Google Sign-In — no more forgotten passwords. The real-time tracking is super accurate. Highly recommended for anyone who loves fashion!', initial: 'P', name: 'Priya Kaur', role: 'Regular Customer' },
]

function TestimonialCard({ t, delay }) {
  const [ref, visible] = useReveal()
  return (
    <div
      ref={ref}
      className={`testimonial-card${visible ? ' visible' : ''}`}
      style={{ transitionDelay: `${delay}s` }}
    >
      <div className="stars">{'★'.repeat(t.stars)}{'☆'.repeat(5 - t.stars)}</div>
      <div className="text">{t.text}</div>
      <div className="author">
        <div className="avatar">{t.initial}</div>
        <div className="info"><div className="name">{t.name}</div><div className="role">{t.role}</div></div>
      </div>
    </div>
  )
}

export default function Testimonials() {
  return (
    <section className="testimonials" id="testimonials">
      <div className="section-label">Testimonials</div>
      <h2>What our <span className="gradient-text-2">users</span> say</h2>
      <div className="testimonials-grid">
        {testimonials.map((t, i) => <TestimonialCard key={i} t={t} delay={i * 0.1} />)}
      </div>
    </section>
  )
}
