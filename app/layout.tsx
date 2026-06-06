import React from 'react';
import './globals.css';

export const metadata = {
  title: 'RepFiles - Reptile Management App',
  description: 'A Progressive Web App for managing reptile collections, breeding projects, schedules, and inventory.',
};

export default function RootLayout({
  children,
}: {
  children: React.ReactNode;
}) {
  return (
    <html lang="en">
      <head>
        <link
          href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0/css/all.min.css"
          rel="stylesheet"
        />
      </head>
      <body>
        {children}
      </body>
    </html>
  );
}
