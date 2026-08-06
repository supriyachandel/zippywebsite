import { useRef, useEffect } from 'react'
import lottie from 'lottie-web'

export default function LottieShowcase() {
  const container = useRef(null)

  useEffect(() => {
    const anim = lottie.loadAnimation({
      container: container.current,
      renderer: 'svg',
      loop: true,
      autoplay: true,
      path: '/lottie.json',
    })
    return () => anim.destroy()
  }, [])

  return (
    <section className="lottie-showcase">
      <div className="lottie-showcase-inner">
        <div className="lottie-showcase-text">
          <div className="section-label">Experience THStyle</div>
          <h2>Shop Smarter, <span className="highlight-text">Faster</span>, Better</h2>
          <p>Watch how THStyle brings the mall to your doorstep. Browse, pick, and get delivered — all in minutes.</p>
        </div>
        <div ref={container} className="lottie-showcase-anim" />
      </div>
    </section>
  )
}
