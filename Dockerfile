FROM node:24.4-alpine3.21

WORKDIR /app

# Copy dependency files first to leverage Docker layer caching
COPY package.json yarn.lock ./

# Install dependencies (and optionally clean yarn cache)
RUN yarn install && yarn cache clean

# Copy remaining source code
COPY . .

# Expose the port your app uses (adjust if needed)
EXPOSE ${CONTAINER_PORT}

# Start the app
CMD ["yarn", "server"]
