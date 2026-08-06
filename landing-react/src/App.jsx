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
import './App.css'

export default function App() {
  return (
    <>
      <Nav />
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
      <Footer />
    </>
  )
}
