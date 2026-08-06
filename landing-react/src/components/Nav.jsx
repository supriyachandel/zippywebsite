import { useState } from 'react'

export default function Nav() {
  const [menuOpen, setMenuOpen] = useState(false)

  const closeMenu = () => {
    setMenuOpen(false)
    document.body.style.overflow = ''
  }
  const openMenu = () => {
    setMenuOpen(true)
    document.body.style.overflow = 'hidden'
  }

  return (
    <>
      <nav className="nav">
        <a href="/" className="logo">
          <div className="logo-text">thStyle</div>
        </a>
        <div className="nav-links">
          <a href="#home">HOME</a>
          <a href="#about">ABOUT US</a>
          <a href="#store">FOR STORES</a>
          <a href="#contact">CONTACT</a>
        </div>
        <div className="nav-actions">
          <a href="#download" className="nav-download-btn">Get App</a>
        </div>
        <button className="hamburger" aria-label="Menu" onClick={openMenu}>
          <span></span><span></span><span></span>
        </button>
      </nav>

      <div className={`mobile-menu${menuOpen ? ' open' : ''}`}>
        <button className="close-btn" onClick={closeMenu}>&times;</button>
        <a href="#home" onClick={closeMenu}>HOME</a>
        <a href="#about" onClick={closeMenu}>ABOUT US</a>
        <a href="#blog" onClick={closeMenu}>BLOG</a>
        <a href="#contact" onClick={closeMenu}>CONTACT</a>
      </div>
    </>
  )
}
