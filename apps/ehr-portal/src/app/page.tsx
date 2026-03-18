export default function Home() {
  return (
    <main style={{ display: "flex", height: "100vh", alignItems: "center", justifyContent: "center" }}>
      <h1 style={{ fontSize: "20vw", fontWeight: 700, letterSpacing: "-0.05em", lineHeight: 1 }}>
        EHR
      </h1>
      <footer style={{ position: "fixed", bottom: "1.5rem", fontSize: "0.8rem", opacity: 0.4 }}>
        &copy;2026{" "}
        <a href="https://stancarver.com" target="_blank" rel="noopener noreferrer" style={{ color: "inherit" }}>
          Stan Carver II
        </a>
      </footer>
    </main>
  );
}
