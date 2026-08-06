import { useState } from 'react'
import useReveal from '../hooks/useReveal'

const faqs = [
  { q: 'What is THStyle?', a: 'THStyle is a hyperlocal fashion and lifestyle delivery app that connects you with nearby stores. Browse, order, and get your favorite products delivered to your doorstep in 10-15 minutes.' },
  { q: 'How does the delivery work?', a: 'We partner with local stores in your area. When you place an order, a delivery partner picks it up and delivers it directly to you. You can track the entire journey in real-time through the app.' },
  { q: 'What is the BHAV bargaining system?', a: 'BHAV (Bargain, Haggle, And Value) is our unique feature that lets you negotiate prices directly with store owners. Found a better price elsewhere? Send a counter-offer and the store can accept, decline, or make a counter-proposal.' },
  { q: 'What payment methods do you accept?', a: 'We accept Razorpay (credit/debit cards, UPI, net banking), Google Pay, PhonePe, Paytm, and Cash on Delivery. All online payments are fully encrypted and secure.' },
  { q: 'Can I sell on THStyle?', a: 'Absolutely! Download the THStyle Store app from the Play Store, register your shop, add your products, and start receiving orders. You get a powerful dashboard to manage inventory, orders, deliveries, and analytics.' },
  { q: 'Is there a minimum order value?', a: 'Minimum order values vary by store. Most stores have a minimum order of ₹99. Delivery is free on orders above ₹299.' },
  { q: 'How do I track my order?', a: 'Once your order is confirmed, you\'ll see a live tracking map in the app showing your delivery partner\'s location in real-time. You\'ll also receive push notifications at every step.' },
  { q: 'What is your return policy?', a: 'We offer a 7-day easy return policy on most products. Simply go to your order history, request a return, and our delivery partner will pick up the item. Refunds are processed within 3-5 business days.' },
]

function FAQItem({ item, index, openIndex, toggle }) {
  const [ref, visible] = useReveal()
  const isOpen = openIndex === index
  return (
    <div
      ref={ref}
      className={`faq-item${visible ? ' visible' : ''}${isOpen ? ' open' : ''}`}
      style={{ transitionDelay: `${index * 0.05}s` }}
    >
      <button className="faq-question" onClick={() => toggle(index)}>
        {item.q}
        <span className="icon">&#9660;</span>
      </button>
      <div className="faq-answer" style={{ display: isOpen ? 'block' : 'none' }}>{item.a}</div>
    </div>
  )
}

export default function FAQ() {
  const [openIndex, setOpenIndex] = useState(null)
  const toggle = (i) => setOpenIndex(openIndex === i ? null : i)

  return (
    <section className="faq" id="faq">
      <h2>Frequently Asked <span className="gradient-text-2">Questions</span></h2>
      <p className="sub">Got questions? We've got answers.</p>
      {faqs.map((item, i) => (
        <FAQItem key={i} item={item} index={i} openIndex={openIndex} toggle={toggle} />
      ))}
    </section>
  )
}
