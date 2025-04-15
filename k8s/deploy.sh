#!/bin/bash

# Deploy infrastructure services first
echo "Deploying PostgreSQL..."
kubectl apply -f k8s/postgres.yaml
echo "Waiting for PostgreSQL to start..."
kubectl wait --for=condition=available --timeout=90s deployment/postgres

echo "Deploying Redis..."
kubectl apply -f k8s/redis.yaml
echo "Waiting for Redis to start..."
kubectl wait --for=condition=available --timeout=60s deployment/redis

echo "Deploying RabbitMQ..."
kubectl apply -f k8s/rabbitmq.yaml
echo "Waiting for RabbitMQ to start..."
kubectl wait --for=condition=available --timeout=90s deployment/rabbitmq

# Deploy application services after dependencies are ready
echo "Deploying User Service..."
kubectl apply -f k8s/user-service.yaml

echo "Deploying Driver Service..."
kubectl apply -f k8s/driver-service.yaml

echo "Deploying Booking Service..."
kubectl apply -f k8s/booking-service.yaml

# Deploy API Gateway
echo "Deploying API Gateway..."
kubectl apply -f k8s/istio.yaml
echo "Waiting for API Gateway to start..."
kubectl wait --for=condition=available --timeout=60s deployment/api-gateway

# Deploy Ingress last
echo "Deploying Ingress..."
kubectl apply -f k8s/ingress.yaml

echo "Deployment complete. Services may take a few moments to become fully ready."
echo "You can check the status with: kubectl get pods"