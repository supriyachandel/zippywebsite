import { useRef, useEffect } from 'react'
import useReveal from '../hooks/useReveal'
import './Screenshots.css'

const screenshots = [
  { id: 1, src: '/screenshot-home.png', alt: 'Home Dashboard' },
  { id: 2, src: '/screenshot-fashion.png', alt: 'Fashion Hub' },
  { id: 3, src: '/screenshot-categories.png', alt: 'Categories Sidebar' },
  { id: 4, src: '/screenshot-orders.png', alt: 'My Orders' },
  { id: 5, src: '/screenshot-product.png', alt: 'Product Detail' },
]

export default function Screenshots() {
  const [ref, visible] = useReveal()
  const scrollRef = useRef(null)

  const scroll = (direction) => {
    if (scrollRef.current) {
      const scrollAmount = 350
      scrollRef.current.scrollBy({ left: direction === 'left' ? -scrollAmount : scrollAmount, behavior: 'smooth' })
    }
  }

  useEffect(() => {
    const interval = setInterval(() => {
      if (scrollRef.current) {
        if (scrollRef.current.scrollLeft + scrollRef.current.clientWidth >= scrollRef.current.scrollWidth - 10) {
          scrollRef.current.scrollTo({ left: 0, behavior: 'smooth' })
        } else {
          scroll('right')
        }
      }
    }, 3000)
    return () => clearInterval(interval)
  }, [])

  return (
    <section className="screenshots-section" ref={ref}>
      <div className="section-label">App Preview</div>
      <h2>Experience the <span className="gradient-text-2">THStyle App</span></h2>
      <p className="screenshots-subtitle">A stunning, fast, and intuitive interface designed for your fashion needs.</p>

      <div className="screenshots-container">
        <button className="scroll-btn left" onClick={() => scroll('left')} aria-label="Scroll left">
          &#10094;
        </button>

        <div className="screenshots-track" ref={scrollRef}>
          {screenshots.map((screen, i) => (
            <div
              key={screen.id}
              className={`screenshot-wrapper${visible ? ' visible' : ''}`}
              style={{ transitionDelay: `${i * 0.1}s` }}
            >
              <div className="phone-frame">
                <div className="phone-notch"></div>
                <img src={screen.src} alt={screen.alt} className="screenshot-img" onError={(e) => {
                  e.target.style.display = 'none';
                  e.target.parentElement.classList.add('missing-img');
                  e.target.parentElement.innerHTML += '<div class=\"missing-text\">Please save<br/>' + screen.src.substring(1) + '<br/>to public/</div>';
                }} />
              </div>
            </div>
          ))}
        </div>

        <button className="scroll-btn right" onClick={() => scroll('right')} aria-label="Scroll right">
          &#10095;
        </button>
      </div>
    </section>
  )
}
