# Reusable Deployment Workflow

This directory contains a reusable GitHub Actions workflow template that supports both frontend (GCS static site) and backend (Cloud Run) deployments from a single workflow definition.

## Overview

The `_reusable-deploy.yml` workflow provides a standardized deployment pipeline that can be called from thin caller workflows. It supports:

- **Frontend deployments** to Google Cloud Storage (GCS) as static sites
- **Backend deployments** to Google Cloud Run as containerized services
- **Environment-based deployments** (development, staging, production)
- **Artifact promotion** flow between environments
- **Dependency caching** for faster builds
- **Concurrency control** to prevent deployment conflicts

## Workflow Structure

### Jobs

1. **validate-inputs**: Validates deployment type and required parameters
2. **build**: Builds the application and creates deployment artifacts
3. **deploy**: Deploys the built artifacts to the target platform

### Key Features

- **Separated build and deploy stages** for better modularity
- **Artifact promotion** using GitHub Actions artifacts
- **Dependency caching** for Node.js (npm) and Python (pip)
- **Concurrency groups** that cancel outdated runs
- **Environment-specific deployments** with proper GitHub environments
- **Input validation** with clear error messages

## Usage

### Required Inputs

| Input | Description | Required |
|-------|-------------|----------|
| `environment` | Target environment (e.g., development, staging, production) | Yes |
| `deployment_type` | Type of deployment: `frontend` or `backend` | Yes |
| `app_path` | Path to the application directory (e.g., `frontend`, `backend`) | Yes |
| `artifact_name` | Name for the build artifact (e.g., `frontend-build`, `backend-app`) | Yes |

### Optional Inputs

| Input | Description | Default |
|-------|-------------|---------|
| `gcp_project_id` | GCP Project ID | - |
| `gcs_bucket_name` | GCS bucket name for frontend deployment | - |
| `cloud_run_service_name` | Cloud Run service name for backend deployment | - |
| `cloud_run_region` | Cloud Run region | `us-central1` |

### Required Secrets

Configure these secrets in your GitHub repository or organization:

| Secret | Description |
|--------|-------------|
| `GCP_WORKLOAD_IDENTITY_PROVIDER` | GCP workload identity provider for authentication |
| `GCP_SERVICE_ACCOUNT_EMAIL` | Service account email with deployment permissions |

## Example Caller Workflows

### Frontend Deployment

```yaml
name: Deploy Frontend
on:
  push:
    branches: [main]
    paths: ['frontend/**']

jobs:
  deploy:
    uses: ./.github/workflows/_reusable-deploy.yml
    with:
      environment: production
      deployment_type: frontend
      app_path: frontend
      artifact_name: frontend-build
      gcp_project_id: my-project
      gcs_bucket_name: my-frontend-bucket
    secrets: inherit
```

### Backend Deployment

```yaml
name: Deploy Backend
on:
  push:
    branches: [main]
    paths: ['backend/**']

jobs:
  deploy:
    uses: ./.github/workflows/_reusable-deploy.yml
    with:
      environment: production
      deployment_type: backend
      app_path: backend
      artifact_name: backend-app
      gcp_project_id: my-project
      cloud_run_service_name: my-api
      cloud_run_region: us-central1
    secrets: inherit
```

### Multi-Environment Deployment

```yaml
name: Deploy to Staging
on:
  push:
    branches: [develop]

jobs:
  deploy-frontend:
    uses: ./.github/workflows/_reusable-deploy.yml
    with:
      environment: staging
      deployment_type: frontend
      app_path: frontend
      artifact_name: frontend-staging
      gcp_project_id: my-project
      gcs_bucket_name: my-staging-bucket
    secrets: inherit

  deploy-backend:
    uses: ./.github/workflows/_reusable-deploy.yml
    with:
      environment: staging
      deployment_type: backend
      app_path: backend
      artifact_name: backend-staging
      gcp_project_id: my-project
      cloud_run_service_name: my-api-staging
      cloud_run_region: us-central1
    secrets: inherit
```

## Deployment Process

### Frontend (GCS Static Site)

1. **Build**: Installs npm dependencies and builds the frontend application
2. **Artifact**: Creates an artifact with the built files
3. **Deploy**: Syncs files to GCS bucket and configures website settings
4. **Access**: Makes files publicly accessible via GCS

### Backend (Cloud Run)

1. **Build**: Installs Python dependencies and builds Docker image
2. **Artifact**: Exports Docker image as tar file
3. **Deploy**: Pushes to Artifact Registry and deploys to Cloud Run
4. **Configure**: Sets environment variables and makes service publicly accessible

## Permissions

The workflow requires the following GitHub permissions:

```yaml
permissions:
  contents: read          # Read repository contents
  id-token: write         # OIDC authentication for GCP
  deployments: write      # Deploy to environments
```

## Concurrency

The workflow uses concurrency groups to prevent multiple deployments of the same type to the same environment:

- **Group pattern**: `deploy-{environment}-{deployment_type}`
- **Behavior**: Cancels in-progress runs when new deployment starts

## Environment Protection

The workflow integrates with GitHub Environments for:

- **Deployment protection rules**
- **Environment-specific secrets**
- **Required approvals**
- **Environment-specific variables**

## Error Handling

The workflow includes comprehensive validation:

- **Input validation**: Checks for required parameters based on deployment type
- **Build validation**: Ensures successful builds before deployment
- **Deploy validation**: Verifies successful deployment completion

## Monitoring and Logs

- **Build logs**: Detailed output for dependency installation and build processes
- **Deploy logs**: GCP deployment commands and results
- **Status updates**: Emoji-rich status updates with deployment URLs
- **Artifact retention**: 30-day retention for build artifacts

## Best Practices

1. **Use specific versions**: Pin dependency versions for reproducible builds
2. **Environment separation**: Use different buckets/services for each environment
3. **Security**: Follow least privilege principle for service accounts
4. **Monitoring**: Set up monitoring and alerting for deployed services
5. **Rollback**: Keep previous versions for quick rollback capability

## Troubleshooting

### Common Issues

1. **Authentication failures**: Check GCP workload identity configuration
2. **Permission errors**: Verify service account has required permissions
3. **Build failures**: Check dependency paths and versions
4. **Deploy conflicts**: Ensure proper concurrency group configuration

### Debug Steps

1. Check workflow logs for specific error messages
2. Verify input parameters match requirements
3. Confirm GCP resources exist and are properly configured
4. Validate secret configuration in GitHub repository
