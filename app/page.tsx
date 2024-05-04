'use client'

import Image from 'next/image'
import Link from 'next/link'
import { useEffect, useState } from 'react'

export default function Home() {
  const [message, setMessage] = useState('')

  useEffect(() => {
    fetch('/api/python')
      .then(response => response.json())
      .then(data => setMessage(data.message))
  }, [])

  return (
    <main className="flex min-h-screen flex-col items-center justify-between p-24">
      <h1>Welcome to My App</h1>
      <p>{message}</p>
      {/* ... */}

      <div className="mb-32 grid text-center lg:mb-0 lg:grid-cols-4 lg:text-left">
        {/* ... */}
      </div>
    </main>
  )
}