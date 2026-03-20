import Link from "next/link"

export default function NotImplemented() {
  return (
    <div style={{ padding: "2rem", textAlign: "center" }}>
      <h1>Not Implemented</h1>
      <p>This feature is not yet available for your role.</p>
      <Link href="/">Back to Home</Link>
    </div>
  )
}
