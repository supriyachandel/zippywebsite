import useReveal from '../hooks/useReveal'

const storeFeatures = [
  { icon: '&#128202;', title: 'Inventory Management', desc: 'Add, edit, and track stock in real time. Set variants, prices, and images.' },
  { icon: '&#128230;', title: 'Order Fulfillment', desc: 'Accept, reject, and update order status. Manage processing, delivery, and returns.' },
  { icon: '&#128666;', title: 'Delivery Partners', desc: 'Manage your fleet and integrate with ShipRocket for automated shipping.' },
  { icon: '&#128200;', title: 'Analytics Dashboard', desc: 'Sales stats, order trends, revenue reports, and performance metrics.' },
  { icon: '&#128101;', title: 'Customer Management', desc: 'View customer history, preferences, and feedback to improve your service.' },
  { icon: '&#128227;', title: 'BHAV Negotiations', desc: 'Respond to customer bargaining requests and close more deals.' },
]



export default function StoreSection() {
  const [leftRef, leftVis] = useReveal()
  const [rightRef, rightVis] = useReveal()

  return (
    <section className="store-section" id="store">
      <div className="store-grid">
        <div ref={leftRef} className={`store-left${leftVis ? ' visible' : ''}`}>
          <div className="section-label">For Store Owners</div>
          <h2>Your store, your rules.</h2>
          <p className="sub">Powerful tools to manage your shop, track inventory, accept orders, and handle deliveries — all from your phone. Join 500+ partner stores already growing with THStyle.</p>
          <div className="store-features">
            {storeFeatures.map((sf, i) => (
              <div className="store-feature" key={i}>
                <div className="icon" dangerouslySetInnerHTML={{ __html: sf.icon }} />
                <div className="info"><h4>{sf.title}</h4><p>{sf.desc}</p></div>
              </div>
            ))}
          </div>
        </div>
        <div ref={rightRef} className={`store-images-container${rightVis ? ' visible' : ''}`}>
          <img src="/dashbord.png" alt="Dashboard" className="store-img-1" />
          <img src="/order.png" alt="Orders" className="store-img-2" />
        </div>
      </div>
    </section>
  )
}
