# Lab Terraform — Azure VM

Provisiona uma VM Ubuntu 22.04 na Azure via Terraform: resource group, VNet, subnet, NIC, IP público estático, NSG restringindo SSH por IP, e a VM em si com um script de setup (systemd service de exemplo).

## Pré-requisitos
- terraform instalado
- azure-cli instalado e autenticado (`az login`)
- Chave SSH (`~/.ssh/id_rsa` ou similar)

## Uso
1. Copie `terraform.tfvars.example` para `terraform.tfvars` e preencha com seus valores.
2. `terraform init`
3. `terraform plan`
4. `terraform apply`

## Notas / troubleshooting já resolvido
- Algumas regiões da assinatura de estudante têm restrição de SKU (B1s/B2s/DS1_v2 indisponíveis) — usado `Standard_D2s_v3` em `northcentralus`.
- IP público Basic SKU foi descontinuado pela Microsoft — usa-se Standard SKU + alocação estática.
- SSH exige NSG com regra de entrada na porta 22, associado à NIC.
