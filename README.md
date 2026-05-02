# Kubernetes & NixOS HomeLab | Infrastructure as Code Showcase 🚀

Stanowi ono w 100% deklaratywną, opartą na kodzie konfigurację mojego domowego klastra Kubernetes (HomeLab), działającego na fizycznym sprzęcie (bare-metal).

Projekt ten jest odzwierciedleniem moich umiejętności w zakresie **DevOps, GitOps, automatyzacji infrastruktury oraz nowoczesnego zarządzania systemami**. Głównym założeniem było stworzenie środowiska, które jest powtarzalne, niezmienne (immutable) i w pełni zdefiniowane w repozytorium Git, dzięki czemu moge z dowolnego miejsca edytować pody w klastrze.

---

## 💡 Główne założenia i funkcjonalności

- **Pojedyncze źródło prawdy (Single Source of Truth):** Cały stan systemu – od kernela, przez demony sieciowe, aż po manifesty aplikacji w Kubernetesie – znajduje się w tym repozytorium.
- **Architektura dwuwarstwowa (IaC + GitOps):** Systemy operacyjne węzłów budowane są przy użyciu NixOS (Push model), natomiast aplikacje i zasoby K3s są automatycznie dociągane z repozytorium przez Fluxa (Pull model).
- **Niezmienność i powtarzalność:** Dzięki wykorzystaniu NixOS oraz Nix Flakes, system zawsze buduje się w ten sam sposób, eliminując problem _"u mnie działa"_.
- **Bezpieczeństwo (Secret Management):** Wrażliwe dane (hasła, tokeny) są szyfrowane kryptograficznie w kodzie przy użyciu `agenix` i odszyfrowywane wyłącznie w pamięci RAM węzłów docelowych.

## 🏗 Architektura i Topologia Sieciowa

Środowisko składa się z trzech fizycznych maszyn (węzłów) połączonych w klaster Kubernetes: jednego węzła zarządzającego (`master` - z83) oraz dwóch węzłów roboczych (`worker` - hp-1, hp-2). Ruch sieciowy jest centralnie zarządzany przez router brzegowy MikroTik.

```text
       [ ISP / Internet ]
              │
              ▼ (WAN)
    ┌────────────────────┐
    │  MikroTik hEX      │ (Router brzegowy / DHCP / Firewall / NAT)
    └─────────┬──────────┘
              │ (LAN)
              ├──────────────────────────────┐
              ▼                              ▼
    ┌────────────────────┐          ┌───────────────────┐
    │  USW Flex Mini     │          │ Mój Laptop        │ (Zarządzanie IaC)
    │  (Switch Ubiquiti) │          └───────────────────┘
    └─┬─────────┬──────┬─┘
      │         │      │
      ▼         ▼      ▼
   ┌─────┐   ┌─────┐  ┌─────┐
   │ z83 │   │ hp-1│  │ hp-2│
   └─────┘   └─────┘  └─────┘
  (Master)  (Worker) (Worker)
```

## 🧰 Stos Technologiczny

Poniższe narzędzia zostały dobrane celowo, aby sprostać wymaganiom nowoczesnych standardów inżynierii oprogramowania:

- **NixOS & Nix Flakes:** Wykorzystane jako system bazowy (Host OS). Pozwalają na całkowicie deklaratywną konfigurację systemu operacyjnego. Plik `flake.lock` gwarantuje determinizm – klaster zbudowany dzisiaj, za rok użyje dokładnie tych samych wersji binarek.
- **Kubernetes (K3s):** Główny orkiestrator. Zarządza cyklem życia kontenerów, zapewnia wysoką dostępność (HA) usług oraz load balancing.
- **Flux (FluxCD):** Operator realizujący rygorystyczny wzorzec GitOps dla klastra. Flux działa jako kontroler wewnątrz Kubernetesa, ciągle monitoruje to repozytorium (Pull model) i automatycznie aplikuje zmiany z plików YAML. Dzięki temu wdrażanie aplikacji ogranicza się do zwykłego `git push`.
- **Agenix / SOPS:** Nowoczesne podejście do zarządzania sekretami w publicznym repozytorium. Sekrety są szyfrowane kluczami asymetrycznymi (Ed25519) poszczególnych maszyn, co chroni infrastrukturę przed wyciekiem danych.

---

## ⚙️ Wdrożenie (Deployment Workflow)

Poniższa sekcja dokumentuje proces odtwarzania klastra (Disaster Recovery) oraz uświadamia, jak proste jest postawienie całej infrastruktury od zera.

### Krok 1: Inicjalizacja środowiska zarządzającego

Zaczynamy od pobrania repozytorium na stację roboczą (laptop), z której prowadzony jest provisioning bazowy:

```bash
git clone https://github.com/Lukidere/kubernetes-config.git
cd kubernetes-config
```

### Krok 2: Konfiguracja Kryptografii (Zarządzanie Kluczami)

System bezpieczeństwa (Agenix) wymaga uwierzytelnienia nowo stawianych hostów:

1. Generowanie kluczy asymetrycznych `Ed25519` na nowych maszynach.
2. Dodanie kluczy publicznych do pliku `secrets.nix` (Rejestracja hostów).
3. Wykonanie re-enkrypcji sekretów (`agenix -r`), aby umożliwić nowym maszynom ich odczyt.

### Krok 3: Scentralizowana Konfiguracja Sieci

W przeciwieństwie do tradycyjnego hardkodowania adresów w systemie operacyjnym, węzły w tym klastrze są skonfigurowane do pobierania adresacji z serwera DHCP.
**Statyczna adresacja IP (DHCP Static Leases), routing oraz reguły firewalla są w pełni i centralnie zarządzane na poziomie routera MikroTik.**
W plikach konfiguracyjnych NixOS (`./configs/*/configuration.nix`) definiowane są jedynie nazwy hostów. Takie podejście ułatwia zarządzanie siecią (IPAM) z jednego punktu i zmniejsza ilość "szumu" w konfiguracji samego OS.

### Krok 4: Continuous Deployment Systemu Operacyjnego (Push)

Stan maszyn bazowych jest kompilowany lokalnie na laptopie i wysyłany bezstanowo na serwery:

```bash
# Wdrożenie węzła Control Plane (Master)
nixos-rebuild switch --flake .#z83

# Wdrożenie węzłów Data Plane (Workers)
nixos-rebuild switch --flake .#hp1
nixos-rebuild switch --flake .#hp2
```

### Krok 5: Automatyzacja GitOps (Pull)

Po zakończeniu działania komend z Kroku 4, systemy operacyjne wstają, łączą się w klaster Kubernetes i w tym momencie stery przejmuje **Flux**. Samodzielnie dociąga on manifesty YAML z repozytorium i instaluje odpowiednie kontrolery, usługi (Serwisy, Ingressy) oraz aplikacje docelowe bez jakiejkolwiek ingerencji manualnej.

---
