import React from 'react'
import './HeroNew.css'

export default function HeroNew() {
  return (
    <section className="hero-new" id="home">
      <div className="hero-top-dot"></div>
      
      <div className="hero-new-container">
        {/* Left Column */}
        <div className="hero-col hero-left-new">
          <div className="hero-titles">
            <h1>thStyle</h1>
            <h2 className="hero-subtitle">fashion at high speed</h2>
          </div>
          
          <p className="hero-description">
            Browse the latest trends from<br />
            top fashion brands near you.<br />
            Order anything you love and get<br />
            it delivered in minutes.
          </p>
          
          <div className="hero-socials">
            <a href="#" aria-label="Facebook">
              <svg viewBox="0 0 24 24" fill="currentColor" width="14" height="14"><path d="M18 2h-3a5 5 0 0 0-5 5v3H7v4h3v8h4v-8h3l1-4h-4V7a1 1 0 0 1 1-1h3z"/></svg>
            </a>
            <a href="#" aria-label="WhatsApp">
              <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round" width="14" height="14"><path d="M21 11.5a8.38 8.38 0 0 1-.9 3.8 8.5 8.5 0 0 1-7.6 4.7 8.38 8.38 0 0 1-3.8-.9L3 21l1.9-5.7a8.38 8.38 0 0 1-.9-3.8 8.5 8.5 0 0 1 4.7-7.6 8.38 8.38 0 0 1 3.8-.9h.5a8.48 8.48 0 0 1 8 8v.5z"/></svg>
            </a>
            <a href="#" aria-label="YouTube">
              <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round" width="14" height="14"><path d="M22.54 6.42a2.78 2.78 0 0 0-1.94-2C18.88 4 12 4 12 4s-6.88 0-8.6.46a2.78 2.78 0 0 0-1.94 2A29 29 0 0 0 1 11.75a29 29 0 0 0 .46 5.33 2.78 2.78 0 0 0 1.94 2c1.72.46 8.6.46 8.6.46s6.88 0 8.6-.46a2.78 2.78 0 0 0 1.94-2 29 29 0 0 0 .46-5.33 29 29 0 0 0-.46-5.33z"/><polygon points="9.75 15.02 15.5 11.75 9.75 8.48 9.75 15.02"/></svg>
            </a>
            <a href="#" aria-label="Instagram">
              <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round" width="14" height="14"><rect x="2" y="2" width="20" height="20" rx="5" ry="5"/><path d="M16 11.37A4 4 0 1 1 12.63 8 4 4 0 0 1 16 11.37z"/><line x1="17.5" y1="6.5" x2="17.51" y2="6.5"/></svg>
            </a>
          </div>
        </div>

        {/* Center Column - Image */}
        <div className="hero-col hero-center-new">
          <div className="arch-image-container">
            <img src="/onboard.png" alt="THStyle Onboard" />
          </div>
        </div>

        {/* Right Column */}
        <div className="hero-col hero-right-new">
          <h3 className="hero-right-title">Start Shopping</h3>
          
          <button className="hero-btn-dark">More here</button>
          
          <div className="hero-offer">UP TO 60% OFF</div>
          
          <div className="hero-website">www.thstyle.com</div>
          
          <div className="color-palette">
            <span className="color-dot dot-black"></span>
            <span className="color-dot dot-brown"></span>
            <span className="color-dot dot-tan"></span>
          </div>
        </div>
      </div>
    </section>
  )
}
