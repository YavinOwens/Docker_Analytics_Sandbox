/** @type {import('tailwindcss').Config} */
module.exports = {
  content: [
    "./src/**/*.{js,jsx,ts,tsx}",
  ],
  theme: {
    extend: {
      colors: {
        'databricks-blue': '#0066CC',
        'databricks-light-blue': '#E6F2FF',
        'databricks-dark-blue': '#004C99',
        'databricks-gray': '#F5F5F5',
        'databricks-dark-gray': '#333333'
      }
    },
  },
  plugins: [],
} 