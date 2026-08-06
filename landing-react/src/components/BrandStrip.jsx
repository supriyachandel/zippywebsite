import useReveal from '../hooks/useReveal'

const brands = ['ZARA', 'H&M', 'NIKE', 'PUMA', 'ADIDAS', 'LEVIS', 'TOMMY']

export default function BrandStrip() {
  const [ref, visible] = useReveal({ threshold: 0.3 })

  return (
    <section ref={ref} className={`brand-strip${visible ? ' visible' : ''}`}>
      <p>Trusted by customers &amp; stores nationwide</p>
      <div className="marquee-wrapper">
        <div className="marquee-track">
          {[...brands, ...brands, ...brands].map((b, i) => (
            <div className="marquee-item" key={i}>{b}</div>
          ))}
        </div>
      </div>
    </section>
  )
}
