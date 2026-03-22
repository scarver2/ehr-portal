// src/components/ecg-animation.tsx
// Animated ECG waveform component - standalone, visible decoration

export function EcgAnimation() {
  // Classic ECG/EKG waveform path: flat → P wave → QRS complex → T wave → flat
  // ViewBox is 400×60, waveform runs left to right
  const ecgPath = "M0,30 L60,30 L70,28 L75,32 L80,30 L100,30 L105,30 L108,10 L112,50 L115,5 L120,55 L124,30 L130,30 L140,22 L150,30 L200,30 L260,30 L270,28 L275,32 L280,30 L300,30 L305,30 L308,10 L312,50 L315,5 L320,55 L324,30 L330,30 L340,22 L350,30 L400,30"

  return (
    <div className="w-full bg-gradient-to-r from-transparent via-blue-50 to-transparent p-6 pointer-events-none select-none">
      <svg
        viewBox="0 0 400 60"
        preserveAspectRatio="xMidYMid meet"
        className="w-full h-24"
        aria-hidden="true"
      >
        <path
          d={ecgPath}
          fill="none"
          stroke="#3b82f6"
          strokeWidth="2"
          strokeLinecap="round"
          strokeLinejoin="round"
          className="ecg-path opacity-80"
        />
        <path
          d={ecgPath}
          fill="none"
          stroke="#60a5fa"
          strokeWidth="2"
          strokeLinecap="round"
          strokeLinejoin="round"
          className="ecg-path-delayed opacity-40"
        />
      </svg>
    </div>
  )
}
