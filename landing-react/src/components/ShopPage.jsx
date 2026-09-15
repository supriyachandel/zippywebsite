import { useState, useEffect, useMemo } from 'react'
import { fetchProducts, fetchCategories, fetchShops, getLoggedInUser, logoutUser, getFallbackProductImage } from '../services/apiService'
import ProductDetailModal from './ProductDetailModal'
import AuthModal from './AuthModal'
import LocationModal from './LocationModal'

const BANNERS = [
  {
    image: "https://images.unsplash.com/photo-1441986300917-64674bd600d8?w=1200&h=500&fit=crop&q=80",
    tag: "LUXURY FASHION COLLECTION",
    title: "Try Clothes at Home Before You Buy",
    subtitle: "Select 3 sizes delivered to your door in 2 Hours. Pay ₹0 upfront."
  },
  {
    image: "https://images.unsplash.com/photo-1490481651871-ab68de25d43d?w=1200&h=500&fit=crop&q=80",
    tag: "VERIFIED LOCAL BOUTIQUES",
    title: "Trending Styles from Top City Stores",
    subtitle: "Real inventory, direct store prices, and instant 15-minute dispatch."
  },
  {
    image: "https://images.unsplash.com/photo-1445205170230-053b83016050?w=1200&h=500&fit=crop&q=80",
    tag: "EXPRESS DELIVERY GUARANTEE",
    title: "High Speed Fashion Delivered in 2 Hours",
    subtitle: "Zero risk home trial. Return unselected sizes on the spot."
  }
]

export default function ShopPage({ onAddToCart, onOpenCart, cartCount = 0, currentUser, onOpenAuth, onUserAuthSuccess }) {
  const [products, setProducts] = useState([])
  const [categories, setCategories] = useState([])
  const [subCategories, setSubCategories] = useState([])
  const [shops, setShops] = useState([])
  const [loading, setLoading] = useState(true)
  const [error, setError] = useState(null)

  // Location State
  const [locationModalOpen, setLocationModalOpen] = useState(false)
  const [currentLocation, setCurrentLocation] = useState(() => {
    try {
      const saved = localStorage.getItem('user_location')
      return saved ? JSON.parse(saved) : { city: 'Bengaluru', area: 'Indiranagar (560038)', express: true, lat: 12.9716, lng: 77.5946 }
    } catch {
      return { city: 'Bengaluru', area: 'Indiranagar (560038)', express: true, lat: 12.9716, lng: 77.5946 }
    }
  })

  // Auth State
  const [authModalOpen, setAuthModalOpen] = useState(false)
  const [pendingItem, setPendingItem] = useState(null)

  // Filter State
  const [selectedSubCatId, setSelectedSubCatId] = useState('all')
  const [selectedShopId, setSelectedShopId] = useState(null)
  const [selectedGender, setSelectedGender] = useState('all')
  const [searchQuery, setSearchQuery] = useState('')
  const [sortBy, setSortBy] = useState('popular')
  const [activeBanner, setActiveBanner] = useState(0)
  const [activeProduct, setActiveProduct] = useState(null)

  // Banner Auto-rotate
  useEffect(() => {
    const timer = setInterval(() => {
      setActiveBanner((prev) => (prev + 1) % BANNERS.length)
    }, 5000)
    return () => clearInterval(timer)
  }, [])

  // Fetch real data on mount
  useEffect(() => {
    let isMounted = true

    async function loadData() {
      try {
        setLoading(true)
        setError(null)

        const [prodsData, catsData, shopsData] = await Promise.all([
          fetchProducts(),
          fetchCategories(),
          fetchShops()
        ])

        if (isMounted) {
          setProducts(prodsData)
          setCategories(catsData.categories)
          setSubCategories(catsData.subCategories)
          setShops(shopsData)
        }
      } catch (err) {
        console.error('Error loading real store API:', err)
        if (isMounted) setError(err.message || 'Failed to connect to store API')
      } finally {
        if (isMounted) setLoading(false)
      }
    }

    loadData()
    return () => { isMounted = false }
  }, [])

  // Auth Guard for Add to Cart
  const handleItemAction = (item) => {
    const user = getLoggedInUser()
    if (!user) {
      setPendingItem(item)
      setAuthModalOpen(true)
      return
    }
    onAddToCart(item)
  }

  const handleAuthSuccess = (user) => {
    if (onUserAuthSuccess) onUserAuthSuccess(user)
    setAuthModalOpen(false)
    if (pendingItem) {
      onAddToCart(pendingItem)
      setPendingItem(null)
    }
  }

  const handleLocationSelect = (loc) => {
    setCurrentLocation(loc)
    try {
      localStorage.setItem('user_location', JSON.stringify(loc))
    } catch (e) {}
  }

  // Filtered Products (Strict Real Data)
  const filteredProducts = useMemo(() => {
    return products.filter((p) => {
      if (selectedSubCatId !== 'all') {
        const matchSub = p.subCategoryId === Number(selectedSubCatId) || 
                         p.subCategoryName?.toLowerCase() === String(selectedSubCatId).toLowerCase()
        if (!matchSub) return false
      }

      if (selectedShopId) {
        if (p.shopId !== selectedShopId) return false
      }

      if (selectedGender !== 'all') {
        if (p.gender !== selectedGender && p.gender !== 'unisex') return false
      }

      if (searchQuery.trim()) {
        const q = searchQuery.toLowerCase()
        const matchName = p.name.toLowerCase().includes(q)
        const matchShop = (p.shopName || '').toLowerCase().includes(q)
        const matchDesc = (p.description || '').toLowerCase().includes(q)
        const matchSub = (p.subCategoryName || '').toLowerCase().includes(q)
        const matchColor = (p.color || '').toLowerCase().includes(q)
        const matchMaterial = (p.material || '').toLowerCase().includes(q)
        const matchPrice = q.includes('1000') ? (p.discountPrice <= 1000 || p.price <= 1000) : false
        if (!matchName && !matchShop && !matchDesc && !matchSub && !matchColor && !matchMaterial && !matchPrice) return false
      }

      return true
    }).sort((a, b) => {
      if (sortBy === 'price-low') return a.discountPrice - b.discountPrice
      if (sortBy === 'price-high') return b.discountPrice - a.discountPrice
      if (sortBy === 'discount') {
        const discA = a.price > a.discountPrice ? ((a.price - a.discountPrice)/a.price) : 0
        const discB = b.price > b.discountPrice ? ((b.price - b.discountPrice)/b.price) : 0
        return discB - discA
      }
      return b.id - a.id
    })
  }, [products, selectedSubCatId, selectedShopId, selectedGender, searchQuery, sortBy])

  const selectedShopObj = shops.find(s => s.id === selectedShopId)

  const selectedSubCatObj = useMemo(() => {
    return subCategories.find(s => s.id === Number(selectedSubCatId) || s.name?.toLowerCase() === String(selectedSubCatId).toLowerCase())
  }, [subCategories, selectedSubCatId])

  const selectedSubCatName = selectedSubCatObj ? selectedSubCatObj.name : selectedSubCatId

  const hasActiveFilter = Boolean(
    searchQuery.trim() || 
    selectedSubCatId !== 'all' || 
    selectedShopId !== null || 
    selectedGender !== 'all'
  )

  const handleClearAllFilters = () => {
    setSearchQuery('')
    setSelectedSubCatId('all')
    setSelectedShopId(null)
    setSelectedGender('all')
  }

  return (
    <div className="pro-shop-container">
      {/* ─── Secondary Store Control Bar ─── */}
      <div className="pro-store-subbar">
        <div className="store-subbar-inner">
          <div 
            className="location-info" 
            onClick={() => setLocationModalOpen(true)}
            title="Click to Change Delivery Location"
          >
            <span className="loc-pin">📍</span>
            <span className="loc-text">
              Delivering to: <strong>{currentLocation.city}, {currentLocation.area}</strong>
              <span className="loc-change-btn">Change</span>
            </span>
            <span className="express-badge">⚡ 2-HOUR EXPRESS</span>
          </div>

          <div className="search-box-container">
            <div className="search-wrapper">
              <span className="search-icon">🔍</span>
              <input
                type="text"
                placeholder="Search clothes, shoes, kurtas, local stores..."
                value={searchQuery}
                onChange={(e) => setSearchQuery(e.target.value)}
              />
              {searchQuery && (
                <button className="clear-search-btn" onClick={() => setSearchQuery('')}>&times;</button>
              )}
            </div>

            <div className="search-pills-row">
              <span style={{ fontSize: '11px', color: '#64748b', fontWeight: '700' }}>Quick Search:</span>
              {['Kurta', 'T-Shirt', 'Jeans', 'Shoes', 'Under ₹1000'].map((tag) => (
                <button
                  key={tag}
                  className="search-pill-tag"
                  onClick={() => setSearchQuery(tag === 'Under ₹1000' ? '1000' : tag)}
                >
                  {tag}
                </button>
              ))}
            </div>
          </div>
        </div>
      </div>

      {hasActiveFilter ? (
        /* ─── DEDICATED SEARCH & FILTER RESULTS VIEW PAGE ─── */
        <div className="pro-results-header">
          <div className="pro-results-header-inner">
            <div className="results-top-nav">
              <button className="btn-back-home" onClick={handleClearAllFilters}>
                ← Back to Shop Home
              </button>
            </div>

            <div className="results-title-group">
              <h2>
                {searchQuery.trim() ? (
                  <>Search results for <span>"{searchQuery}"</span></>
                ) : selectedShopObj ? (
                  <>Products from <span>{selectedShopObj.name}</span></>
                ) : selectedSubCatId !== 'all' ? (
                  <>Category: <span>{selectedSubCatName}</span></>
                ) : (
                  <>Filtered <span>Products</span></>
                )}
              </h2>
              <p className="results-subtitle">
                Found {filteredProducts.length} {filteredProducts.length === 1 ? 'item' : 'items'} matching your query
              </p>
            </div>

            {/* Active Filter Chips Bar */}
            <div className="active-filter-chips">
              <span className="active-label">Active Filters:</span>
              {searchQuery.trim() && (
                <span className="filter-chip">
                  Search: "{searchQuery}" <button onClick={() => setSearchQuery('')}>&times;</button>
                </span>
              )}
              {selectedSubCatId !== 'all' && (
                <span className="filter-chip">
                  Category: {selectedSubCatName} <button onClick={() => setSelectedSubCatId('all')}>&times;</button>
                </span>
              )}
              {selectedShopObj && (
                <span className="filter-chip">
                  Store: {selectedShopObj.name} <button onClick={() => setSelectedShopId(null)}>&times;</button>
                </span>
              )}
              {selectedGender !== 'all' && (
                <span className="filter-chip">
                  Gender: {selectedGender.charAt(0).toUpperCase() + selectedGender.slice(1)} <button onClick={() => setSelectedGender('all')}>&times;</button>
                </span>
              )}
              <button className="clear-all-chip-btn" onClick={handleClearAllFilters}>
                Reset All
              </button>
            </div>
          </div>
        </div>
      ) : (
        <>
          {/* ─── Hero Showcase Carousel ─── */}
          <section className="pro-hero-section">
            <div 
              className="pro-hero-slide"
              style={{ backgroundImage: `linear-gradient(90deg, rgba(15,23,42,0.92) 0%, rgba(15,23,42,0.65) 60%, transparent 100%), url(${BANNERS[activeBanner].image})` }}
            >
              <div className="pro-hero-content">
                <span className="pro-hero-tag">{BANNERS[activeBanner].tag}</span>
                <h1>{BANNERS[activeBanner].title}</h1>
                <p>{BANNERS[activeBanner].subtitle}</p>

                <div className="pro-hero-actions">
                  <a href="#products-grid" className="btn-hero-primary">Browse Live Products ({products.length})</a>
                  <a href="#stores-section" className="btn-hero-secondary">Explore Stores Nearby</a>
                </div>
              </div>

              <div className="pro-hero-indicators">
                {BANNERS.map((_, idx) => (
                  <button
                    key={idx}
                    className={`indicator ${activeBanner === idx ? 'active' : ''}`}
                    onClick={() => setActiveBanner(idx)}
                  />
                ))}
              </div>
            </div>
          </section>

          {/* ─── Category Filter Pills Carousel ─── */}
          <section className="pro-section category-section">
            <div className="pro-section-title">
              <div>
                <h2>Categories</h2>
                <p>Real categories from live store database</p>
              </div>
            </div>

            <div className="pro-cat-carousel">
              <button
                className={`pro-cat-pill ${selectedSubCatId === 'all' ? 'active' : ''}`}
                onClick={() => setSelectedSubCatId('all')}
              >
                <span className="icon">✨</span>
                <span className="label">All Items</span>
                <span className="count">({products.length})</span>
              </button>

              {subCategories.map((sc) => {
                const count = products.filter(p => p.subCategoryId === sc.id || p.subCategoryName === sc.name).length
                return (
                  <button
                    key={sc.id}
                    className={`pro-cat-pill ${selectedSubCatId === sc.id ? 'active' : ''}`}
                    onClick={() => setSelectedSubCatId(sc.id)}
                  >
                    <span className="icon">
                      {sc.name.toLowerCase().includes('jean') ? '👖' : 
                       sc.name.toLowerCase().includes('shirt') ? '👕' : 
                       sc.name.toLowerCase().includes('sand') ? '👡' : '👗'}
                    </span>
                    <span className="label">{sc.name}</span>
                    {count > 0 && <span className="count">({count})</span>}
                  </button>
                )
              })}
            </div>
          </section>

          {/* ─── Stores Nearby Section (Real Shops) ─── */}
          <section id="stores-section" className="pro-section stores-section">
            <div className="pro-section-title">
              <div>
                <h2>Stores Nearby</h2>
                <p>Certified boutiques with 15-minute trial dispatch</p>
              </div>
              {selectedShopId && (
                <button className="reset-filter-btn" onClick={() => setSelectedShopId(null)}>
                  ✕ Show All Stores
                </button>
              )}
            </div>

            <div className="pro-stores-grid">
              {shops.map((shop) => {
                const isSelected = selectedShopId === shop.id
                const shopProductCount = products.filter(p => p.shopId === shop.id).length
                return (
                  <div
                    key={shop.id}
                    className={`pro-store-card ${isSelected ? 'selected' : ''}`}
                    onClick={() => setSelectedShopId(isSelected ? null : shop.id)}
                  >
                    <div className="store-banner">
                      <img 
                        src={shop.image || 'https://images.unsplash.com/photo-1441986300917-64674bd600d8?w=800&auto=format&fit=crop&q=80'} 
                        alt={shop.name}
                        onError={(e) => { 
                          e.currentTarget.src = 'https://images.unsplash.com/photo-1441986300917-64674bd600d8?w=800&auto=format&fit=crop&q=80'
                        }}
                      />
                      <div className="store-fallback-icon">🏬</div>
                      <span className="store-rating-badge">★ {shop.rating}</span>
                    </div>

                    <div className="store-body">
                      <h4>{shop.name}</h4>
                      <p className="store-address">📍 {shop.city || 'Bengaluru'} {shop.address ? `• ${shop.address}` : ''}</p>
                      <div className="store-footer-meta">
                        <span className="delivery-tag">⚡ {shop.deliveryTime}</span>
                        <span className="items-count">{shopProductCount} items</span>
                      </div>
                    </div>
                  </div>
                )
              })}
            </div>
          </section>
        </>
      )}

      {/* ─── Products Catalog Grid (Real Products Only) ─── */}
      <section id="products-grid" className="pro-section products-section">
        <div className="pro-section-title">
          <div>
            <h2>
              {selectedShopObj ? `Products from ${selectedShopObj.name}` : 'Catalog Items'}
            </h2>
            <p>
              {selectedShopObj ? `Direct store inventory from ${selectedShopObj.city}` : 'Strict real database items — No dummy data'}
            </p>
          </div>

          {/* Controls: Gender Chips & Sort Selector */}
          <div className="pro-controls-cluster">
            <div className="gender-segmented">
              {['all', 'male', 'female', 'unisex'].map((g) => (
                <button
                  key={g}
                  className={`gender-tab ${selectedGender === g ? 'active' : ''}`}
                  onClick={() => setSelectedGender(g)}
                >
                  {g === 'all' ? 'All' : g.charAt(0).toUpperCase() + g.slice(1)}
                </button>
              ))}
            </div>

            <div className="sort-dropdown-box">
              <select value={sortBy} onChange={(e) => setSortBy(e.target.value)}>
                <option value="popular">Latest Arrivals</option>
                <option value="discount">Biggest Discounts</option>
                <option value="price-low">Price: Low to High</option>
                <option value="price-high">Price: High to Low</option>
              </select>
            </div>
          </div>
        </div>

        {/* Loading / Empty States */}
        {loading ? (
          <div className="pro-loading-card">
            <div className="pro-spinner"></div>
            <p>Loading real products from store database...</p>
          </div>
        ) : error ? (
          <div className="pro-error-card">
            <div className="icon">⚠️</div>
            <h4>Store API Connection Error</h4>
            <p>{error}</p>
            <button onClick={() => window.location.reload()}>Retry Connection</button>
          </div>
        ) : filteredProducts.length === 0 ? (
          <div className="pro-empty-card">
            <div className="icon">🛍️</div>
            <h4>No products match your filter</h4>
            <p>Try resetting filters or category selections.</p>
            <button onClick={() => { setSelectedSubCatId('all'); setSelectedShopId(null); setSelectedGender('all'); setSearchQuery('') }}>
              Reset All Filters
            </button>
          </div>
        ) : (
          <div className="pro-product-grid">
            {filteredProducts.map((product) => {
              const hasDiscount = product.discountPrice > 0 && product.discountPrice < product.price
              const discountPercent = hasDiscount 
                ? Math.round(((product.price - product.discountPrice) / product.price) * 100)
                : 0

              return (
                <div
                  key={product.id}
                  className="pro-product-card"
                  onClick={() => setActiveProduct(product)}
                >
                  {/* Image & Badges */}
                  <div className="pro-img-wrapper">
                    <img 
                      src={product.image || getFallbackProductImage(product.name, product.subCategoryName)} 
                      alt={product.name} 
                      loading="lazy"
                      onError={(e) => { 
                        e.currentTarget.src = getFallbackProductImage(product.name, product.subCategoryName)
                      }}
                    />

                    <div className="top-tags">
                      <span className="store-tag">🏬 {product.shopName}</span>
                      {hasDiscount && <span className="discount-tag">-{discountPercent}%</span>}
                    </div>

                    <div className="trial-overlay-pill">
                      <span>🏠 Try at Home in 2h</span>
                    </div>
                  </div>

                  {/* Body Content */}
                  <div className="pro-card-body">
                    <div className="meta-sub">
                      <span className="cat-label">{product.subCategoryName}</span>
                      {product.gender && <span className="gender-label">{product.gender.toUpperCase()}</span>}
                    </div>

                    <h3 className="product-title">{product.name}</h3>

                    {/* Specs Pills */}
                    <div className="specs-list">
                      {product.size && <span className="spec">Size: {product.size}</span>}
                      {product.color && <span className="spec">Color: {product.color}</span>}
                      {product.material && <span className="spec">{product.material}</span>}
                    </div>

                    {/* Price Row */}
                    <div className="price-row">
                      <span className="price-now">
                        ₹{(hasDiscount ? product.discountPrice : product.price).toLocaleString()}
                      </span>
                      {hasDiscount && (
                        <span className="price-was">₹{product.price.toLocaleString()}</span>
                      )}
                    </div>

                    {/* Actions */}
                    <div className="card-actions">
                      <button
                        className="btn-quick-view"
                        onClick={(e) => { e.stopPropagation(); setActiveProduct(product) }}
                      >
                        Details
                      </button>
                      <button
                        className="btn-add-try"
                        onClick={(e) => {
                          e.stopPropagation()
                          handleItemAction({
                            ...product,
                            selectedSize: product.sizes?.[0] || product.size || 'M',
                            selectedColor: product.colors?.[0] || product.color || 'Default',
                            purchaseMode: 'try',
                            cartId: `${product.id}-${product.sizes?.[0] || 'M'}-${product.colors?.[0] || 'Default'}-try`
                          })
                        }}
                      >
                        🏠 Try Now
                      </button>
                    </div>
                  </div>
                </div>
              )
            })}
          </div>
        )}
      </section>

      {/* ─── Product Details Modal ─── */}
      {activeProduct && (
        <ProductDetailModal
          product={activeProduct}
          onClose={() => setActiveProduct(null)}
          onAddToCart={handleItemAction}
        />
      )}

      {/* ─── Auth Modal (Triggers on Add to Cart / Bag) ─── */}
      <AuthModal
        isOpen={authModalOpen}
        onClose={() => { setAuthModalOpen(false); setPendingItem(null) }}
        onSuccess={handleAuthSuccess}
        pendingItemName={pendingItem?.name}
      />

      {/* ─── Location Picker Modal ─── */}
      <LocationModal
        isOpen={locationModalOpen}
        onClose={() => setLocationModalOpen(false)}
        currentLocation={currentLocation}
        onLocationSelect={handleLocationSelect}
      />
    </div>
  )
}
