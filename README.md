Oppgave 1: 
Sikkerhet og forbedring av CI/CD-pipelinen

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
        run: terraform plan -var="statuscake_api_token=${{ secrets.STATUSCAKE_API_TOKEN }}" -out=tfplan
        working-directory: ${{ env.TF_DIR }}

      - name: Apply Terraform (only on main)
        if: github.ref == 'refs/heads/main'
        run: terraform apply -var="statuscake_api_token=${{ secrets.STATUSCAKE_API_TOKEN }}" -auto-approve tfplan
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

Oppgave 2: 
Forbedring og utvidelse av Terraform-koden

Under utviklingen av oppgave 2 oppstod det problemer med branches og .gitignore filen. Derfor måtte jeg slette progresjonen min og resette oppgaven.


Endringer i Terraform-konfigurasjonen
I denne oppgaven har jeg forbedret og utvidet Terraform-koden ved å:
1. Erstatte hardkodede verdier med variabler** for mer fleksibilitet.  
2. Legge til en `contact_group`-ressurs** for StatusCake med støtte for e-postvarsler.  
2. Oppdatere CI/CD-pipelinen** til å bruke de nye variablene.

Endringer i `main.tf`
1. `uptime_check`-ressursen bruker nå variabler i stedet for hardkodede verdier.
2.  Ny ressurs: `statuscake_contact_group` som støtter email addresse:

    resource "statuscake_contact_group" "default" {
      name            = var.contact_group_name
      email_addresses = var.contact_group_emails
    }

For å gjøre konfigurasjonen mer fleksibel, har jeg opprettet `variables.tf`:

    variable "contact_group_emails" {
      description = "Liste over e-postadresser i kontaktgruppen"
      type        = list(string)
      default     = ["din.email@example.com"]
    }

Endringer i `hellow_world.yml`:
1. Pipeline tar nå hensyn til de nye variablene.
2. Terraform plan og apply kjører som før, men med oppdaterte parametere.

Test av løsningen:
FFor å sikre at alt fungerer som forventet, har jeg kjørt flere tester:

Test 1: Terraform Plan
Gjorde en liten oppdatering i main.tf og pushet til en feature branch.
- Terraform Plan kjørte vellykket, og viste at en ny contact_group skulle opprettes.

Test 2: Terraform Apply på main
Merget feature branch til main.
-Terraform Apply opprettet både contact_group og uptime_check.
-Bekreftet i StatusCake at kontaktgruppen og overvåkningen er aktiv.

Test 3: E-postvarsling
E-postadressen ble registrert i StatusCake.
-Bekreftet at Terraform output viste riktig ID for contact_group.

Problemer:
Under implementeringen av statuscake_contact_group i Terraform oppstod en feil hvor StatusCake ikke godtok kontaktgruppenavnet. Dette skjedde etter første push. Feilmeldingen var:

│ Error: failed to create contact group: The provided parameters are invalid. Check the errors output for detailed information.: name contains violations
│ 
│   with statuscake_contact_group.default,
│   on main.tf line 14, in resource "statuscake_contact_group" "default":
│   14: resource "statuscake_contact_group" "default" {
│ 
│ The name is already taken. Choose a unique name.

-Dette betyr at StatusCake nektet å opprette en ny kontaktgruppe fordi navnet allerede var tatt. Jeg forsøkte flere forskjellige metoder på å fikse dette problemet, blant annet et forsøk på å gjøre navnet dynamisk med en variabel:

resource "statuscake_contact_group" "default" {
  name            = "Terraform Contact Group ${timestamp()}"
  email_addresses = var.contact_group_emails
}


Min midlertidige løsning for å bare gå videre med oppgaven var en manuell endring av navnet.
Jeg må bare bytte navnet for hver gang:
variable "contact_group_name" {
  description = "Navn på kontaktgruppen"
  type        = string
  default     = "DevOps Team 30"
}

Hver gang jeg gjorde en ny terraform apply, måtte jeg endre navnet.

Løsningen har noen konsekvenser. Terraform kunne ikke håndtere kontaktgruppen automatisk. Hvis noen andre på teamet prøvde å kjøre terraform apply uten å endre navnet, ville de møte samme feil. Dette kunne føre til inkonsistens i terraform state, siden kontaktgruppen ikke kunne oppdateres riktig.

Konklusjon
Terraform-konfigurasjonen er nå mer fleksibel og inkluderer en `contact_group` med varsling. CI/CD fungerer som forventet, og StatusCake-miljøet er riktig konfigurert, men det er problem med opprettelse av kontaktgruppe navn ved hver push til git. Jeg brukte mye tid på å prøve å få Terraform til å opprette kontaktgruppen automatisk uten å få navnekonflikt, men ingen av løsningene ble akseptert av StatusCake eller Terraform.

For å kunne fullføre oppgaven måtte vi derfor bruke en manuell løsning, hvor vi endret navnet på kontaktgruppen for hver terraform apply-kjøring.

Selv om dette tillot oss å gå videre, er dette en svakhet i løsningen som bør forbedres i fremtidige iterasjoner.

Oppgave 3: 
Terraform-moduler

Beskrivelse
I denne oppgaven ble Terraform-koden utvidet for å overvåke flere nettsider med StatusCake. For å unngå repetisjon av kode ble det opprettet en Terraform-modul (`modules/statuscake_uptime`) som brukes for å definere og gjenbruke oppsettet for oppetidssjekker.

Modulen ble brukt til å opprette to separate overvåkninger:
1. VG.no - `VG Uptime Check`
2. XKCD.com - `XKCD Uptime Check`

Endringer og Implementasjon
- Opprettet en mappe `modules/statuscake_uptime` som inneholder:
  - `main.tf` (definerer ressursene)
  - `variables.tf` (definerer variablene for modulen)
  - `outputs.tf` (definerer hvilke verdier modulen eksponerer)
- Brukt modulen to ganger i `infrastructure/main.tf` for å overvåke VG og XKCD.
- Definerte variabler for oppetidsjekker, inkludert `timeout`, `validate_ssl`, `status_codes`, og `follow_redirects`.

Eksempel på hvordan modulen brukes:
module "uptime_check_vg" {
  source          = "../modules/statuscake_uptime"
  name            = "VG Uptime Check"
  address         = "https://www.vg.no"
  check_interval  = 300
  confirmation    = 3
  trigger_rate    = 10
  timeout         = 50
  validate_ssl    = true
  follow_redirects = true
  status_codes    = ["200", "301", "302"]
  tags            = ["news", "monitoring"]
}

Problemer og Feilsøking
Etter å ha implementert Terraform-modulen for StatusCake-overvåkning av to nettsider (VG.no og XKCD.com), oppstod en kritisk feil: Begge oppetidssjekkene gikk fra "UP" til "DOWN" etter noen sekunder, selv om nettsidene var tilgjengelige.

Forventet resultat var at Terraform skulle opprette fungerende overvåkninger, men StatusCake meldte umiddelbar nedetid, til tross for at nettsidene returnerte HTTP 200-statuskode når de ble manuelt sjekket.

1. Manuell sjekking av nettadresser med curl
Første steg var å teste nettsidene manuelt for å se om de faktisk var tilgjengelige.
Kommandoene jeg kjørte var:
curl -I https://xkcd.com
curl -L -I https://xkcd.com
curl -I https://www.vg.no
curl -L -I https://www.vg.no

Resultat:
Begge nettsidene returnerte HTTP 200 OK, noe som bekreftet at de faktisk var oppe.
StatusCake viste fortsatt "DOWN", noe som indikerte at feilen kan ligge i konfigurasjonen av oppetidssjekkene, ikke selve nettsidene.

2. Justering av status_codes i Terraform
StatusCake kunne ha tolket noen HTTP-statuskoder som feil, selv om de egentlig var forventet.

Endringer ble gjort i variables.tf for modulen:

variable "status_codes" {
  description = "Tillatte HTTP-statuskoder"
  type        = list(string)
  default     = ["200", "301", "302", "403"]
}

Vi utvidet listen basert på hva vi fant på StatusCake sin egen oppsett av tester:

variable "status_codes" {
  description = "Tillatte HTTP-statuskoder"
  type        = list(string)
  default     = ["200", "201", "204", "205", "206", "303",
                 "400", "401", "403", "404", "405", "406",
                 "408", "409", "410", "413", "429", "444",
                 "494", "495", "496", "499", "500", "501",
                 "502", "503", "504", "505", "506", "507",
                 "508", "509", "510", "511", "521", "522", "523"]
}

Resultat:
Dette løste ikke problemet, men tiden den var oppe var lengre. StatusCake rapporterte fortsatt at sjekkene var nede eventuelt, selv når sidene returnerte HTTP 200.

3. Endring av request_method fra "HEAD" til "HTTP"
Terraform-modulen var satt opp til å bruke "HEAD" som request_method, men jeg tenkte at kanskje noen nettsider returneree uventede resultater på en HEAD-forespørsel. Jeg endret request_method til "GET" for å simulere en normal nettleserforespørsel.

Endring i main.tf i modulen:
http_check {
  request_method = "GET" # Endret fra HEAD til GET
  timeout        = 75
  validate_ssl   = false
  follow_redirects = true
  status_codes   = var.status_codes
}

Resultat:
Dette løste ikke problemet alene, men bidro til mer konsistente testresultater i StatusCake.

4. Fjerning av gamle oppetidssjekker i StatusCake
Det var mulig at StatusCake ikke håndterte Terraform-endringer korrekt, og at gamle sjekker fortsatt påvirket resultatene. Jeg slettet alle testene manuelt og prøvde på nytt.

Resultat:
Dette hjalp en del, da det fjernet flere av de gamle konfigurasjonene som muligens skapte konflikt.
Sjekkene viste "UP" en stund lengre, men gikk tilbake til "DOWN" etter noen sekunder.

Konklusjon
Vi prøvde alle mulige feilsøkingsmetoder vi kunne tenke oss, men problemet forble uløst. StatusCake fortsatte å rapportere at sjekkene var "DOWN" selv når de fikk HTTP 200. Den mest sannsynlige feilkilden kan være at jeg har skrevet noe feil. Det er en del redundans i filene, noe som ikke har skap noen problemer i de tidligere oppgavene, men som kanskje skader progresjonen til oppgave 3.


Oppgave 4: 
Håndtering av Terraform State

Problemet med nåværende tilnærming
For øyeblikket blir `terraform.tfstate` sjekket inn i GitHub-repositoryet sammen med koden. Dette kan fungere i starten, men etter hvert som teamet vokser, kan det føre til flere problemer:

1. State-filkonflikter
   - Når flere utviklere jobber med Terraform samtidig, kan `terraform.tfstate` bli overskrevet ved push og pull, noe som fører til mistede endringer.
   - Hvis en utvikler har en lokal state-fil og en annen utvikler gjør en oppdatering i repositoryet, kan Terraform-planene bli utdaterte eller feile.

2. Manglende låsemekanismer
   - Terraform state bør låses slik at kun én person eller prosess kan utføre Terraform-kommandoer samtidig. Uten dette kan flere `terraform apply`-operasjoner kjøre parallelt og skape uforutsigbare resultater.

3. Sikkerhetsrisiko
   - `terraform.tfstate` kan inneholde sensitive data, som API-nøkler eller passord. Hvis denne filen sjekkes inn i et offentlig eller delt repository, kan det føre til datalekkasjer.

4. Manglende historikk og rollback
   - Ved bruk av en lokal eller sjekket-inn state-fil finnes det ingen innebygd versjonskontroll eller rollback-mekanismer. Hvis noe går galt, kan det være vanskelig å gjenopprette tidligere infrastrukturtilstander.

Bedre Mekanismer for Terraform State-håndtering

En bedre tilnærming er å lagre `terraform.tfstate` på en sentralisert, sikker og låsbar backend. 

Her er tre gode alternativer:
1. S3 Bucket med DynamoDB-lås (AWS)
Terraform kan konfigureres til å bruke en S3-bucket for å lagre state-filen, med DynamoDB for låsing. Dette sikrer at:
   - Terraform state er sentralt lagret og alltid oppdatert.
   - DynamoDB-låsen forhindrer flere Terraform-operasjoner samtidig.
   - Versjonering kan aktiveres på S3-bucketen for enkel rollback.

Eksempel på backend-konfigurasjon:
terraform {
  backend "s3" {
    bucket         = "my-terraform-state"
    key            = "terraform.tfstate"
    region         = "us-east-1"
    encrypt        = true
    dynamodb_table = "terraform-lock"
  }
}

2. Terraform Cloud eller Terraform Enterprise
Terraform Cloud gir en innebygd løsning for state-håndtering med:
   - Automatisk state-lagring.
   - Låsemekanismer.
   - Versjonskontroll og rollback.
   - Integrasjon med CI/CD-pipelines.

Aktivering av Terraform Cloud backend:
terraform {
  backend "remote" {
    hostname     = "app.terraform.io"
    organization = "my-org"

    workspaces {
      name = "my-workspace"
    }
  }
}

3. Remote State med Azure Blob Storage eller Google Cloud Storage
For team som bruker Azure eller GCP, kan Terraform state lagres i Azure Blob Storage eller Google Cloud Storage (GCS). Begge gir sentralisert lagring og versjonskontroll.

Eksempel for Azure:
terraform {
  backend "azurerm" {
    resource_group_name  = "my-resource-group"
    storage_account_name = "mystorageaccount"
    container_name       = "tfstate"
    key                  = "terraform.tfstate"
  }
}

Konklusjon
For et voksende team er det viktig å ikke sjekke inn state-filen i GitHub. I stedet bør man bruke en remote backend med låsemekanismer, for eksempel:
- S3 + DynamoDB (AWS)
- Terraform Cloud
- Azure Blob Storage
- Google Cloud Storage

Ved å implementere en av disse løsningene kan vi:
- Unngå konflikter når flere utviklere jobber samtidig.  
- Sikre state-filen mot utilsiktet sletting eller overskriving.  
- Beskytte sensitiv infrastrukturdata.  
- Få versjonskontroll og rollback-funksjonalitet.  