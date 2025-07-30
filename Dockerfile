# Use a lightweight official Node.js image
FROM node:24.4-alpine3.21

# Define environment variable defaults (optional but useful for fallback)
ENV CONTAINER_PORT=5000

# Set working directory
WORKDIR /app

# Copy only package manifests first for better caching
COPY package.json yarn.lock ./

# Install dependencies conditionally based on NODE_ENV
RUN if [ "$NODE_ENV" = "dev" ]; then \
      yarn install; \
    else \
      yarn install --production; \
    fi && \
    yarn cache clean

# Copy rest of the application
COPY . .

# Install nodemon globally for dev use
RUN yarn global add nodemon

# Expose port for runtime (can be overridden via --env-file or docker-compose)
EXPOSE ${CONTAINER_PORT}

# Start app with nodemon
CMD ["nodemon"]
