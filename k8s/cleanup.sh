#!/bin/bash

echo "Removing all Kubernetes resources for the cab service..."

# Remove Ingress first
echo "Removing Ingress..."
kubectl delete -f k8s/ingress.yaml --ignore-not-found=true

# Remove API Gateway
echo "Removing API Gateway..."
kubectl delete -f k8s/istio.yaml --ignore-not-found=true

# Remove application services
echo "Removing Booking Service..."
kubectl delete -f k8s/booking-service.yaml --ignore-not-found=true

echo "Removing Driver Service..."
kubectl delete -f k8s/driver-service.yaml --ignore-not-found=true

echo "Removing User Service..."
kubectl delete -f k8s/user-service.yaml --ignore-not-found=true

# Remove infrastructure services
echo "Removing RabbitMQ..."
kubectl delete -f k8s/rabbitmq.yaml --ignore-not-found=true

echo "Removing Redis..."
kubectl delete -f k8s/redis.yaml --ignore-not-found=true

echo "Removing PostgreSQL..."
kubectl delete -f k8s/postgres.yaml --ignore-not-found=true

# Optional: remove all resources with a specific label if you added one
# echo "Removing any remaining resources with app=cab-service label..."
# kubectl delete all -l app=cab-service

echo "Cleanup complete. You can verify with: kubectl get all"