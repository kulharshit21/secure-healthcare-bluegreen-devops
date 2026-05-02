# JENKINS_DEMO_SETUP

This document explains how to demonstrate Jenkins safely on a Windows + Docker Desktop + Minikube setup without breaking the already working local blue-green runtime.

`Jenkinsfile.demo` is now cross-platform:
- uses `isUnix()` to choose `sh` (Linux/macOS agents) or `bat` (Windows agents)
- works for both Windows Jenkins service and Linux-based Jenkins Docker agents

## Option A: Jenkins on Windows Service (Recommended for this project)

1. Install Jenkins LTS (Windows installer).
2. Open `http://localhost:8080`.
3. Unlock Jenkins using the initial admin password.
4. Install suggested plugins.
5. Create a new **Pipeline** job.
6. Configure one of these:
   - **Pipeline script from SCM** (if repo is on GitHub), script path: `Jenkinsfile.demo`
   - **Pipeline script** and paste `Jenkinsfile.demo` content directly.
7. Click **Build Now**.
8. Capture screenshots of stage execution and test output.

## Option B: Jenkins in Docker (Linux runtime)

Use port `9090` so it does not conflict with Kubernetes service port-forward on `8080`.

```powershell
docker volume create jenkins_home
docker run -d --name jenkins -p 9090:8080 -p 50000:50000 -v jenkins_home:/var/jenkins_home jenkins/jenkins:lts
```

Open:
- `http://localhost:9090`

Get initial password:

```powershell
docker exec jenkins cat /var/jenkins_home/secrets/initialAdminPassword
```

Important warning:
- The official Jenkins Docker image may not include Python, Docker CLI, kubectl, Minikube, or Trivy by default.
- So Option B may require extra agent/tooling setup.
- For many viva demos, Option B is best used to prove Jenkins UI + pipeline configuration.
- Note: this is exactly why a bat-only pipeline would fail in Docker Jenkins; `Jenkinsfile.demo` avoids that by being cross-platform.

## Option C: Best viva explanation (most reliable)

1. Show `Jenkinsfile.demo` running checkout + dependency + pytest stages.
2. Show manual runtime proof screenshots for Docker/Kubernetes/Trivy.
3. Explain that `Jenkinsfile` is the full intended automation flow for a fully configured Jenkins agent.

## Full Jenkinsfile vs Jenkinsfile.demo

- `Jenkinsfile`:
  - Intended complete CI/CD automation in a properly configured environment.
  - Includes build, scan, push, deploy, smoke test, switch, and verification logic.

- `Jenkinsfile.demo`:
  - Safe local pipeline for viva.
  - Uses Windows-friendly `bat` steps.
  - Does not fail whole build if Docker/kubectl/Trivy are unavailable in Jenkins agent.
  - Marks optional tool stages as **UNSTABLE** instead of failing.

- Manual runtime verification (already done):
  - Minikube blue-green deployment, traffic switch/rollback, Trivy, and security checks verified via terminal.
