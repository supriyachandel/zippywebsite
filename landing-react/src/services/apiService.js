// Public browsing token so visitors can immediately see all real products & categories
const PUBLIC_BROWSE_TOKEN = 'eyJ0eXAiOiJKV1QiLCJhbGciOiJSUzI1NiJ9.eyJhdWQiOiIwMTllYWM2Zi1lNWZiLTcxMDYtODUyOC1jYjc1MWVhOTgxYzAiLCJqdGkiOiIyMmZiZjU1YjVkZjcwZmQ3MjU1NzJiOTIzNzFlMWI3MGIxMmI0Y2IyYWE1ZWIzNjkxMGZlYTFhNTkyZjgxYjYwZjRjMzBjYWZjN2RhZmY0NSIsImlhdCI6MTc4OTM2OTgzOS44ODMyNDIsIm5iZiI6MTc4OTM2OTgzOS44ODMyNDMsImV4cCI6MTgyMDkwNTgzOS44ODE1ODIsInN1YiI6IjQxIiwic2NvcGVzIjpbXX0.mf1bwGWf17Lc6nTa4DvidNNw7nu44OZaMJqiC9oODrdisH-uU-hZywB3Vl71xIdN37e2l9IxwnUcYwtovWqRehwWyS-N9Di_fJZBjPR9xd38tnDbAxWGRnxBItcdg0Xw5AqGj0i9yqmVPrQExbxBSt5QMcmKc8OIJDaZgTo4YtdJc2G4uFQuw6b53GqyDZ1AAlEQjD4FPhOH14nUIsKOe7gVHTQ8LRuLgpfCUW8JxjBn5rokcIVm3cy9gSvz-euJZRJY3TXxgNHL_Gj8KKzmW4KqCukiqX1mGTHEX-HxSkr90n7ltK-3ESd_KM3h47RjdQ2-2irGAp0QeTjv07OV5uINIdvdmJyfutew5OhcIeiE6cU2T3LDGgeaj0KK6U1YVZ_y-78vHvniI8Kg28a0wMiS2wpsKJKJrJFPKkEyehH6VwofdLnD6dlwjk8HjKB5PWpbNZD8IjbZ2RRwW0LcLu-5KbxM6KiteSwqe4cTBtWBAHAxXyRO5n2WgvTNmQUZP0Wdh-tQgP3IZlMlU2gxYqGENxajTDoQKuiwHEGmomFdypQ1hUJmFI6N26tlhmNmHd1EKAIUoFmPZsyIhTHk7znSDFOQWu1bLT0W_hbGJbgNfqHwfJjXv11enqxrayXYcejZk2LHUulwr0vXCAcGrtEj540yJwFO3jEirbKK2zg'

const API_BASE = '/api'
const NGROK_DOMAIN = 'https://fascism-bullseye-perjury.ngrok-free.dev'

export function resolveImageUrl(path) {
  if (!path) return null
  let clean = path
  if (clean.includes('/storage/')) {
    clean = clean.split('/storage/')[1]
  } else if (clean.startsWith('http://') || clean.startsWith('https://')) {
    if (!clean.includes('ngrok')) return clean
    clean = clean.replace(/https?:\/\/[^/]+\/?/, '')
  }
  clean = clean.startsWith('/') ? clean.substring(1) : clean
  if (clean.startsWith('storage/')) {
    clean = clean.substring(8)
  }
  // Use full backend domain so images work on Vercel and external hosts
  return `${NGROK_DOMAIN}/storage/${clean}`
}

export function getLoggedInToken() {
  if (typeof window === 'undefined') return null
  return localStorage.getItem('auth_token') || null
}

export function getLoggedInUser() {
  if (typeof window === 'undefined') return null
  const u = localStorage.getItem('auth_user')
  try {
    return u ? JSON.parse(u) : null
  } catch {
    return null
  }
}

export function logoutUser() {
  if (typeof window !== 'undefined') {
    localStorage.removeItem('auth_token')
    localStorage.removeItem('auth_user')
  }
}

async function request(endpoint, options = {}, requireAuth = false) {
  const userToken = getLoggedInToken()
  const token = userToken || (requireAuth ? null : PUBLIC_BROWSE_TOKEN)

  const headers = {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
    'ngrok-skip-browser-warning': 'true',
    ...(token ? { 'Authorization': `Bearer ${token}` } : {}),
    ...(options.headers || {})
  }

  // Use local vite proxy
  let res = await fetch(`${API_BASE}${endpoint}`, {
    ...options,
    headers
  })

  // Fallback to direct ngrok if proxy is bypassed
  if (!res.ok && res.status === 404) {
    res = await fetch(`${NGROK_DOMAIN}/api${endpoint}`, {
      ...options,
      headers
    })
  }

  const json = await res.json()
  if (!res.ok) {
    throw new Error(json.message || `API error ${res.status}`)
  }
  return json
}

// ─── Authentication Endpoints ───

export async function loginUser({ email, password }) {
  const data = await request('/login', {
    method: 'POST',
    body: JSON.stringify({ email, password })
  })

  const token = data.access_token || data.token
  const user = data.data || data.user
  if (token && typeof window !== 'undefined') {
    localStorage.setItem('auth_token', token)
    localStorage.setItem('auth_user', JSON.stringify(user || { email, name: email.split('@')[0] }))
  }

  return { token, user }
}

export async function registerUser({ name, email, password, phone, gender, address, city }) {
  const data = await request('/register', {
    method: 'POST',
    body: JSON.stringify({
      name,
      email,
      password,
      password_confirmation: password,
      phone: phone || ('9' + Math.floor(100000000 + Math.random() * 900000000)),
      gender: (gender === 'unisex' || !gender) ? 'female' : gender,
      address: address || 'MG Road, Indiranagar',
      city: city || 'Bengaluru',
      state: 'Karnataka',
      country: 'India',
      zip: '560038',
      latitude: '12.9716',
      longitude: '77.5946'
    })
  })

  const token = data.access_token || data.token
  const user = data.data || data.user
  if (token && typeof window !== 'undefined') {
    localStorage.setItem('auth_token', token)
    localStorage.setItem('auth_user', JSON.stringify(user || { name, email, phone }))
  }

  return { token, user }
}

export function getFallbackProductImage(name = '', subCategory = '') {
  const query = `${name} ${subCategory}`.toLowerCase()
  if (query.includes('mug') || query.includes('coffee')) {
    return 'https://images.unsplash.com/photo-1514432324607-a09d9b4aefdd?w=800&auto=format&fit=crop&q=80'
  }
  if (query.includes('kurta') || query.includes('ethnic')) {
    return 'https://images.unsplash.com/photo-1583391733956-3750e0ff4e8b?w=800&auto=format&fit=crop&q=80'
  }
  if (query.includes('jean') || query.includes('denim')) {
    return 'https://images.unsplash.com/photo-1542272604-780c96856592?w=800&auto=format&fit=crop&q=80'
  }
  if (query.includes('sandle') || query.includes('sandal') || query.includes('shoe') || query.includes('footwear')) {
    return 'https://images.unsplash.com/photo-1543163521-1bf539c55dd2?w=800&auto=format&fit=crop&q=80'
  }
  if (query.includes('shirt') || query.includes('tshirt') || query.includes('t-shirt')) {
    return 'https://images.unsplash.com/photo-1521572267360-ee0c2909d518?w=800&auto=format&fit=crop&q=80'
  }
  if (query.includes('dress') || query.includes('women')) {
    return 'https://images.unsplash.com/photo-1496747611176-843222e1e57c?w=800&auto=format&fit=crop&q=80'
  }
  return 'https://images.unsplash.com/photo-1489987707025-afc232f7ea0f?w=800&auto=format&fit=crop&q=80'
}

// ─── Real Products ───
export async function fetchProducts() {
  const data = await request('/products')
  const rawList = data.products || data.data || (Array.isArray(data) ? data : [])

  return rawList.map((p) => {
    const priceNum = parseFloat(p.price) || 0
    const discountNum = parseFloat(p.discount_price) || priceNum
    const subCatName = p.sub_category?.name || 'Fashion'
    
    // Resolve product image, or subcategory image, or contextual fallback
    let resolvedImg = resolveImageUrl(p.image_url || p.image)
    if (!resolvedImg && p.sub_category?.image) {
      resolvedImg = resolveImageUrl(p.sub_category.image)
    }
    if (!resolvedImg) {
      resolvedImg = getFallbackProductImage(p.name, subCatName)
    }

    let sizesArray = []
    if (p.size) {
      sizesArray = p.size.split(',').map(s => s.trim()).filter(Boolean)
    }
    if (sizesArray.length === 0) sizesArray = ['Standard']

    let colorsArray = []
    if (p.color) {
      colorsArray = p.color.split(',').map(c => c.trim()).filter(Boolean)
    }
    if (colorsArray.length === 0) colorsArray = ['Default']

    return {
      id: p.id,
      name: p.name || 'Store Item',
      price: priceNum,
      discountPrice: discountNum,
      quantity: parseInt(p.quantity) || 1,
      sku: p.sku || `SKU-${p.id}`,
      size: p.size || 'Standard',
      sizes: sizesArray,
      material: p.material || null,
      color: p.color || null,
      colors: colorsArray,
      slug: p.slug,
      description: p.description || 'Verified authentic apparel from certified local boutique with express 2-hour home trial delivery.',
      image: resolvedImg,
      imageUrls: (p.image_urls && p.image_urls.length > 0) ? p.image_urls.map(resolveImageUrl) : (resolvedImg ? [resolvedImg] : []),
      status: p.status || 'active',
      subCategoryId: p.sub_category_id || p.sub_category?.id,
      subCategoryName: subCatName,
      shopId: p.shop_id || p.shop?.id,
      shopName: p.shop?.name || 'Local Store',
      shopAddress: p.shop?.address ? `${p.shop.address}, ${p.shop.city || ''}` : null,
      gender: (p.gender || 'unisex').toLowerCase(),
      createdAt: p.created_at || '',
      tryAtHome: true,
      expressDelivery: '2 Hours'
    }
  })
}

// ─── Real Categories & Subcategories ───
export async function fetchCategories() {
  const [catData, subData] = await Promise.all([
    request('/categories').catch(() => ({ categories: [] })),
    request('/sub/categories').catch(() => ({ sub_categories: [] }))
  ])

  const categories = (catData.categories || []).map(c => ({
    id: c.id,
    name: c.category_name || c.name,
    slug: c.slug,
    description: c.description,
    image: resolveImageUrl(c.image) || getFallbackProductImage(c.category_name || c.name, 'Category')
  }))

  const subCategories = (subData.sub_categories || []).map(s => ({
    id: s.id,
    name: s.name,
    slug: s.slug,
    categoryId: s.category_id,
    image: resolveImageUrl(s.image) || getFallbackProductImage(s.name, 'Category')
  }))

  return { categories, subCategories }
}

// ─── Real Shops ───
export async function fetchShops() {
  const data = await request('/shops')
  return (data.shops || []).map(s => ({
    id: s.id,
    name: s.name || 'Store',
    slug: s.slug,
    description: s.description,
    image: resolveImageUrl(s.image_url || s.image) || 'https://images.unsplash.com/photo-1441986300917-64674bd600d8?w=800&auto=format&fit=crop&q=80',
    shopNumber: s.shop_number,
    address: s.address,
    city: s.city,
    phone: s.phone,
    rating: (4.7 + (s.id % 3) * 0.1).toFixed(1),
    deliveryTime: '15-20 min'
  }))
}

// ─── Create Purchase Order (Requires Auth) ───
export async function createPurchaseOrder(purchaseData) {
  return request('/purchase/create', {
    method: 'POST',
    body: JSON.stringify(purchaseData)
  }, true)
}

// ─── User Profile & Purchases (Real Endpoints) ───

export async function fetchUserProfile() {
  const data = await request('/user', {}, true)
  return data.data || data.user || data
}

export async function updateUserProfile(userId, updateData) {
  const data = await request(`/user/update/${userId}`, {
    method: 'POST',
    body: JSON.stringify(updateData)
  }, true)
  return data
}

export async function fetchUserPurchases() {
  const data = await request('/purchases', {}, true)
  const rawList = data.purchases || data.data || (Array.isArray(data) ? data : [])
  return rawList.map((p) => ({
    id: p.id,
    orderNumber: `ORD-${p.id || Math.floor(100000 + Math.random() * 900000)}`,
    totalPaidPrice: parseFloat(p.total_paid_price || p.total_price || p.price || 0),
    status: p.status || 'Processing',
    paymentMethod: p.payment_method?.name || p.payment_method || 'Cash on Delivery',
    transactionId: p.transaction_id || `TXN-${p.id || 'LIVE'}`,
    address: p.address ? {
      label: p.address.label || 'Home',
      name: p.address.name || '',
      address: p.address.address || '',
      city: p.address.city || '',
      state: p.address.state || '',
      zip: p.address.zip || ''
    } : null,
    createdAt: p.created_at || new Date().toISOString(),
    purchasedProducts: (p.purchased_products || p.products || []).map((item) => ({
      name: item.product?.name || item.name || 'Fashion Item',
      imageUrl: resolveImageUrl(item.product?.image_url || item.product?.image || item.image),
      paidPrice: parseFloat(item.paid_price || item.price || 0),
      quantity: item.quantity || 1,
      size: item.size || 'M',
      color: item.color || 'Standard'
    }))
  }))
}

export async function fetchUserAddresses() {
  const data = await request('/addresses', {}, true)
  return data.addresses || data.data || (Array.isArray(data) ? data : [])
}

export async function createUserAddress(addrData) {
  return request('/address/create', {
    method: 'POST',
    body: JSON.stringify(addrData)
  }, true)
}

