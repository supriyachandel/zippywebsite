import { useEffect, useRef } from 'react'

const ORBS = [
  { size: 400, color: 'rgba(233,30,99,0.04)', x: 80, y: 20, speed: 0.3 },
  { size: 350, color: 'rgba(74,108,247,0.03)', x: 15, y: 70, speed: 0.25 },
  { size: 300, color: 'rgba(233,30,99,0.03)', x: 60, y: 80, speed: 0.35 },
]

function Orb({ size, color, x, y, speed }) {
  const ref = useRef(null)
  const t = useRef(Math.random() * Math.PI * 2)

  useEffect(() => {
    const el = ref.current
    if (!el) return
    let raf
    const animate = () => {
      t.current += speed * 0.003
      const dx = Math.sin(t.current * 0.5) * 15
      const dy = Math.cos(t.current * 0.3) * 10
      el.style.transform = `translate(${dx}px, ${dy}px)`
      raf = requestAnimationFrame(animate)
    }
    raf = requestAnimationFrame(animate)
    return () => cancelAnimationFrame(raf)
  }, [speed])

  return (
    <div
      ref={ref}
      style={{
        position: 'absolute',
        width: size,
        height: size,
        left: `${x}%`,
        top: `${y}%`,
        transform: 'translate(-50%, -50%)',
        borderRadius: '50%',
        background: `radial-gradient(circle, ${color}, transparent 70%)`,
        filter: 'blur(40px)',
        pointerEvents: 'none',
      }}
    />
  )
}

export default function BackgroundEffects() {
  return (
    <div
      style={{
        position: 'fixed',
        inset: 0,
        zIndex: 0,
        overflow: 'hidden',
        pointerEvents: 'none',
      }}
    >
      {ORBS.map((o, i) => <Orb key={i} {...o} />)}
    </div>
  )
}
