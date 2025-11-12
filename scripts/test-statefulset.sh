#!/bin/bash
# ============================================
# 🧪 Lab 8 - Test Script for PostgreSQL StatefulSet
# ============================================

echo "🚀 Starting StatefulSet verification tests..."

# --------------------------------------------
# 1️⃣ Pod Naming Stability
# --------------------------------------------
echo "🔹 Checking current PostgreSQL pods..."
kubectl get pods -l app=postgres

echo "🔹 Deleting postgres-0 to test naming stability..."
kubectl delete pod postgres-0 --grace-period=0 --force

echo "⏳ Waiting for postgres-0 to be recreated..."
kubectl wait --for=condition=Ready pod/postgres-0 --timeout=120s

echo "✅ Pod recreated. Verifying name stability..."
kubectl get pods -l app=postgres -o wide

# --------------------------------------------
# 2️⃣ Stable DNS Entry
# --------------------------------------------
echo "🔹 Testing stable DNS entry for postgres-0..."
kubectl run dns-test --rm -it --image=busybox --restart=Never -- nslookup postgres-0.postgres-headless.default.svc.cluster.local

# --------------------------------------------
# 3️⃣ Data Persistence Test
# --------------------------------------------
echo "🔹 Creating test database and table..."
kubectl exec -it postgres-0 -- psql -U labuser -d labdb -c "CREATE TABLE IF NOT EXISTS test (id SERIAL PRIMARY KEY, message TEXT);"
kubectl exec -it postgres-0 -- psql -U labuser -d labdb -c "INSERT INTO test (message) VALUES ('Hello StatefulSet!');"
kubectl exec -it postgres-0 -- psql -U labuser -d labdb -c "SELECT * FROM test;"

echo "🔹 Deleting pod to test data persistence..."
kubectl delete pod postgres-0 --grace-period=0 --force

echo "⏳ Waiting for pod to come back..."
kubectl wait --for=condition=Ready pod/postgres-0 --timeout=120s

echo "✅ Checking if data persisted..."
kubectl exec -it postgres-0 -- psql -U labuser -d labdb -c "SELECT * FROM test;"

# --------------------------------------------
# 4️⃣ Volume Management
# --------------------------------------------
echo "🔹 Checking PVCs created automatically..."
kubectl get pvc -l app=postgres

# --------------------------------------------
# 5️⃣ Scaling Behavior
# --------------------------------------------
echo "🔹 Scaling StatefulSet to 3 replicas..."
kubectl scale statefulset postgres --replicas=3

echo "⏳ Waiting for pods to start sequentially..."
kubectl rollout status statefulset/postgres --timeout=180s

kubectl get pods -l app=postgres -o wide
kubectl get pvc -l app=postgres

echo "🔹 Scaling back to 1 replica..."
kubectl scale statefulset postgres --replicas=1
kubectl rollout status statefulset/postgres --timeout=180s

echo "✅ StatefulSet tests completed successfully!"

