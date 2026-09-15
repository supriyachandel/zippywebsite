const imageCache = new Map()

/**
 * Fetches an image with ngrok-skip-browser-warning headers if needed,
 * converting it to a local Blob URL to completely bypass the ngrok warning screen.
 */
export async function getCachedImageUrl(url) {
  if (!url) return null
  if (!url.includes('ngrok')) return url
  if (imageCache.has(url)) return imageCache.get(url)

  try {
    const res = await fetch(url, {
      headers: {
        'ngrok-skip-browser-warning': 'true'
      }
    })
    if (!res.ok) throw new Error(`HTTP error ${res.status}`)
    const blob = await res.blob()
    const objectUrl = URL.createObjectURL(blob)
    imageCache.set(url, objectUrl)
    return objectUrl
  } catch (err) {
    console.warn('Failed to fetch image via blob bypass:', url, err)
    return url
  }
}
