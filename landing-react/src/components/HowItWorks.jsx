import useReveal from '../hooks/useReveal'

const steps = [
  { num: '1', color: '#e91e63', title: 'Browse &amp; Discover', desc: 'Explore curated collections, search by style, or browse categories. Find exactly what you need.' },
  { num: '2', color: '#9c27b0', title: 'Order &amp; Pay', desc: 'Add to cart, choose your address, and pay securely via UPI, Card, COD, or Razorpay.' },
  { num: '3', color: '#1d6bf0', title: 'Track &amp; Receive', desc: 'Track your order in real-time. Get notified when it\'s out for delivery and receive it in minutes.' },
]

function StepCard({ step, delay }) {
  const [ref, visible] = useReveal()
  return (
    <div
      ref={ref}
      className={`step${visible ? ' visible' : ''}`}
      style={{ transitionDelay: `${delay}s` }}
    >
      <div className="number" style={{ background: `${step.color}1a`, color: step.color }}>{step.num}</div>
      <div>
        <h3 dangerouslySetInnerHTML={{ __html: step.title }} />
        <p>{step.desc}</p>
      </div>
    </div>
  )
}

export default function HowItWorks() {
  return (
    <section className="how" id="about">
      <h2>How It <span>Works</span></h2>
      <p className="sub">Three simple steps to get your favorite fashion at your doorstep.</p>
      <div className="steps">
        {steps.map((s, i) => <StepCard key={i} step={s} delay={i * 0.1} />)}
      </div>
    </section>
  )
}
