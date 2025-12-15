/** @type {import('tailwindcss').Config} */
export default {
    content: [
        "./index.html",
        "./src/**/*.{js,ts,jsx,tsx}",
    ],
    theme: {
        extend: {
            colors: {
                // "Professional Warmth" Palette
                background: '#FAFAF9', // Stone 50
                surface: '#FFFFFF',
                primary: {
                    light: '#5EEAD4', // Teal 300
                    DEFAULT: '#14B8A6', // Teal 500
                    dark: '#0F766E', // Teal 700
                },
                secondary: {
                    light: '#94A3B8', // Slate 400
                    DEFAULT: '#64748B', // Slate 500
                    dark: '#334155', // Slate 700
                },
                text: {
                    main: '#1E293B', // Slate 800
                    muted: '#64748B', // Slate 500
                },
                accent: '#F59E0B', // Amber 500 (for subtle highlights)
            },
            fontFamily: {
                sans: ['Inter', 'system-ui', 'sans-serif'],
            }
        },
    },
    plugins: [],
}
