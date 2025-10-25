export default function Home() {
  return (
    <div className="flex min-h-screen flex-col items-center justify-center p-8">
      <main className="flex flex-col items-center gap-8 max-w-2xl text-center">
        <h1 className="text-4xl font-[var(--font-weight-bold)] tracking-tight">
          Video Alert
        </h1>
        <p className="text-lg text-[var(--color-muted-foreground)]">
          Welcome to Video Alert - A modern web application built with Next.js and FastAPI
        </p>
        <div className="flex flex-col gap-4 w-full max-w-md">
          <div className="rounded-[var(--radius-lg)] border border-[var(--color-border)] p-6 bg-[var(--color-surface)] shadow-[var(--shadow-sm)]">
            <h2 className="text-xl font-[var(--font-weight-semibold)] mb-2">Frontend</h2>
            <p className="text-sm text-[var(--color-muted-foreground)]">
              Next.js with TypeScript and shadcn/ui
            </p>
          </div>
          <div className="rounded-[var(--radius-lg)] border border-[var(--color-border)] p-6 bg-[var(--color-surface)] shadow-[var(--shadow-sm)]">
            <h2 className="text-xl font-[var(--font-weight-semibold)] mb-2">Backend</h2>
            <p className="text-sm text-[var(--color-muted-foreground)]">
              FastAPI - API running at http://localhost:8000
            </p>
          </div>
        </div>
      </main>
    </div>
  );
}
