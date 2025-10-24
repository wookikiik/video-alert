import type { Metadata } from "next";
import "./globals.css";

export const metadata: Metadata = {
  title: "Video Alert",
  description: "Video Alert application built with Next.js and FastAPI",
};

export default function RootLayout({
  children,
}: Readonly<{
  children: React.ReactNode;
}>) {
  return (
    <html lang="en">
      <body className="antialiased">
        {children}
      </body>
    </html>
  );
}
