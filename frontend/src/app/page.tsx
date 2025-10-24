export default function Home() {
  return (
    <div className="flex min-h-screen flex-col items-center justify-center p-8">
      <main className="flex flex-col items-center gap-8 max-w-2xl text-center">
        <h1 className="text-4xl font-bold tracking-tight">
          Video Alert
        </h1>
        <p className="text-lg text-neutral-600 dark:text-neutral-400">
          Welcome to Video Alert - A modern web application built with Next.js and FastAPI
        </p>
        <div className="flex flex-col gap-4 w-full max-w-md">
          <div className="rounded-lg border border-neutral-200 dark:border-neutral-800 p-6">
            <h2 className="text-xl font-semibold mb-2">Frontend</h2>
            <p className="text-sm text-neutral-600 dark:text-neutral-400">
              Next.js with TypeScript and shadcn/ui
            </p>
          </div>
          <div className="rounded-lg border border-neutral-200 dark:border-neutral-800 p-6">
            <h2 className="text-xl font-semibold mb-2">Backend</h2>
            <p className="text-sm text-neutral-600 dark:text-neutral-400">
              FastAPI - API running at http://localhost:8000
            </p>
          </div>
        </div>
      </main>
    </div>
  );
}
