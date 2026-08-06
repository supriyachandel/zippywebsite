import { useRef, useEffect, useState } from 'react'
import lottie from 'lottie-web'

function GeoDecorations() {
  return (
    <>
      <div className="geo-dot geo-dot-1" />
      <div className="geo-dot geo-dot-2" />
      <div className="geo-dot geo-dot-3" />
      <div className="geo-circle geo-circle-1" />
      <div className="geo-circle geo-circle-2" />
      <div className="geo-ring geo-ring-1" />
      <div className="geo-ring geo-ring-2" />
      <div className="geo-zigzag geo-zigzag-1">
        <svg width="80" height="24" viewBox="0 0 80 24" fill="none">
          <path d="M0 12 L12 4 L24 20 L36 4 L48 20 L60 4 L72 20 L80 12" stroke="#1a1a4e" strokeWidth="1.5" strokeLinecap="round" strokeLinejoin="round"/>
        </svg>
      </div>
      <div className="geo-zigzag geo-zigzag-2">
        <svg width="60" height="20" viewBox="0 0 60 20" fill="none">
          <path d="M0 10 L10 2 L20 18 L30 2 L40 18 L50 2 L60 10" stroke="#1a1a4e" strokeWidth="1.5" strokeLinecap="round" strokeLinejoin="round"/>
        </svg>
      </div>
    </>
  )
}

export default function Hero() {
  const animContainer = useRef(null)
  const [displayText, setDisplayText] = useState('')
  const fullText = 'Trend'
  const [showCursor, setShowCursor] = useState(true)

  useEffect(() => {
    const anim = lottie.loadAnimation({
      container: animContainer.current,
      renderer: 'svg',
      loop: true,
      autoplay: true,
      path: '/lottie.json',
    })
    return () => anim.destroy()
  }, [])

  useEffect(() => {
    let i = 0
    const timer = setInterval(() => {
      if (i <= fullText.length) {
        setDisplayText(fullText.slice(0, i))
        i++
      } else {
        clearInterval(timer)
      }
    }, 100)
    return () => clearInterval(timer)
  }, [])

  useEffect(() => {
    const cursor = setInterval(() => setShowCursor(c => !c), 530)
    return () => clearInterval(cursor)
  }, [])

  return (
    <section className="hero">
      <div className="hero-left">
        <div className="hero-label" style={{ fontSize: '18px', color: '#1a1a4e', letterSpacing: '1px' }}>THStyle App</div>
        <h1>
          <span className="hero-fashion" style={{ color: '#4a6cf7' }}>Style</span><br />
          <span className="hero-trend" style={{ color: '#1a1a4e' }}>
            {displayText}<span className="dot" style={{ background: '#e91e63' }}></span><span className={`typing-cursor${showCursor ? ' blink' : ''}`}></span>
          </span>
        </h1>
        <p className="hero-desc" style={{ maxWidth: '400px', fontSize: '14px', lineHeight: '1.6' }}>
          Browse the latest trends from top fashion brands near you.<br />
          Order anything you love and get it delivered in minutes.<br />
          Fast, fresh, and always in style with THStyle.
        </p>
        <div className="hero-buttons">
          <a href="#signup" className="download-btn android" style={{ borderRadius: '24px', padding: '12px 32px', fontSize: '14px', fontWeight: 'bold', letterSpacing: '2px' }}>
            SIGN UP
          </a>
        </div>
        <div className="hero-social">
          <div className="hero-social-label">FOLLOW US</div>
          <div className="hero-social-icons">
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
      </div>
      <div className="hero-right">
        <GeoDecorations />
        <div className="hero-illustration">
          <div ref={animContainer} className="lottie-wrap" />
        </div>
      </div>
    </section>
  )
}
