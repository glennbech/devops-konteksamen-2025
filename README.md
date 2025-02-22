# PGR301 DevOps i skyen -Gjentak: 72 timers skriftlig individuell hjemmeeksamen

## Krav til leveransen

**Eksamensoppgaven, kode og nødvendige filer er tilgjengelig i GitHub-repoet:**  
[https://github.com/glennbechdevops/eksamen-2025-konte](https://github.com/glennbechdevops/eksamen-2025-konte)

### Retningslinjer for innlevering

### **WiseFlow:**
* Når du leverer oppgaven i WiseFlow, last opp et dokument som kun inneholder en lenke til ditt repository. Filen må være i enten PDF- eller tekstformat.

### **GitHub:**
* Du kan enten lage en fork av dette repositoryet eller kopiere filene inn i et nytt repository.
* For å unngå at andre studenter ser din besvarelse, anbefales det å jobbe i et privat repository. Gjør repositoryet offentlig rett før innleveringsfristen.
* I repositoryet ditt skal du opprette en fil, `README.md`, hvor du besvarer drøfteoppgaver og dokumenterer oppgavespesifikke leveranser.



# Bakgrunn

Din bedrift har nylig begynt å bruke [StatusCake](https://www.statuscake.com/) for overvåking av tilgjengelighet. 

Som en del av selskapets **DevOps-reise** er det besluttet å implementere **"overvåking som kode"** for å sikre en mer systematisk og reproduserbar tilnærming. Valget har falt på **Terraform** for infrastrukturadministrasjon og **GitHub Actions** for CI/CD. 



## Eksisterende oppsett

Du har fått utdelt et **Terraform-prosjekt**, lokalisert i mappen `infrastructure/`.

### Prosjektets innhold

1. **Enkel Terraform-konfigurasjon**
  - Inneholder hardkodede API-nøkler i `provider`-blokken.

2. **Enkel alarm for én nettside**
  - Bruker hardkodede verdier, noe som gjør koden lite gjenbrukbar.

3. **CI/CD-pipeline**
  - Automatisert utrulling av oppsettet, men ikke implementert i tråd med god DevOps-praksis.





### 0.  Generelt 

* For å løse oppgaven anbefales det å opprette en gratis 7-dagers prøveperiode hos StatusCake: [Registrer deg her](https://www.statuscake.com/).
* Bruk litt tid på å bli kjent med tjenesten og konseptene. Det vil hjelpe deg med å skrive infrastrukturkoden.
* Prøv gjerne å kjøre Terraform lokalt før du bruker GitHub Actions for å spare tid.
* Når du skal overvåke en nettside, kan du velge et vilkårlig domene, for eksempel [VG](https://www.vg.no) eller [xkcd](https://xkcd.com/).

 

### 1. Sikkerhet og forbedring av CI/CD-pipelinen (30 poeng)

For øyeblikket er workflowen konfigurert for manuell oppstart. Dette krever at man navigerer til GitHub i nettleseren, åpner "Actions" og deretter velger "Run workflow".  
I tillegg ser det ut til at en API-nøkkel for StatusCake er hardkodet i koden – noe som er en alvorlig sikkerhetsrisiko.

Din oppgave er å gjennomføre følgende endringer:

- **GitHub Actions Workflow:**
  - På feature branches skal workflowen kjøre `terraform plan`, men ikke `terraform apply`.
  - På main branch skal både `terraform plan` og `terraform apply` utføres automatisk.

- **Håndtering av sensitive verdier:**
  - Infrastrukturkoden og GitHub Actions workflowen skal ikke inneholde hardkodede hemmeligheter, som for eksempel Status CAKE sin API-nøkkel. Beskriv og implementer en sikker løsning for håndtering av sensitive verdier.


  
### 2. Forbedring- og utvidelse av Terraform koden (30 poeng)

* Erstatt hardkodede verdier med variabler der det gir mening
* Sett deg inn i StatusCake sin Terraform-provider (https://registry.terraform.io/providers/StatusCakeDev/statuscake/latest/docs) og utvid koden med flere ressurser. 
* Du må som et minimum opprette en contact_group, men du står fritt til å legge til flere ressurser etter eget ønske.
* Lag en kort beskrivelse av valgene dine for overvåkning, terskelverdier mm. 



### 3. Terraform-moduler (30 poeng)

En av de store fordelene med Terraform er muligheten til å skrive gjenbrukbar infrastrukturkode. Siden flere avdelinger i bedriften kan ha behov for overvåkning med StatusCake, ønsker vi å lage en gjenbrukbar modul.

I evalueringen vektlegges brukervennligheten til modulen – for eksempel ved at den setter fornuftige standardverdier for terskelverdier og andre innstillinger. Samtidig bør modulen gi brukerne mulighet til å overstyre disse variablene ved behov.

**Oppgave:**
- Utvid Terraform-koden slik at den kan overvåke flere nettsider. For å unngå repetisjon av kode skal du bruke **Terraform-moduler**.
- Lag en modul og bruk den to ganger med ulike verdier for minst to forskjellige nettsider.



### 4. Håndtering av Terraform State (10 poeng)

Som du kanskje har lagt merke til, er håndteringen av `Terraform state` ikke optimal. For øyeblikket har teamet valgt å sjekke inn Terraform state-filen i GitHub sammen med koden.

**Oppgave:**
Drøft følgende; 

- I starten kan denne tilnærmingen fungere, men hvilke konsekvenser kan det få når teamet vokser og flere utviklere jobber med samme repository samtidig?
- Hvilke mekanismer kan brukes for å håndtere Terraform state på en bedre måte?

LYKKE TIL MED OPPGAVEN!

