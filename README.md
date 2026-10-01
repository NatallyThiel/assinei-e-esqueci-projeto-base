# 📱 Assinei & Esqueci

O **Assinei & Esqueci** é uma solução inteligente desenvolvida para ajudar utilizadores a gerir e organizar os seus gastos recorrentes (serviços de streaming, software, clubes de benefícios, etc.), evitando cobranças indesejadas e renovações automáticas por esquecimento.

---

## 🏛️ Visão Geral da Arquitetura

O projeto adota um modelo arquitetural **Cliente-Servidor descentralizado baseado em Serviços e APIs** (Monólito Modular na Nuvem), organizado em **Arquitetura em Camadas** (*Layered / Clean Architecture*) tanto no cliente quanto no servidor.

### Detalhamento das Camadas:
* **Camada de Apresentação (Client - Mobile):** Desenvolvida em **Flutter**, segue o padrão de separação entre Interface de Utilizador (UI) e Lógica de Estado (ValueNotifier / ListenableBuilder no MVP), garantindo reatividade rápida ao listar assinaturas, disparar notificações e manipular ecrãs de cancelamento.
* **Camada de Aplicação e Negócio (Backend REST API):** Atua no processamento das regras do app (cálculo de datas de vencimento, agendamento de alertas e gestão de assinaturas vinculadas ao CPF).
* **Camada de Dados (Database):** Armazena de forma relacional os dados cadastrais dos utilizadores, métodos de pagamento salvos, histórico de lembretes e status das assinaturas (*Ativa, Cancelada, Teste Grátis*).

---

## 🛠️ Stack Tecnológica & Justificativa Técnica

### 📱 Frontend Mobile
* **Tecnologia:** Dart + Flutter
* **Justificativa:** Permite o desenvolvimento cross-platform nativo (Android e iOS) a partir de uma única base de código. A renderização via Skia/Impeller garante alta performance e fluidez nas listas. O suporte nativo a notificações locais e push facilita o disparo de alertas pré-cobrança.

### ⚙️ Backend & Regras de Negócio
* **Tecnologia:** Java + Spring Boot
* **Justificativa:** Framework robusto, amplamente adotado no mercado enterprise para a construção de APIs RESTful de alta concorrência e segurança. O ecossistema Spring (Spring Security, Spring Data JPA) facilita o gerenciamento de autenticação via JWT, integração segura com o PostgreSQL e o agendamento de tarefas em segundo plano para envio de alertas.

### 🗄️ Banco de Dados
* **Tecnologia:** PostgreSQL
* **Justificativa:** Banco de dados relacional (RDBMS) robusto e seguro. Garante conformidade com as propriedades ACID (Atomicidade, Consistência, Isolamento e Durabilidade) e suporte nativo a dados estruturados e semiestruturados (JSONB), sendo ideal para lidar com histórico financeiro e integração com Open Finance.

### ☁️ Hospedagem e Infraestrutura
* **Tecnologia / Plataforma:** Google Play Store & Nuvem
* **Justificativa:** A **Google Play Store** será a plataforma oficial para a publicação, distribuição e atualização do aplicativo mobile via artefato de compilação (`.aab`). A infraestrutura em nuvem garante disponibilidade, certificados de segurança SSL nativos e escalabilidade para o backend em Spring Boot e para o banco de dados PostgreSQL.

---

## 🔌 Serviços e APIs de Terceiros

| Serviço / API | Tecnologia / Provedor | Finalidade |
| :--- | :--- | :--- |
| **Push Notifications** | Firebase Cloud Messaging (FCM) | Envio de alertas de lembrete $X$ dias antes da renovação automática de um teste grátis ou assinatura. |
| **Gateway de Pagamento** *(Em Definição)* | Asaas / Mercado Pago / Stripe | Processar planos de assinatura do próprio app ou validar cobranças de testes. |
| **Open Finance / Leitura Bancária** *(Futura Integração)* | Pluggy ou Belvo | Mapeamento automático de cobranças recorrentes na fatura do cartão de crédito via CPF. |

---

📂 Estrutura do Projeto Frontend
lib/
├── data/
│   ├── models/         # Modelos de dados (AssinaturaModel, UsuarioModel)
│   └── repositories/   # Repositórios e gerenciamento de estado
└── modules/            # Módulos e ecrãs da aplicação
    ├── alertas/
    ├── assinaturas/
    ├── inicial/        # Dashboard e navegação principal
    └── perfil/
