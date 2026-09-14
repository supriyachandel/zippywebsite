import { useState, useEffect } from 'react'
import Nav from './components/Nav'
import HeroNew from './components/HeroNew'
import BrandStrip from './components/BrandStrip'
import HowItWorks from './components/HowItWorks'
import Features from './components/Features'
import Showcase from './components/Showcase'
import StoreSection from './components/StoreSection'
import Testimonials from './components/Testimonials'
import Stats from './components/Stats'
import FAQ from './components/FAQ'
import CTA from './components/CTA'
import Footer from './components/Footer'
import LottieShowcase from './components/LottieShowcase'
import Screenshots from './components/Screenshots'

import ShopPage from './components/ShopPage'
import CartDrawer from './components/CartDrawer'
import AuthModal from './components/AuthModal'
import ProfileModal from './components/ProfileModal'
import { getLoggedInUser, logoutUser } from './services/apiService'

import './App.css'
import './components/Shop.css'

export default function App() {
  const [activeTab, setActiveTab] = useState('home')
  const [cartOpen, setCartOpen] = useState(false)
  const [cartItems, setCartItems] = useState([])
  const [currentUser, setCurrentUser] = useState(null)
  const [globalAuthModalOpen, setGlobalAuthModalOpen] = useState(false)
  const [profileModalOpen, setProfileModalOpen] = useState(false)

  // Listen to hash changes (#shop or #home) & auth state
  useEffect(() => {
    const handleHash = () => {
      if (window.location.hash === '#shop') {
        setActiveTab('shop')
      } else if (window.location.hash === '#home' || window.location.hash === '') {
        setActiveTab('home')
      }
    }
    handleHash()
    window.addEventListener('hashchange', handleHash)
    setCurrentUser(getLoggedInUser())
    return () => window.removeEventListener('hashchange', handleHash)
  }, [])

  const handleTabSwitch = (tab) => {
    setActiveTab(tab)
    window.location.hash = tab
    window.scrollTo({ top: 0, behavior: 'smooth' })
  }

  const handleAddToCart = (newItem) => {
    setCartItems((prevItems) => {
      const existingIndex = prevItems.findIndex((item) => item.cartId === newItem.cartId)
      if (existingIndex > -1) {
        const updated = [...prevItems]
        updated[existingIndex].quantity += 1
        return updated
      }
      return [...prevItems, { ...newItem, quantity: 1 }]
    })
    setCartOpen(true)
  }

  const handleUpdateQuantity = (cartId, newQty) => {
    if (newQty <= 0) {
      handleRemoveItem(cartId)
      return
    }
    setCartItems((prevItems) =>
      prevItems.map((item) => (item.cartId === cartId ? { ...item, quantity: newQty } : item))
    )
  }

  const handleRemoveItem = (cartId) => {
    setCartItems((prevItems) => prevItems.filter((item) => item.cartId !== cartId))
  }

  const handleClearCart = () => {
    setCartItems([])
  }

  const handleLogout = () => {
    logoutUser()
    setCurrentUser(null)
  }

  const totalCartCount = cartItems.reduce((acc, item) => acc + item.quantity, 0)

  return (
    <>
      <Nav
        activeTab={activeTab}
        setActiveTab={handleTabSwitch}
        cartCount={totalCartCount}
        onOpenCart={() => setCartOpen(true)}
        currentUser={currentUser}
        onLogout={handleLogout}
        onOpenAuth={() => setGlobalAuthModalOpen(true)}
        onOpenProfile={() => setProfileModalOpen(true)}
      />

      <CartDrawer
        isOpen={cartOpen}
        onClose={() => setCartOpen(false)}
        cartItems={cartItems}
        onUpdateQuantity={handleUpdateQuantity}
        onRemoveItem={handleRemoveItem}
        onClearCart={handleClearCart}
      />

      <AuthModal
        isOpen={globalAuthModalOpen}
        onClose={() => setGlobalAuthModalOpen(false)}
        onSuccess={(user) => {
          setCurrentUser(user)
          setGlobalAuthModalOpen(false)
        }}
      />

      <ProfileModal
        isOpen={profileModalOpen}
        onClose={() => setProfileModalOpen(false)}
        currentUser={currentUser}
        onLogout={handleLogout}
        onProfileUpdated={(updated) => setCurrentUser(updated)}
      />

      {activeTab === 'shop' ? (
        <ShopPage
          onAddToCart={handleAddToCart}
          onOpenCart={() => setCartOpen(true)}
          cartCount={totalCartCount}
          currentUser={currentUser}
          onOpenAuth={() => setGlobalAuthModalOpen(true)}
          onUserAuthSuccess={(user) => setCurrentUser(user)}
        />
      ) : (
        <>
          <HeroNew />
          <Screenshots />
          <LottieShowcase />
          <BrandStrip />
          <HowItWorks />
          <Features />
          <Showcase />
          <StoreSection />
          <Testimonials />
          <Stats />
          <FAQ />
          <CTA />
        </>
      )}

      <Footer />
    </>
  )
}
