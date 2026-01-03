# 📦 infra-kubernetes — Provisionamento de Kubernetes (AWS EKS)

Este diretório contém instruções e boas práticas para provisionar a infraestrutura Kubernetes na AWS (EKS) necessária para executar aplicações do repositório (ex.: `application`). Ele descreve dois fluxos: 1) fluxo rápido com `eksctl` e 2) fluxo recomendado e reproduzível com Terraform.

---

## 🚀 Objetivo

- Criar um cluster Kubernetes gerenciado (EKS) pronto para produção/ homologação.
- Instalar add-ons essenciais: AWS Load Balancer Controller, Metrics Server, Cluster Autoscaler, Cert-Manager, CSI Driver (EBS).
- Preparar permissões (IAM/IRSA), storage class e policies necessárias.
- Integrar com pipelines CI/CD e armazenar estado remoto (Terraform state em S3 com locking).

---

## ✨ Pré-requisitos

- AWS CLI configurado (com perfil ou variáveis de ambiente).
- `eksctl` (para fluxo rápido) e/ou Terraform (>= 1.0) para o fluxo reproduzível.
- `kubectl` para interagir com o cluster.
- Conta AWS com permissões para criar EKS, VPC, IAM, EC2, ECR, S3, DynamoDB.
- (Opcional) `helm` para instalar add-ons.

---

## ✅ Considerações de arquitetura

- Em produção, use VPC com subnets privadas e NAT Gateway para nós privados; ative endpoints VPC para serviços (S3/STS).
- Use roles e policies mínimas (least privilege) e prefira IRSA (IAM Roles for Service Accounts) para addons que precisam de permissões AWS.
- Use S3 para remote state do Terraform e DynamoDB para locking.

---

## A — Fluxo rápido com eksctl (rápido para POCs / dev)

1. Criar cluster mínimo (exemplo):

```bash
eksctl create cluster \
  --name challengeone-cluster \
  --region us-east-2 \
  --nodes 2 \
  --node-type t3.medium \
  --managed
```

2. Atualizar `kubeconfig` (geralmente o `eksctl` faz isso automaticamente):

```bash
aws eks --region us-east-2 update-kubeconfig --name challengeone-cluster
kubectl get nodes
```

3. Instalar os addons com Helm (exemplo resumido):

```bash
# Metrics Server
helm repo add bitnami https://charts.bitnami.com/bitnami
helm install metrics-server bitnami/metrics-server -n kube-system

# AWS Load Balancer Controller (exige criar OIDC provider e policy)
eksctl utils associate-iam-oidc-provider --region us-east-2 --cluster challengeone-cluster --approve
# seguir docs AWS para criar policy e serviceaccount

# Cert-Manager
helm repo add jetstack https://charts.jetstack.io
helm install cert-manager jetstack/cert-manager --namespace cert-manager --create-namespace --set installCRDs=true
```

4. Validar cluster: criar um deployment de teste e acessar via NodePort/LoadBalancer.

---

## B — Fluxo recomendado (Infra como Código com Terraform)

Use Terraform quando precisar de reprodutibilidade, revisão de mudanças e integração com pipelines.

1. Preparar backend remoto (S3 + DynamoDB):

```hcl
# exemplo: backend.tf
terraform {
  backend "s3" {
    bucket = "terraform-state-bucket-challenger-19"
    key    = "infra-kubernetes/terraform.tfstate"
    region = "us-east-2"
  }
}
```

Crie o bucket e a tabela DynamoDB (locking):

```bash
aws s3 mb s3://terraform-state-bucket-challenger-19 --region us-east-2
aws dynamodb create-table --table-name terraform-state-lock \
  --attribute-definitions AttributeName=LockID,AttributeType=S \
  --key-schema AttributeName=LockID,KeyType=HASH --billing-mode PAY_PER_REQUEST
```

2. Criar EKS com módulos Terraform (exemplo resumido):

- Use um módulo confiável (ex.: `eks module` da comunidade ou `aws_eks_cluster` e `aws_eks_node_group`).
- Habilite OIDC provider para IRSA e anexe políticas inline ou managed policies às ServiceAccounts.

```bash
cd infra-kubernetes
terraform init
terraform plan -out plan.tf
terraform apply "plan.tf"
```

3. Componentes a configurar no código Terraform:

- VPC com subnets públicas/privadas
- EKS control plane e node groups (managed node groups / Fargate profiles se aplicável)
- IAM OIDC provider e IAM policies para addons (AWS LB Controller, EBS CSI driver, external-dns se usar)
- Security groups para nós e LB
- S3 backend + DynamoDB lock

4. Após o apply, atualizar kubeconfig e validar:

```bash
aws eks --region us-east-2 update-kubeconfig --name <cluster-name>
kubectl get nodes
```

---

## C — Add-ons essenciais e instruções rápidas

1. AWS Load Balancer Controller

- Requer OIDC e policy com permissões para criar/gerenciar ELB/TargetGroups/Ingress.
- Instalar via Helm com service account que usa IRSA.

2. EBS CSI Driver

- Para volumes persistentes (PVC) usando EBS.
- Instalar via Helm / Terraform and provide IAM permissions.

3. Cert-Manager

- Para gerenciar certificados TLS (Let's Encrypt) — instalar CRDs antes.

4. Metrics Server

- Necessário para `kubectl top` e escaladores.

5. Cluster Autoscaler

- Configurar com o IAM policy apropriado e apontar para o grupo de nós.

Exemplo de instalação com Helm (resumido):

```bash
helm repo add eks https://aws.github.io/eks-charts
helm repo update
helm install aws-load-balancer-controller eks/aws-load-balancer-controller -n kube-system \
  --set clusterName=<cluster-name> --set region=us-east-2 --set vpcId=<vpc-id>
```

---

## D — Integração com CI/CD e deploy de aplicações

- Configure `kubectl` no runner CI (use `aws-actions/configure-aws-credentials` e `aws eks update-kubeconfig`).
- Use `kubectl` / `helm` / `terraform` do pipeline para aplicar alterações.
- Armazene imagens em ECR (recomendado) ou Docker Hub e configure `imagePullSecrets` quando necessário.

---

## E — Verificações e troubleshooting

- Verificar nodes: `kubectl get nodes -o wide`
- Verificar pods: `kubectl get pods -A`
- Logs do LB Controller / ingress: `kubectl logs -n kube-system <pod>`
- Erros comuns:
  - `ImagePullBackOff`: credenciais ou imagem não disponível.
  - `PVC` pendente: driver CSI não instalado ou classe de storage incorreta.
  - `LoadBalancer` não provisionado: Security Group ou quota da conta.

---

## F — Limpeza (remover recursos)

- Se criou com `eksctl`:

```bash
eksctl delete cluster --name challengeone-cluster --region us-east-2
```

- Se criou com Terraform:

```bash
terraform destroy -auto-approve
```

---

## 🔐 Segurança e boas práticas

- Não coloque credenciais em código. Use GitHub Secrets / AWS Parameter Store / Secrets Manager.
- Habilite logging do control plane e monitore auditoria.
- Use subnets privadas para workloads sensíveis e minimize acesso público.

---

## ✅ Deseja que eu adicione

- **script de bootstrap** (`scripts/bootstrap-eks.sh`) que cria EKS + OIDC + policies e instala addons, ou
- **módulo Terraform de exemplo** (com VPC, EKS e node groups) pronto para usar.

Responda **"bootstrap"**, **"terraform"** ou **"ambos"** e eu adiciono os artefatos correspondentes.

