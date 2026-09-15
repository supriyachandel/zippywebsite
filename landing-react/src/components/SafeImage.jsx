import { useState, useEffect } from 'react'
import { getCachedImageUrl } from '../services/imageCache'

export default function SafeImage({ src, fallback, alt = '', className = '', ...props }) {
  const [imgSrc, setImgSrc] = useState(src || fallback || '')

  useEffect(() => {
    let active = true

    if (src && src.includes('ngrok')) {
      getCachedImageUrl(src).then((resolvedUrl) => {
        if (active && resolvedUrl) {
          setImgSrc(resolvedUrl)
        }
      }).catch(() => {
        if (active && fallback) {
          setImgSrc(fallback)
        }
      })
    } else {
      setImgSrc(src || fallback || '')
    }

    return () => {
      active = false
    }
  }, [src, fallback])

  return (
    <img
      src={imgSrc || fallback}
      alt={alt}
      className={className}
      onError={() => {
        if (fallback && imgSrc !== fallback) {
          setImgSrc(fallback)
        }
      }}
      {...props}
    />
  )
}
