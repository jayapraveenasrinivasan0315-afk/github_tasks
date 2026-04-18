import { useState, useEffect, useRef } from 'react'

// const API_URL = 'http://localhost:8000'
const API_URL = import.meta.env.VITE_API_BASE_URL

// ── Utility: format ISO timestamp to readable string ──────────────────────
function formatDate(isoString) {
  if (!isoString) return ''
  return new Date(isoString).toLocaleDateString('en-IN', {
    day: '2-digit',
    month: 'short',
    year: 'numeric',
    hour: '2-digit',
    minute: '2-digit',
  })
}

// ── Sub-component: single name row ────────────────────────────────────────
function NameItem({ name, createdAt }) {
  return (
    <li>
      <span className="name-text">{name}</span>
      <span className="timestamp">{formatDate(createdAt)}</span>
    </li>
  )
}

// ── Sub-component: feedback message ──────────────────────────────────────
function Message({ text, type }) {
  if (!text) return null
  return <div className={`message ${type}`}>{text}</div>
}

// ── Main App component ────────────────────────────────────────────────────
export default function App() {
  const [nameInput, setNameInput]   = useState('')
  const [names, setNames]           = useState([])
  const [loading, setLoading]       = useState(false)
  const [message, setMessage]       = useState({ text: '', type: '' })
  const inputRef                    = useRef(null)
  const timerRef                    = useRef(null)

  // Load all saved names on first render
  useEffect(() => {
    fetchNames()
    return () => clearTimeout(timerRef.current)
  }, [])

  // Auto-clear message after 4 seconds
  function showMessage(text, type) {
    setMessage({ text, type })
    clearTimeout(timerRef.current)
    timerRef.current = setTimeout(() => setMessage({ text: '', type: '' }), 4000)
  }

  // GET /names — fetch all saved names from backend
  async function fetchNames() {
    try {
      const res = await fetch(`${API_URL}/names`)
      if (!res.ok) throw new Error('Failed to fetch names.')
      const data = await res.json()
      setNames(data)
    } catch (err) {
      console.error('Fetch error:', err.message)
    }
  }

  // POST /names — save a new name to the backend
  async function saveName() {
    const trimmed = nameInput.trim()
    if (!trimmed) {
      showMessage('Please enter a name before saving.', 'error')
      inputRef.current?.focus()
      return
    }

    setLoading(true)
    try {
      const res = await fetch(`${API_URL}/names`, {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ name: trimmed }),
      })

      if (!res.ok) {
        const err = await res.json()
        throw new Error(err.detail || 'Something went wrong.')
      }

      const saved = await res.json()
      showMessage(`"${saved.name}" saved successfully!`, 'success')
      setNameInput('')
      await fetchNames()
    } catch (err) {
      showMessage(err.message, 'error')
    } finally {
      setLoading(false)
    }
  }

  // Allow pressing Enter in the input field
  function handleKeyDown(e) {
    if (e.key === 'Enter') saveName()
  }

  // Names displayed newest first
  const sortedNames = [...names].reverse()

  return (
    <div className="card">
      <h1>Save a Name</h1>
      <p className="subtitle">Type a name and save it to the database.</p>

      {/* Form */}
      <div className="form-group">
        <input
          ref={inputRef}
          type="text"
          id="name-input"
          placeholder="Enter a name..."
          maxLength={100}
          autoComplete="off"
          value={nameInput}
          onChange={(e) => setNameInput(e.target.value)}
          onKeyDown={handleKeyDown}
        />
        <button id="save-btn" onClick={saveName} disabled={loading}>
          {loading ? 'Saving...' : 'Save'}
        </button>
      </div>

      {/* Feedback message */}
      <Message text={message.text} type={message.type} />

      {/* Saved names list */}
      <div className="saved-list">
        <h2>Saved names</h2>
        <ul>
          {sortedNames.length === 0 ? (
            <li className="empty-state">No names saved yet.</li>
          ) : (
            sortedNames.map((item) => (
              <NameItem
                key={item.id}
                name={item.name}
                createdAt={item.created_at}
              />
            ))
          )}
        </ul>
      </div>
    </div>
  )
}
