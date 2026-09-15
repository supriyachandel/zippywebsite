import { useState } from 'react'
import { getFallbackProductImage } from '../services/apiService'
import SafeImage from './SafeImage'

export default function ProductDetailModal({ product, onClose, onAddToCart }) {
  if (!product) return null

  const [selectedSize, setSelectedSize] = useState(product.sizes?.[0] || product.size || 'Standard')
  const [selectedColor, setSelectedColor] = useState(product.colors?.[0] || product.color || 'Default')
  const [purchaseMode, setPurchaseMode] = useState(product.tryAtHome ? 'try' : 'buy')
  const [addedNotice, setAddedNotice] = useState(false)

  const fallbackImg = getFallbackProductImage(product.name, product.subCategoryName)

  const hasDiscount = product.discountPrice > 0 && product.discountPrice < product.price
  const discountPercent = hasDiscount
    ? Math.round(((product.price - product.discountPrice) / product.price) * 100)
    : 0

  const handleAdd = () => {
    onAddToCart({
      ...product,
      selectedSize,
      selectedColor,
      purchaseMode,
      cartId: `${product.id}-${selectedSize}-${selectedColor}-${purchaseMode}`
    })
    setAddedNotice(true)
    setTimeout(() => {
      setAddedNotice(false)
      onClose()
    }, 1200)
  }

  return (
    <div className="modal-overlay" onClick={onClose}>
      <div className="modal-content product-detail-modal" onClick={(e) => e.stopPropagation()}>
        <button className="modal-close-btn" onClick={onClose}>&times;</button>

        <div className="product-modal-grid">
          {/* Left: Image Gallery */}
          <div className="product-modal-media">
            <div className="product-modal-main-img">
              <SafeImage 
                src={product.image} 
                fallback={fallbackImg}
                alt={product.name} 
              />
              {hasDiscount && <span className="product-modal-badge">{discountPercent}% OFF</span>}
              <div className="try-home-banner">
                <span className="icon">🏠</span>
                <span>Try at Home Available — Pay only if you keep!</span>
              </div>
            </div>
          </div>

          {/* Right: Info & Actions */}
          <div className="product-modal-info">
            <div className="product-shop-tag">
              🏬 {product.shopName} {product.shopAddress ? `• ${product.shopAddress}` : ''}
            </div>
            <h2 className="product-modal-title">{product.name}</h2>

            <div className="product-modal-meta">
              <span className="category-pill">{product.subCategoryName}</span>
              {product.gender && <span className="gender-pill">{product.gender.toUpperCase()}</span>}
              {product.sku && <span className="sku-pill">SKU: {product.sku}</span>}
            </div>

            <div className="product-modal-price">
              <span className="current-price">
                ₹{(hasDiscount ? product.discountPrice : product.price).toLocaleString()}
              </span>
              {hasDiscount && (
                <span className="original-price">₹{product.price.toLocaleString()}</span>
              )}
              {hasDiscount && (
                <span className="discount-tag">{discountPercent}% OFF</span>
              )}
            </div>

            <p className="product-modal-desc">{product.description}</p>

            {/* Real Product Specs */}
            <div className="product-specs-box">
              {product.material && (
                <div className="spec-item">
                  <span className="label">Material:</span>
                  <span className="val">{product.material}</span>
                </div>
              )}
              {product.color && (
                <div className="spec-item">
                  <span className="label">Color:</span>
                  <span className="val">{product.color}</span>
                </div>
              )}
              {product.size && (
                <div className="spec-item">
                  <span className="label">Available Sizes:</span>
                  <span className="val">{product.size}</span>
                </div>
              )}
            </div>

            {/* Size Selector */}
            {product.sizes && product.sizes.length > 0 && (
              <div className="option-group">
                <label className="option-label">Select Size:</label>
                <div className="option-pills">
                  {product.sizes.map((size) => (
                    <button
                      key={size}
                      className={`option-pill ${selectedSize === size ? 'active' : ''}`}
                      onClick={() => setSelectedSize(size)}
                    >
                      {size}
                    </button>
                  ))}
                </div>
              </div>
            )}

            {/* Color Selector */}
            {product.colors && product.colors.length > 0 && (
              <div className="option-group">
                <label className="option-label">Select Color:</label>
                <div className="option-pills">
                  {product.colors.map((color) => (
                    <button
                      key={color}
                      className={`option-pill ${selectedColor === color ? 'active' : ''}`}
                      onClick={() => setSelectedColor(color)}
                    >
                      {color}
                    </button>
                  ))}
                </div>
              </div>
            )}

            {/* Mode selection (Try at home vs Buy) */}
            <div className="purchase-mode-selector">
              <div 
                className={`mode-card ${purchaseMode === 'try' ? 'selected' : ''}`}
                onClick={() => setPurchaseMode('try')}
              >
                <div className="mode-header">
                  <span className="mode-icon">🏠</span>
                  <strong>Try at Home (App Feature)</strong>
                </div>
                <p>Agent delivers to your door. Pay ₹0 upfront, only pay for what you keep!</p>
              </div>
              <div 
                className={`mode-card ${purchaseMode === 'buy' ? 'selected' : ''}`}
                onClick={() => setPurchaseMode('buy')}
              >
                <div className="mode-header">
                  <span className="mode-icon">🛍️</span>
                  <strong>Direct Purchase</strong>
                </div>
                <p>Standard express delivery directly to your location.</p>
              </div>
            </div>

            {/* Features highlight */}
            <div className="product-highlights">
              <div className="highlight-item">
                <span className="icon">🚚</span> Express 2-Hour Delivery
              </div>
              <div className="highlight-item">
                <span className="icon">↩️</span> Instant Returns
              </div>
              <div className="highlight-item">
                <span className="icon">🛡️</span> Verified Local Store
              </div>
            </div>

            {/* Add Action Button */}
            <button className="add-to-cart-btn" onClick={handleAdd} disabled={addedNotice}>
              {addedNotice 
                ? '✓ Added to Bag!' 
                : purchaseMode === 'try' 
                  ? `🏠 Book Home Trial (₹${(hasDiscount ? product.discountPrice : product.price).toLocaleString()})` 
                  : `🛍️ Add to Bag (₹${(hasDiscount ? product.discountPrice : product.price).toLocaleString()})`
              }
            </button>
          </div>
        </div>
      </div>
    </div>
  )
}
