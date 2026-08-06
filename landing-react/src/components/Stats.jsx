import { useEffect, useRef, useState } from 'react'
import useReveal from '../hooks/useReveal'

function animateCounter(el, target, suffix = '', isRating = false) {
  let current = 0
  const step = Math.max(1, Math.floor(target / 60))
  const timer = setInterval(() => {
    current += step
    if (current >= target) { current = target; clearInterval(timer) }
    el.textContent = isRating ? (current / 10).toFixed(1) : current.toLocaleString() + suffix
  }, 25)
}

const stats = [
  { id: 'statCustomers', target: 10500, suffix: '+', color: '#e91e63', label: 'Happy Customers' },
  { id: 'statStores', target: 528, suffix: '+', color: '#4a6cf7', label: 'Partner Stores' },
  { id: 'statDelivery', target: 14, suffix: '', color: '#1a1a4e', label: 'Avg. Delivery (min)' },
  { id: 'statRating', target: 48, suffix: '', color: '#e91e63', label: 'App Rating', rating: true },
]

function StatCard({ s, delay }) {
  const [ref, visible] = useReveal({ threshold: 0.3 })
  const countRef = useRef(null)
  const [triggered, setTriggered] = useState(false)

  useEffect(() => {
    if (!visible || triggered) return
    setTriggered(true)
    const el = countRef.current
    if (el) animateCounter(el, s.target, s.suffix, !!s.rating)
  }, [visible, triggered, s])

  return (
    <div
      ref={ref}
      className={`stat-item${visible ? ' visible' : ''}`}
      style={{ transitionDelay: `${delay}s` }}
    >
      <h3 ref={countRef} id={s.id} style={{ color: s.color }}>0</h3>
      <p>{s.label}</p>
    </div>
  )
}

export default function Stats() {
  return (
    <section className="stats">
      <div className="stats-grid">
        {stats.map((s, i) => (
          <StatCard key={s.id} s={s} delay={i * 0.1} />
        ))}
      </div>
    </section>
  )
}
