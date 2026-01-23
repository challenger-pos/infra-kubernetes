# infra-kubernetes — Terraform para EKS

Este repositório contém a infraestrutura como código (Terraform) responsável por provisionar a base Kubernetes necessária para o Tech Challenge.

Principais objetivos:
- Provisionar infra reprodutível para execução da aplicação principal em Kubernetes.
- Expor outputs usados pelos repositórios de aplicação e funções serverless.
- Fornecer pontos de integração para CI/CD, monitoramento e monitoramento de logs.

## O que este repositório cria
- Pasta no backend remoto (S3) para o state do Terraform.
- VPC, subnets públicas e privadas, route tables e security groups.
- Cluster EKS e node groups gerenciados.
- Add-ons e integrações via Terraform/Helm (AWS LB Controller, EBS CSI, Metrics Server, Cluster Autoscaler) — implementados nos módulos em [infra/terraform](infra/terraform).

## Premissas e pré-requisitos
- AWS CLI autenticado (perfil ou variáveis de ambiente com permissão para EKS/VPC/IAM/S3/DynamoDB).
- Terraform v1.0+ instalado.
- `kubectl` disponível localmente ou no runner CI para validação.
- Conta AWS com cotas suficientes (EC2, EBS, ELB).

## Estrutura relevante
- Código Terraform: [infra/terraform](infra/terraform)
- Workflows de CI (exemplo): [.github/workflows/ci-cd-kubernetes.yml](.github/workflows/ci-cd-kubernetes.yml)

## Como aplicar (fluxo recomendado)
1. Ajuste `variables.tf` conforme desejado.
2. Inicialize e aplique:

```bash
cd infra/terraform
terraform init
terraform plan
terraform apply 
```

3. Após `apply`, atualize o `kubeconfig` para usar o cluster provisionado:

```bash
aws eks --region <region> update-kubeconfig --name <cluster_name>
kubectl get nodes
```

Observação: o backend remoto é configurado em [infra/terraform/backend.tf](infra/terraform/backend.tf). Certifique-se de que o bucket S3 esteja acessível ao executor do Terraform.

## Variáveis sensíveis e CI/CD
- Guarde credenciais em GitHub Secrets. Ex: `AWS_ACCESS_KEY_ID`, `AWS_SECRET_ACCESS_KEY` e `AWS_DEFAULT_REGION`.
- Nos pipelines, é usado `terraform init` com o backend configurado e executado `plan`/`apply` apenas a partir das branches protegidas (homologation/main) via workflows.

## Outputs importantes
- O módulo exporta (exemplos) `cluster_name`, `cluster_endpoint`, `cluster_ca`, ARNs de roles criadas, IDs de security groups e outputs para o AWS LB Controller. Consulte [infra/terraform/outputs.tf](infra/terraform/outputs.tf) para a lista completa.

