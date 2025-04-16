#!/bin/bash

# Define color codes
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

echo -e "${RED}🧹 Removing all Kubernetes resources for the cab service...${NC}"

# Remove Ingress first
echo -e "${PURPLE}🚪 Removing Ingress...${NC}"
kubectl delete -f k8s/ingress.yaml --ignore-not-found=true

# Remove API Gateway
echo -e "${PURPLE}🔀 Removing API Gateway...${NC}"
kubectl delete -f k8s/api-gateway.yaml --ignore-not-found=true

# Remove application services
echo -e "${GREEN}📅 Removing Booking Service...${NC}"
kubectl delete -f k8s/booking-service.yaml --ignore-not-found=true

echo -e "${GREEN}🚗 Removing Driver Service...${NC}"
kubectl delete -f k8s/driver-service.yaml --ignore-not-found=true

echo -e "${GREEN}👤 Removing User Service...${NC}"
kubectl delete -f k8s/user-service.yaml --ignore-not-found=true

# Remove infrastructure services
echo -e "${CYAN}🐰 Removing RabbitMQ...${NC}"
kubectl delete -f k8s/rabbitmq.yaml --ignore-not-found=true

echo -e "${CYAN}🔄 Removing Redis...${NC}"
kubectl delete -f k8s/redis.yaml --ignore-not-found=true

echo -e "${CYAN}🗄️  Removing PostgreSQL...${NC}"
kubectl delete -f k8s/postgres.yaml --ignore-not-found=true

# Remove application secrets
echo -e "${PURPLE}🔐 Removing application secrets...${NC}"
kubectl delete -f k8s/app-secrets.yaml --ignore-not-found=true

# Optional: remove all resources with a specific label if you added one
# echo -e "${YELLOW}🏷️  Removing any remaining resources with app=cab-service label...${NC}"
# kubectl delete all -l app=cab-service

echo -e "${GREEN}✅ Cleanup complete.${NC} You can verify with: ${BLUE}kubectl get all${NC}"