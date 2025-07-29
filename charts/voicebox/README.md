Voicebox Helm Chart
==================

This chart installs Stardog Voicebox, an AI-powered conversational interface service for Stardog Knowledge Graph. Voicebox enables natural language interactions with your knowledge graph data.

Chart Details
-------------

This chart does the following:

- Deploys the Voicebox service as a Kubernetes Deployment
- Creates a ConfigMap for Voicebox configuration
- Creates a Service to expose the Voicebox API
- Configures environment variables for LLM integration
- Sets up security contexts for secure container execution

Configuration Parameters
------------------------

| Parameter                                    | Description |
| ---                                          | --- |
| `enabled`                                    | Enable or disable the Voicebox deployment |
| `replicaCount`                               | Number of Voicebox replicas to deploy |
| `logLevel`                                   | Log level for Voicebox service (DEBUG, INFO, WARNING, ERROR) |
| `securityContext.seccompProfile.type`        | Seccomp profile type for the pod |
| `securityContext.runAsNonRoot`               | Run containers as non-root user |
| `securityContext.runAsUser`                  | UID to run the container as |
| `securityContext.runAsGroup`                 | GID to run the container as |
| `securityContext.fsGroup`                    | GID for volume mounts |
| `containerSecurityContext.allowPrivilegeEscalation` | Allow privilege escalation |
| `containerSecurityContext.readOnlyRootFilesystem` | Mount root filesystem as read-only |
| `service.type`                               | Kubernetes service type (ClusterIP, LoadBalancer, NodePort) |
| `service.port`                               | Port to expose the Voicebox service |
| `service.loadBalancerIP`                     | Static IP for LoadBalancer service type |
| `service.annotations`                        | Additional service annotations |
| `image.registry`                             | Docker registry for Voicebox image |
| `image.repository`                           | Docker repository for Voicebox image |
| `image.tag`                                  | Docker image tag for Voicebox |
| `image.pullPolicy`                           | Image pull policy (Always, IfNotPresent, Never) |
| `image.username`                             | Docker registry username |
| `image.password`                             | Docker registry password |
| `image.pullSecrets`                          | List of image pull secret names |
| `configFile`                                 | Voicebox configuration JSON content |
| `environmentVariables.AZURE_API_KEY`         | Azure API key for LLM integration |
| `environmentVariables.PRODUCTION`            | Production mode flag (0 for development, 1 for production) |
| `resources`                                  | Resource requests and limits for Voicebox container |
| `nodeSelector`                               | Node selector for pod scheduling |
| `affinity`                                   | Pod affinity rules |
| `tolerations`                                | Pod tolerations for node taints |

Voicebox Configuration
----------------------

The `configFile` parameter accepts a JSON configuration that controls Voicebox behavior. Full documentation for this file can be found in [the Launchpad Documentation](https://github.com/stardog-union/launchpad-docs/blob/main/voicebox.md#voicebox-configuration-file).

Installation
------------

To install Voicebox with default settings:

```bash
helm install voicebox ./charts/voicebox --namespace stardog
```

To install with custom configuration:

```bash
helm install voicebox ./charts/voicebox \
  --namespace stardog \
  --set image.username=<your-username> \
  --set image.password=<your-password> \
  --set environmentVariables.AZURE_API_KEY=<your-api-key>
```

Or create a custom values file:

```yaml
# voicebox-values.yaml
image:
  username: your-username
  password: your-password

environmentVariables:
  AZURE_API_KEY: your-azure-api-key

configFile: |
  {
    "agent_selection_type": "llm",
    "enable_lineage": true,
    "enable_external_llm": true,
    "enable_analytics": true,
    "enable_charts": true,
    "use_agents_automatically": false,
    "default_llm_config": {
      "llm_provider": "azure",
      "llm_name": "Meta-Llama-3.1-70B-Instruct",
      "server_url": "https://your-model.services.ai.azure.com/models"
    }
  }

resources:
  limits:
    cpu: 2
    memory: 4Gi
  requests:
    cpu: 1
    memory: 2Gi
```

Then install:

```bash
helm install voicebox ./charts/voicebox \
  --namespace stardog \
  -f voicebox-values.yaml
```

Accessing Voicebox
------------------

Once deployed, Voicebox can be accessed through the Kubernetes service:

```bash
# For ClusterIP service type (within cluster)
kubectl port-forward -n stardog svc/voicebox-voicebox 8080:8080

# Then access at http://localhost:8080
```

For production deployments, consider using a LoadBalancer service type or configuring an Ingress controller.

Requirements
------------

- Stardog instance accessible from the Voicebox service
- Valid LLM provider credentials (e.g., Azure API key)
- Docker registry credentials to pull the Voicebox image
- Kubernetes cluster with appropriate RBAC permissions

Troubleshooting
---------------

### Check Voicebox logs:
```bash
kubectl logs -n stardog deployment/voicebox-voicebox
```

### Verify configuration:
```bash
kubectl describe configmap -n stardog voicebox-voicebox
```

### Check service endpoints:
```bash
kubectl get endpoints -n stardog voicebox-voicebox
```
