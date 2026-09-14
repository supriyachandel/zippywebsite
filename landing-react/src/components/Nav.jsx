import { useState } from 'react'

export default function Nav({ activeTab = 'home', setActiveTab, cartCount = 0, onOpenCart, currentUser, onLogout, onOpenAuth, onOpenProfile }) {
  const [menuOpen, setMenuOpen] = useState(false)

  const closeMenu = () => {
    setMenuOpen(false)
    document.body.style.overflow = ''
  }
  const openMenu = () => {
    setMenuOpen(true)
    document.body.style.overflow = 'hidden'
  }

  const handleNavClick = (tabName, e) => {
    if (e) e.preventDefault()
    if (setActiveTab) setActiveTab(tabName)
    closeMenu()
  }

  return (
    <header className="pro-header-wrapper">
      {/* ─── Top Announcement Ticker Bar ─── */}
      <div className="top-announcement-bar">
        <div className="announcement-content">
          <span className="sparkle">⚡</span>
          <span>EXPRESS 2-HOUR HOME TRIAL • TRY CLOTHES AT HOME BEFORE BUYING • FREE RETURNS</span>
          <span className="sparkle">⚡</span>
        </div>
      </div>

      {/* ─── Primary Pro Navigation ─── */}
      <nav className="nav pro-nav">
        <a href="#home" className="logo" onClick={(e) => handleNavClick('home', e)}>
          <div className="logo-text">
            <span className="logo-bolt">⚡</span>ZippyStyle
          </div>
        </a>

        <div className="nav-links">
          <a
            href="#home"
            className={activeTab === 'home' ? 'active' : ''}
            onClick={(e) => handleNavClick('home', e)}
          >
            HOME
          </a>
          <a
            href="#shop"
            className={`shop-nav-link ${activeTab === 'shop' ? 'active' : ''}`}
            onClick={(e) => handleNavClick('shop', e)}
          >
            SHOP <span className="nav-badge-pill">NEW</span>
          </a>
          <a href="#about" onClick={(e) => { handleNavClick('home', e); setTimeout(() => document.getElementById('about')?.scrollIntoView(), 100); }}>ABOUT US</a>
          <a href="#store" onClick={(e) => { handleNavClick('home', e); setTimeout(() => document.getElementById('store')?.scrollIntoView(), 100); }}>FOR STORES</a>
          <a href="#contact" onClick={(e) => { handleNavClick('home', e); setTimeout(() => document.getElementById('contact')?.scrollIntoView(), 100); }}>CONTACT</a>
        </div>

        <div className="nav-actions">
          {/* User Profile / Auth State */}
          {currentUser ? (
            <div className="user-profile-badge" onClick={onOpenProfile} title="View Profile & Orders">
              <span className="user-avatar">👤</span>
              <span className="user-name">{currentUser.name || currentUser.email.split('@')[0]}</span>
              <button 
                className="user-logout-btn" 
                onClick={(e) => { e.stopPropagation(); onLogout(); }} 
                title="Sign Out"
              >
                &times;
              </button>
            </div>
          ) : (
            <button className="pro-auth-btn" onClick={onOpenAuth}>
              Sign In
            </button>
          )}

          {/* Cart Icon Trigger */}
          <button className="nav-cart-btn pro-cart-btn" onClick={onOpenCart} title="Open Shopping Bag">
            <span className="cart-icon">🛍️</span>
            <span className="cart-text">Bag</span>
            {cartCount > 0 && <span className="cart-badge">{cartCount}</span>}
          </button>

          <a href="#download" className="nav-download-btn">Get App</a>
        </div>

        <button className="hamburger" aria-label="Menu" onClick={openMenu}>
          <span></span><span></span><span></span>
        </button>
      </nav>

      {/* ─── Mobile Navigation Drawer ─── */}
      <div className={`mobile-menu${menuOpen ? ' open' : ''}`}>
        <button className="close-btn" onClick={closeMenu}>&times;</button>
        <a href="#home" onClick={(e) => handleNavClick('home', e)}>HOME</a>
        <a href="#shop" className="mobile-shop-link" onClick={(e) => handleNavClick('shop', e)}>
          SHOP STORE 🛍️ <span className="nav-badge-pill">LIVE</span>
        </a>
        {currentUser && (
          <a href="#profile" onClick={(e) => { e.preventDefault(); onOpenProfile(); closeMenu(); }}>
            MY ORDERS & PROFILE 👤
          </a>
        )}
        <a href="#about" onClick={closeMenu}>ABOUT US</a>
        <a href="#store" onClick={closeMenu}>FOR STORES</a>
        <a href="#contact" onClick={closeMenu}>CONTACT</a>
      </div>
    </header>
  )
}
