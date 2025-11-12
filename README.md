# 📸 Lab 8 — Evidence & Test Documentation

This document collects **screenshots and command outputs** proving that the PostgreSQL StatefulSet setup works as expected in Lab 8.

Each subsection below corresponds to one verification step.

---

## 🧩 1. Pod Naming Stability

### 📄 Description
Verify that after deleting a PostgreSQL pod, the **pod name remains the same** (e.g., `postgres-0`).

### ✅ Commands
```bash
kubectl get pods -l app=postgres -o wide
kubectl delete pod postgres-0
kubectl wait --for=condition=Ready pod/postgres-0 --timeout=120s
kubectl get pods -l app=postgres -o wide
📸 Screenshots
pods-before.png → list of pods before deletion

pods-after.png → list of pods after recreation


![Pods before deletion](pods-before.png)
![Pods after recreation](pods-after.png)
💾 2. PVC Auto-Creation
📄 Description
Show that PVCs are automatically created per StatefulSet replica.

✅ Command

kubectl get pvc
📸 Screenshot
pvc-list.png → displays automatically created PVCs


![PVC Auto-Creation](pvc-list.png)
🌐 3. Stable DNS Entry Test
📄 Description
Confirm that each StatefulSet pod can be accessed via a stable DNS name.

✅ Command

kubectl run dns-test --rm -it --image=busybox --restart=Never -- nslookup postgres-0.postgres-headless.default.svc.cluster.local
📸 Screenshot
nslookup.png → shows DNS lookup result


![Stable DNS Lookup](nslookup.png)
🗃️ 4. Data Persistence Verification
📄 Description
Insert data into PostgreSQL, delete the pod, and confirm that the data still exists after recreation.

✅ Commands

kubectl exec -it postgres-0 -- psql -U labuser -d labdb -c "CREATE TABLE IF NOT EXISTS t_persist(id serial, msg text);"
kubectl exec -it postgres-0 -- psql -U labuser -d labdb -c "INSERT INTO t_persist(msg) VALUES('persist-test');"
kubectl exec -it postgres-0 -- psql -U labuser -d labdb -c "SELECT * FROM t_persist;"

kubectl delete pod postgres-0
kubectl wait --for=condition=Ready pod/postgres-0 --timeout=120s
kubectl exec -it postgres-0 -- psql -U labuser -d labdb -c "SELECT * FROM t_persist;"
📸 Screenshots
db-before.png → before deletion

db-after.png → after deletion (data persists)


![Data before deletion](db-before.png)
![Data after recreation](db-after.png)
⚙️ 5. Scaling Behavior
📄 Description
Demonstrate how scaling up the StatefulSet creates new pods and PVCs in order.

✅ Commands

kubectl scale statefulset postgres --replicas=3
kubectl get pods -l app=postgres -w
kubectl get pvc
📸 Screenshots
scale-pods.png → sequential creation of pods (postgres-0, postgres-1, postgres-2)

scale-pvcs.png → new PVCs created (postgres-data-postgres-1, etc.)

![Scaling Pods](scale-pods.png)
![Scaling PVCs](scale-pvcs.png)
📊 6. Summary Table
Test	Description	Result
Pod Naming Stability	Pod keeps same name after restart	✅
PVC Auto-Creation	PVCs created automatically per pod	✅
Stable DNS	DNS entry points to same pod	✅
Data Persistence	Data remains after pod restart	✅
Scaling Behavior	Sequential creation of pods/PVCs	✅

🧠 Notes & Observations
The StatefulSet ensures predictable pod identities, unlike Deployments.

PVCs remain bound even after pod deletion, ensuring durable storage.

Headless service enables stable DNS for inter-pod communication.

Scaling behavior is ordered — safer for databases.

This architecture is now production-ready for PostgreSQL workloads.

Author: WajdiTech
Course: Kubernetes Labs – Lab 8
Date: 2025-11


