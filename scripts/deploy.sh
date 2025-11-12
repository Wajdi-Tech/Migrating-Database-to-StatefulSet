#!/bin/bash
set -e

echo "🚀 Deploying Lab 8 - Stateful PostgreSQL Setup..."

cd "$(dirname "$0")/../k8s"

kubectl apply -f db-configmap.yaml
kubectl apply -f db-secret.yaml
kubectl apply -f postgres-headless-service.yaml
kubectl apply -f postgres-service.yaml
kubectl apply -f postgres-statefulset.yaml
kubectl apply -f web-deployment.yaml
kubectl apply -f web-service.yaml

echo "⏳ Waiting for StatefulSet to be ready..."
kubectl rollout status statefulset/postgres

echo "✅ Checking pods..."
kubectl get pods -o wide

echo "✅ Checking PVCs..."
kubectl get pvc

echo "✅ All components deployed successfully!"

