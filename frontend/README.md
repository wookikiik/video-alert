# Video Alert Frontend

Next.js frontend for Video Alert application with shadcn/ui components.

## Setup

1. Install dependencies:
```bash
npm install
```

2. Run the development server:
```bash
npm run dev
```

3. Open [http://localhost:3000](http://localhost:3000) in your browser.

## Build

```bash
npm run build
npm start
```

## Tech Stack

- **Next.js 16** - React framework with App Router
- **TypeScript** - Type safety
- **Tailwind CSS v4** - Utility-first CSS framework
- **shadcn/ui** - Re-usable components built with Radix UI and Tailwind CSS

## Project Structure

```
frontend/
├── src/
│   ├── app/            # App Router pages
│   ├── components/     # React components
│   └── lib/           # Utility functions
├── public/            # Static assets
└── package.json       # Dependencies
```

## API Integration

The frontend connects to the FastAPI backend at `http://localhost:8000`.
