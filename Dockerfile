FROM alpine:3.18

# Install required packages
RUN apk add --no-cache \
    bash \
    curl \
    openssl \
    util-linux \
    ca-certificates

# Create app directory and secrets directory
WORKDIR /app
RUN mkdir -p /etc/secrets

# Copy the shell script
COPY api-job.sh /app/api-job.sh

# Make script executable
RUN chmod +x /app/api-job.sh

# Create default secret files (will be overridden by Kubernetes secrets)
RUN echo "demo-consumer-123" > /etc/secrets/consumer_id-2.txt && \
    echo "demo-private-key" > /etc/secrets/private_key1.txt

# Set default environment variables
ENV exitCode=0

# Run the script
CMD ["/app/api-job.sh"]
