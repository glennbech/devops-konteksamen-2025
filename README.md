Oppgave 1: Sikkerhet og forbedring av CI/CD-pipelinen

Endringer i CI/CD-pipelinen:
I denne oppgaven har jeg forbedret GitHub Actions workflowen for Terraform for å implementere en automatisert og sikker CI/CD-pipeline.

Endringer jeg har gjort:
- Feature branches: Workflowen kjører `terraform plan`, men ikke `terraform apply`.
- Main branch: Workflowen kjører både `terraform plan` og `terraform apply` automatisk.
- Sikring av API-nøkler: Jeg har fjernet hardkodede verdier og erstattet dem med GitHub Secrets.
- Fjerning av Terraform state commit: Terraform state-filen blir ikke sjekket inn i repositoryet.

Håndtering av sensitive verdier:
For å sikre at API-nøkler ikke er hardkodet i kildekoden, har jeg implementert en løsning ved bruk av GitHub Secrets:
1. Jeg har lagret API-nøkkelen i GitHub Secrets under navnet `STATUSCAKE_API_TOKEN`.
2. Workflowen refererer til denne verdien ved bruk av:
   env:
     STATUSCAKE_API_TOKEN: ${{ secrets.STATUSCAKE_API_TOKEN }}

Oppdatert GitHub Actions workflow.

Den oppdaterte `hellow_world.yml` ser slik ut nå:
name: Terraform Pipeline

on:
  push:
    branches:
      - main
      - 'feature/**'
  pull_request:
    branches:
      - main

permissions:
  contents: write

env:
  TF_STATE_FILE: "terraform.tfstate"
  TF_DIR: "infrastructure"
  STATUSCAKE_API_TOKEN: ${{ secrets.STATUSCAKE_API_TOKEN }}

jobs:
  terraform:
    name: Terraform Workflow
    runs-on: ubuntu-latest

    steps:
      - name: Checkout Repository
        uses: actions/checkout@v4

      - name: Setup Terraform
        uses: hashicorp/setup-terraform@v1

      - name: Initialize Terraform
        run: terraform init
        working-directory: ${{ env.TF_DIR }}

      - name: Terraform Plan
        run: terraform plan -out=tfplan
        working-directory: ${{ env.TF_DIR }}

      - name: Apply Terraform (only on main)
        if: github.ref == 'refs/heads/main'
        run: terraform apply -auto-approve tfplan
        working-directory: ${{ env.TF_DIR }}


Testing av løsningen
For å verifisere at workflowen fungerer som forventet, har jeg gjennomført følgende tester:

Test 1: Feature branch
1. Opprettet en ny feature branch:
  
   git checkout -b feature/test-ci-cd
   
2. Gjorde en liten endring i `main.tf` for å trigge workflowen.

3. Commitet og pushet endringen:

   git add infrastructure/main.tf
   git commit -m "Test: Oppdaterte Terraform-konfig for CI/CD-test"
   git push origin feature/test-ci-cd
   
4. Verifiserte at kun `terraform plan` kjørte i GitHub Actions, og at `terraform apply` ble hoppet over.

Test 2: Merge til main
1. Byttet til `main` branch og slo sammen endringene:
  
   git checkout main
   git merge feature/test-ci-cd
   
2. Pushet endringene til `main`:
   
   git push origin main
  
3. Verifiserte i GitHub Actions at både `terraform plan` og `terraform apply` kjørte automatisk.

Dette kan man se under actions i workflowene kalt "test".

Test 3: Sikring av API-nøkler
1. Sjekket at StatusCake API-token ikke var synlig i noen av loggene i GitHub Actions.
2. Bekreftet at Terraform kunne opprette StatusCake-ressurser ved bruk av API-nøkkelen fra GitHub Secrets.

Testene bekreftet at workflowen fungerer som spesifisert i oppgaven.

