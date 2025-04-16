#!/bin/bash

# Define color codes
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# Build Docker images first
echo -e "${GREEN}🚀 Building Docker images...${NC}"
cd $(dirname "$0")/..

# Check if minikube is running
if command -v minikube &> /dev/null && minikube status &> /dev/null; then
  echo -e "${YELLOW}Using Minikube for image builds...${NC}"
  
  echo -e "${BLUE}👤 Checking User Service image...${NC}"
  if ! minikube image ls | grep -q "user-service:1.0.0"; then
    echo -e "${BLUE}Building User Service image directly in Minikube...${NC}"
    minikube image build -t user-service:1.0.0 ./user-service
  else
    echo -e "${GREEN}User Service image already exists in Minikube, skipping build${NC}"
  fi

  echo -e "${BLUE}🚗 Checking Driver Service image...${NC}"
  if ! minikube image ls | grep -q "driver-service:1.0.0"; then
    echo -e "${BLUE}Building Driver Service image directly in Minikube...${NC}"
    minikube image build -t driver-service:1.0.0 ./driver-service
  else
    echo -e "${GREEN}Driver Service image already exists in Minikube, skipping build${NC}"
  fi

  echo -e "${BLUE}📅 Checking Booking Service image...${NC}"
  if ! minikube image ls | grep -q "booking-service:1.0.0"; then
    echo -e "${BLUE}Building Booking Service image directly in Minikube...${NC}"
    minikube image build -t booking-service:1.0.0 ./booking-service
  else
    echo -e "${GREEN}Booking Service image already exists in Minikube, skipping build${NC}"
  fi
else
  # Fallback to regular Docker if minikube is not available
  echo -e "${BLUE}👤 Checking User Service image...${NC}"
  if [[ "$(docker images -q user-service:1.0.0 2> /dev/null)" == "" ]]; then
    echo -e "${BLUE}Building User Service image...${NC}"
    docker build -t user-service:1.0.0 ./user-service
  else
    echo -e "${GREEN}User Service image already exists, skipping build${NC}"
  fi

  echo -e "${BLUE}🚗 Checking Driver Service image...${NC}"
  if [[ "$(docker images -q driver-service:1.0.0 2> /dev/null)" == "" ]]; then
    echo -e "${BLUE}Building Driver Service image...${NC}"
    docker build -t driver-service:1.0.0 ./driver-service
  else
    echo -e "${GREEN}Driver Service image already exists, skipping build${NC}"
  fi

  echo -e "${BLUE}📅 Checking Booking Service image...${NC}"
  if [[ "$(docker images -q booking-service:1.0.0 2> /dev/null)" == "" ]]; then
    echo -e "${BLUE}Building Booking Service image...${NC}"
    docker build -t booking-service:1.0.0 ./booking-service
  else
    echo -e "${GREEN}Booking Service image already exists, skipping build${NC}"
  fi
fi

# Deploy secrets first
echo -e "${PURPLE}🔐 Deploying application secrets...${NC}"
kubectl apply -f k8s/app-secrets.yaml

# Deploy infrastructure services first
echo -e "${CYAN}🗄️  Deploying PostgreSQL...${NC}"
kubectl apply -f k8s/postgres.yaml
echo -e "${YELLOW}⏳ Waiting for PostgreSQL to start...${NC}"
kubectl wait --for=condition=available --timeout=90s deployment/postgres

echo -e "${CYAN}🔄 Deploying Redis...${NC}"
kubectl apply -f k8s/redis.yaml
echo -e "${YELLOW}⏳ Waiting for Redis to start...${NC}"
kubectl wait --for=condition=available --timeout=60s deployment/redis

echo -e "${CYAN}🐰 Deploying RabbitMQ...${NC}"
kubectl apply -f k8s/rabbitmq.yaml
echo -e "${YELLOW}⏳ Waiting for RabbitMQ to start...${NC}"
kubectl wait --for=condition=available --timeout=90s deployment/rabbitmq

# Deploy application services after dependencies are ready
echo -e "${GREEN}👤 Deploying User Service...${NC}"
kubectl apply -f k8s/user-service.yaml

echo -e "${GREEN}🚗 Deploying Driver Service...${NC}"
kubectl apply -f k8s/driver-service.yaml

echo -e "${GREEN}📅 Deploying Booking Service...${NC}"
kubectl apply -f k8s/booking-service.yaml

# Deploy API Gateway
echo -e "${PURPLE}🔀 Deploying API Gateway...${NC}"
kubectl apply -f k8s/api-gateway.yaml
echo -e "${YELLOW}⏳ Waiting for API Gateway to start...${NC}"
kubectl wait --for=condition=available --timeout=60s deployment/api-gateway

# Deploy Ingress last
echo -e "${PURPLE}🚪 Deploying Ingress...${NC}"
kubectl apply -f k8s/ingress.yaml

echo -e "${GREEN}✅ Deployment complete. Services may take a few moments to become fully ready.${NC}"
echo -e "${BLUE}ℹ️  You can check the status with: kubectl get pods${NC}"