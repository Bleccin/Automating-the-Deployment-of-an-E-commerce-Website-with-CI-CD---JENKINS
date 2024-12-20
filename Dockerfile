# Use a suitable base image for your application.
# For a Node.js application, use a Node.js base image.
FROM node:16-alpine

# Set the working directory inside the container.
WORKDIR /app

# Copy package.json and package-lock.json (if available) first for caching.
COPY package*.json ./

# Install application dependencies.
RUN npm install

# Copy the rest of the application code.
COPY . .

# Expose the port your application listens on.
EXPOSE 8081

# Define the command to start your application.
CMD ["npm", "start"]
