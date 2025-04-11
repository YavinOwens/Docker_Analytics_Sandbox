FROM node:16-alpine

WORKDIR /app

COPY package*.json ./

RUN npm install

COPY . .

# Install Tailwind CSS properly but skip the init step
# We'll rely on the existing tailwind config files
RUN npm install -D tailwindcss postcss autoprefixer

# Build for production or use development server
EXPOSE 3000

CMD ["npm", "start"] 