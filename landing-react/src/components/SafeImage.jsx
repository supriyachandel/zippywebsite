import { useState, useEffect } from 'react'
import { getCachedImageUrl } from '../services/imageCache'

export default function SafeImage({ src, fallback, alt = '', className = '', ...props }) {
  const isNgrok = Boolean(src && src.includes('ngrok'))

  // If not ngrok, use src directly. If ngrok, do NOT put raw ngrok URL in img src to prevent warning screen onError
  const [imgSrc, setImgSrc] = useState(() => {
    if (!src) return fallback || ''
    if (!isNgrok) return src
    return ''
  })

  useEffect(() => {
    let active = true

    if (!src) {
      setImgSrc(fallback || '')
      return
    }

    if (isNgrok) {
      getCachedImageUrl(src)
        .then((blobUrl) => {
          if (active) {
            if (blobUrl) {
              setImgSrc(blobUrl)
            } else if (fallback) {
              setImgSrc(fallback)
            }
          }
        })
        .catch(() => {
          if (active && fallback) {
            setImgSrc(fallback)
          }
        })
    } else {
      setImgSrc(src)
    }

    return () => {
      active = false
    }
  }, [src, fallback, isNgrok])

  return (
    <img
      src={imgSrc || fallback || 'data:image/svg+xml;base64,PHN2ZyB4bWxucz0iaHR0cDovL3d3dy53My5vcmcvMjAwMC9zdmciIHdpZHRoPSIxIiBoZWlnaHQ9IjEiPjwvc3ZnPg=='}
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
