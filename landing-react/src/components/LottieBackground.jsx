import { useRef, useEffect } from 'react'
import lottie from 'lottie-web'

export default function LottieBackground() {
  const ref = useRef(null)

  useEffect(() => {
    const anim = lottie.loadAnimation({
      container: ref.current,
      renderer: 'svg',
      loop: true,
      autoplay: true,
      path: '/lottie.json',
    })
    return () => anim.destroy()
  }, [])

  return (
    <div className="lottie-bg">
      <div ref={ref} className="lottie-bg-inner" />
      <div className="lottie-bg-fade" />
    </div>
  )
}
