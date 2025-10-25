import type { Metadata } from "next";
import "./globals.css";
import { Toaster } from "@/components/ui/sonner";
import { SidebarProvider, SidebarTrigger } from "@/components/ui/sidebar";
import { AppSidebar } from "@/components/app-sidebar";

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
        <SidebarProvider>
          <AppSidebar />
          <main className="w-full">
            <header className="sticky top-0 z-10 flex h-14 items-center gap-4 border-b bg-background px-4">
              <SidebarTrigger />
            </header>
            {children}
          </main>
        </SidebarProvider>
        <Toaster />
      </body>
    </html>
  );
}
