# FINAL_VIVA_QA_CHEATSHEET

## 1) What is the project?
This project implements a secure CI/CD workflow for a Dockerized healthcare API using Jenkins and Kubernetes blue-green deployment. It demonstrates testing, controlled rollout, rollback, and security checks. The setup is optimized for local Minikube demo with production-style practices.

## 2) How does it cover all 3 assignment topics?
It covers Jenkins CI/CD with `Jenkinsfile` and `Jenkinsfile.demo`, Dockerized app deployment on Kubernetes, and blue-green switch/rollback. Security is integrated through Secrets, RBAC, non-root runtime, probes, and Trivy scan evidence.

## 3) What is blue-green deployment?
Blue-green means running two versions in parallel: blue (current) and green (new). Traffic switches by changing the service selector. This reduces risk because rollback is immediate.

## 4) Why is blue-green safer than direct deployment?
Direct deployment replaces running pods in-place, so failures can impact users immediately. Blue-green lets us test green first, then switch traffic only when validated. Rollback is a selector change, not a rebuild.

## 5) How does Kubernetes switch traffic?
By patching the `healthcare-service` selector from `version=blue` to `version=green`. Kubernetes service endpoints update to the selected pods. Same process in reverse handles rollback.

## 6) What is the role of Jenkins?
Jenkins orchestrates CI/CD stages: checkout, environment check, dependency install, tests, and optional deployment-related checks. In this project, Jenkins demo pipeline proves CI execution while host terminal proves full runtime CD.

## 7) Why did Jenkins Docker skip Docker/kubectl/Trivy?
The official Jenkins Docker image is isolated and does not automatically include host CLIs. So those stages are intentionally optional in `Jenkinsfile.demo`. They are skipped cleanly without failing the build.

## 8) Is Jenkins still used?
Yes. Jenkins demo run succeeds and proves pipeline execution. It validates source pull, virtualenv creation, dependency install, and tests. Full host runtime proof complements Jenkins in viva.

## 9) What was runtime verified manually?
Docker build/run, Minikube deployment, blue-green switch and rollback, service responses, Trivy execution, and non-root UID/GID hardening were all verified from host terminal with command outputs.

## 10) What security features are implemented?
Kubernetes Secrets, RBAC with service account, non-root container UID/GID 1000, readiness/liveness/startup probes, resource limits, and Trivy vulnerability scanning evidence are included.

## 11) What is Trivy?
Trivy is a container vulnerability scanner. It checks OS packages and language dependencies for known CVEs. It is used here to demonstrate DevSecOps integration in the pipeline.

## 12) What did Trivy find?
Trivy reported HIGH findings and 0 CRITICAL findings in the demo images. This provides concrete security scanning proof. Findings are documented as part of evidence.

## 13) Why are HIGH findings acceptable for demo?
For assignment demo, the objective is to prove scanning integration and reporting. Production policy could gate builds by severity thresholds and require remediation timelines. So we show scan evidence honestly.

## 14) Why use Kubernetes Secrets?
Secrets avoid hardcoding sensitive values in source/manifests. They centralize sensitive config and reduce accidental exposure. The app consumes secrets through environment variables.

## 15) Why use RBAC?
RBAC enforces least privilege for service accounts. It limits what workloads can do in the namespace. This reduces blast radius if a pod is compromised.

## 16) Why run container as non-root?
Running as non-root reduces privilege escalation risk and limits impact of runtime compromise. Here, both uid and gid are hardened to 1000. This is a core container security baseline.

## 17) What is readiness probe?
Readiness probe tells Kubernetes when a pod can safely receive traffic. If it fails, the service stops routing requests to that pod. It protects user experience during startup and failures.

## 18) What is liveness probe?
Liveness probe detects hung or unhealthy pods and triggers restart. It improves self-healing behavior. Combined with readiness, it supports resilient service operation.

## 19) How is rollback done?
Rollback is done by patching service selector back to blue. After selector update, traffic returns to stable blue pods. It is fast and avoids redeploying older image during incident.

## 20) What are the limitations?
Jenkins Docker agent lacks host CLIs by default, Minikube is single-node local, data is dummy healthcare data, and HIGH vulnerabilities remain. These are documented clearly for transparency.

## 21) What would you improve in production?
Use dedicated Jenkins agents with Docker/kubectl/trivy, enforce scan gates, move secrets to vault, deploy on managed multi-node Kubernetes, add monitoring/alerts, and automate progressive delivery with policy checks.
