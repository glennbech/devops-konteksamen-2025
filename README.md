Hvordan kjøre og teste Terraform-konfigurasjonen:
For å kjøre og teste Terraform-oppsettet med StatusCake, følg disse stegene:

1. Klon repositoryet
Først må du klone repositoryet ditt til din lokale maskin:
git clone https://github.com/ym2806/devops-konteksamen-2025.git

cd devops-konteksamen-2025/infrastructure

2. Installer Terraform
Terraform må være installert på systemet ditt.
Bekreft installasjonen med:
terraform version

3. Sett opp API-token i GitHub Secrets -siden hver konto har sin egen token.
Før Terraform kan kjøre StatusCake-konfigurasjonen, må du sette opp API-tokenet ditt som en GitHub Secret:

Gå til repositoryet ditt på GitHub.
Klikk på Settings > Secrets and variables > Actions.
Klikk New repository secret.
Sett Name: STATUSCAKE_API_TOKEN
Sett Value: Ditt API-token fra StatusCake. Denne finner du ved å lage en konto på StatusCake og du finner den på nederste del av siden "My account".

4. Initialiser Terraform
Når du har satt opp API-tokenet, må du initialisere Terraform:
terraform init i cd devops-konteksamen-2025/infrastructure

-Dette laster ned nødvendige provider-moduler og setter opp Terraform.

5. Planlegg endringer
Kjør følgende kommando for å se hvilke endringer Terraform vil gjøre:
Terraform plan

-Terraform vil vise en oversikt over ressursene den planlegger å opprette eller endre.

6. Kjør Terraform Apply
Hvis alt ser riktig ut, kan du kjøre:
terraform apply -auto-approve

-Dette vil opprette eller oppdatere StatusCake-ressursene basert på konfigurasjonen.

7. Verifiser at overvåkningen fungerer
Logg inn på StatusCake Dashboard.
Gå til Uptime Monitoring og sjekk at VG og XKCD-oppetidssjekkene er opprettet.
Se om de viser "UP" eller "DOWN".

8. Feilsøking
Hvis noe ikke fungerer, prøv følgende:

Sjekk Terraform-loggene:
terraform show

-Slett eksisterende tester manuelt i StatusCake og kjør terraform apply på nytt.
-Endre status_codes i Terraform-konfigurasjonen hvis StatusCake tolker svar feil.
-Sjekk GitHub Actions-loggene for feil i CI/CD-oppsettet.

-Hvis ingen av disse feilsøkingsmetodene hjalp kan du sjekke metodene i eksamensbesvarelsen under.

Eksamensbesvarelse DevOps 2025
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

Test 3: Sikring av API-nøkler
1. Sjekket at StatusCake API-token ikke var synlig i noen av loggene i GitHub Actions.
2. Bekreftet at Terraform kunne opprette StatusCake-ressurser ved bruk av API-nøkkelen fra GitHub Secrets.

Testene bekreftet at workflowen fungerer som spesifisert i oppgaven. Dette kan man se under actions i workflowene kalt "test" og du kan prøve det selv.


Oppgave 2: 
Forbedring og utvidelse av Terraform-koden

Under utviklingen av oppgave 2 oppstod det problemer med branches og .gitignore filen. Derfor måtte jeg slette progresjonen min og resette oppgaven.

Endringer i Terraform-konfigurasjonen-
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
For å sikre at alt fungerer som forventet, har jeg kjørt flere tester:

Test 1: Terraform Plan
Gjorde en liten oppdatering/kommentar i main.tf og pushet til en feature branch.
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
Jeg må foreløpig bytte navnet for hver gang:
variable "contact_group_name" {
  description = "Navn på kontaktgruppen"
  type        = string
  default     = "DevOps Team 30"
}

Løsningen har dessverre noen konsekvenser. Terraform kunne ikke håndtere kontaktgruppen automatisk. Hvis noen andre på teamet prøvde å pushe til git uten å endre navnet, ville de møte samme feil. Dette kunne føre til inkonsistens siden kontaktgruppen ikke kunne oppdateres riktig. Men under Terraform apply funker dette fint uten å endre navn.

Konklusjon
Terraform-konfigurasjonen er nå mer fleksibel og inkluderer en `contact_group` med varsling. CI/CD fungerer som forventet, og StatusCake-miljøet er riktig konfigurert, men det er problem med opprettelse av kontaktgruppe navn ved hver push til git. Jeg brukte mye tid på å prøve å få Terraform til å opprette kontaktgruppen automatisk uten å få navnekonflikt, men ingen av løsningene ble akseptert av StatusCake eller Terraform og jeg måtte eventuelt gå videre. 

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
  source           = "../modules/statuscake_uptime"
  name             = "VG Uptime Check"
  address          = "https://www.vg.no"
  check_interval   = 900
  confirmation     = 3
  trigger_rate     = 10
  timeout          = 75 
  validate_ssl     = false  # Deaktivert SSL-validering
  follow_redirects = true   # Tillater redirects
  request_method   = "HTTP"
  status_codes = [
  "200", "201", "204", "205", "206", "303", "400", "401", "403", 
  "404", "405", "406", "408", "409", "410", "413", "429", "444", 
  "494", "495", "496", "499", "500", "501", "502", "503", "504", 
  "505", "506", "507", "508", "509", "510", "511", "521", "522", "523"
]
  tags             = ["news", "monitoring"]
contact_group_id = [statuscake_contact_group.default.id]
}

Problemer og Feilsøking
Etter å ha implementert Terraform-modulen for StatusCake-overvåkning av to nettsider (VG.no og XKCD.com), oppstod en kritisk feil: Begge oppetidssjekkene gikk først til å være "DOWN" hele tiden, og så til "UP" til "DOWN" etter noen sekunder ved videre implementering, selv om nettsidene var tilgjengelige.

Forventet resultat var at Terraform skulle opprette fungerende overvåkninger, men StatusCake meldte nedetid, til tross for at nettsidene returnerte HTTP 200-statuskode når de ble manuelt sjekket. Jeg prøvde en del forskjellige metoder før jeg måtte gå videre:

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

Jeg utvidet listen basert på hva man fant på StatusCake sin egen oppsett av tester:

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
Dette løste ikke problemet, men tiden den var oppe var lengre. StatusCake rapporterte fortsatt at sjekkene var nede etter litt tid, selv når sidene returnerte HTTP 200.

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
Dette løste ikke problemet alene, men bidro til mer konsistente testresultater i StatusCake da testen var "UP" i en lengre periode.

4. Fjerning av gamle oppetidssjekker i StatusCake
Det var mulig at StatusCake ikke håndterte Terraform-endringer korrekt, og at gamle sjekker fortsatt påvirket resultatene. Jeg slettet alle testene manuelt og prøvde på nytt.

Resultat:
Dette hjalp en del, da det fjernet flere av de gamle konfigurasjonene som muligens skapte konflikt.
Sjekkene viste "UP" en stund lengre, men gikk tilbake til "DOWN" etter noen sekunder.

Konklusjon
Jeg prøvde alle mulige feilsøkingsmetoder man kunne tenke, men problemet forble uløst. StatusCake fortsatte å rapportere at sjekkene var "DOWN" etter noen sekunder/minutter selv når de fikk HTTP 200. Den mest sannsynlige feilkilden kan være at jeg har skrevet noe feil. Det er en del redundans i filene, spesielt i main og variabel filene, noe som ikke har skap noen problemer i de tidligere oppgavene, men som kanskje skader progresjonen til oppgave 3. Det kan også være DNS eller serverbaserte blokkeringer da StatusCake sine overvåkingsservere kan være blokkert. Tidligere under øving for eksamen så opplevde jeg problemer med både wifi og DNS serverne på min laptop, spesielt da jeg øvde på Docker.


Oppgave 4: 
Håndtering av Terraform State

Siden `terraform.tfstate` for øyeblikket blir sjekket inn i GitHub-repositoryet sammen med koden kan dette fungere i starten, men etter hvert som teamet vokser, føre til flere problemer.

Når flere utviklere arbeider med Terraform samtidig, kan terraform.tfstate bli overskrevet ved git push eller git pull, noe som kan føre til tap av data eller inkonsistente endringer i infrastrukturen. Hvis én utvikler kjører terraform apply og en annen kjører terraform plan med en utdatert state-fil, kan det føre til at Terraform ikke lenger har korrekt oversikt over infrastrukturen.

Terraform har ingen innebygd mekanisme for å forhindre at flere utviklere utfører terraform apply samtidig når state-filen lagres lokalt. Dette kan resultere i parallelle oppdateringer, som igjen kan føre til inkonsistente eller uventede endringer i infrastrukturen.

Terraform state-filen kan inneholde sensitive data, for eksempel API-nøkler, tilgangstokens eller IP-adresser til kritiske systemer. Dersom terraform.tfstate sjekkes inn i et offentlig eller delt repository, kan denne informasjonen potensielt bli eksponert og misbrukt.

Når terraform.tfstate lagres lokalt eller i GitHub, er det ingen enkel måte å spore endringer eller rulle tilbake til tidligere versjoner hvis noe går galt. For å omgå dette problemet har jeg manuelt laget zip-kopier av terraform.tfstate før jeg kjørte terraform apply, men dette er en ineffektiv og sårbar metode sammenlignet med en skikkelig løsning.

En mer robust og skalerbar løsning er å lagre terraform.tfstate i en sentralisert, sikker og låsbar backend. Dette sikrer at teamet alltid har en oppdatert og konsistent state-fil, samtidig som det eliminerer sikkerhetsrisikoen ved å sjekke inn state-filen i GitHub.

1. S3 Bucket med DynamoDB-lås (AWS)
Terraform kan konfigureres til å bruke en Amazon S3-bucket for å lagre state-filen, med DynamoDB for å håndtere låsemekanismer. Dette gir følgende fordeler:

Terraform state lagres sentralt og kan alltid hentes oppdatert.
DynamoDB-låsen forhindrer at flere Terraform-operasjoner kjører samtidig.
S3 har innebygd versjonering, slik at man kan rulle tilbake til tidligere versjoner hvis nødvendig.
Eksempel på Terraform-konfigurasjon for S3-backend:
terraform {
  backend "s3" {
    bucket         = "my-terraform-state"
    key            = "terraform.tfstate"
    region         = "us-east-1"
    encrypt        = true
    dynamodb_table = "terraform-lock"
  }
}

-Dette sikrer at Terraform kun tillater én operasjon om gangen og at state-filen er trygt lagret.

2. Terraform Cloud eller Terraform Enterprise
Terraform Cloud tilbyr en innebygd løsning for state-håndtering med flere fordeler:

Automatisk lagring av state-filen i en sentral backend.
Låsemekanismer som forhindrer parallelle terraform apply-operasjoner.
Versjonskontroll, slik at man kan rulle tilbake ved feil.
Mulighet for integrasjon med CI/CD-pipelines.
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

-Terraform Cloud gir en sømløs opplevelse for team som allerede bruker HashiCorp-verktøyene.

3. Remote State med Azure Blob Storage eller Google Cloud Storage
For team som bruker Microsoft Azure eller Google Cloud Platform, kan Terraform state lagres i:

Azure Blob Storage
Google Cloud Storage (GCS)
Begge alternativene gir:

Sentralisert lagring av state-filen.
Versjonskontroll for rollback.
Integrasjon med CI/CD.
Eksempel på Terraform backend-konfigurasjon for Azure Blob Storage:
terraform {
  backend "azurerm" {
    resource_group_name  = "my-resource-group"
    storage_account_name = "mystorageaccount"
    container_name       = "tfstate"
    key                  = "terraform.tfstate"
  }
}

-Dette sikrer en skalerbar løsning for Terraform state uten behov for manuell håndtering av state-filen.

Konklusjon
Å sjekke inn terraform.tfstate i GitHub er ikke en langsiktig løsning for et voksende DevOps-team. Ved å implementere en remote backend-løsning, som S3 + DynamoDB, Terraform Cloud eller Azure/GCP Storage, kan vi: Unngå state-filkonflikter når flere utviklere jobber samtidig.
Sikre state-filen mot utilsiktet sletting eller overskriving.
Beskytte sensitiv infrastrukturdata fra å bli eksponert.
Få versjonskontroll og rollback-funksjonalitet.
For å forbedre prosjektet ytterligere, bør Terraform-konfigurasjonen oppdateres til å bruke en remote backend, slik at state-filen alltid er oppdatert, låst og sikret mot tap eller konflikter