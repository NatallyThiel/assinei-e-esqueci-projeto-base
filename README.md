# 📱 Assinei & Esqueci

O **Assinei & Esqueci** é uma aplicação em Flutter desenvolvida para ajudar os utilizadores a gerir e organizar os seus gastos recorrentes e assinaturas (serviços de streaming, software, clubes de benefícios, entre outros), evitando cobranças indesejadas por esquecimento.

---

## 🚀 Funcionalidades

- 📊 **Dashboard Financeiro:** Visualização rápida do gasto mensal estimado com assinaturas.
- ⏰ **Alertas e Próximos Vencimentos:** Identificação automática da assinatura mais próxima do vencimento com contagem decrescente de dias.
- 🔔 **Opções Rápidas de Ação:**
  - **Cancelar Agora:** Direcionamento para detalhes do cancelamento com instruções do serviço.
  - **Lembrar Depois:** Configuração de lembretes personalizados.
- 📋 **Gestão de Assinaturas:** Listagem, consulta e adição de novas assinaturas ativas.
- 👤 **Perfil do Utilizador:** Gestão dos dados pessoais.

---

## 🛠️ Tecnologias Utilizadas

- **Linguagem:** [Dart](https://dart.dev/)
- **Framework:** [Flutter](https://flutter.dev/)
- **Gerenciamento de Estado:** ValueNotifier / ListenableBuilder
- **Banco de Dados:** [PostgreSQL](https://www.postgresql.org/) (utilizado no backend para persistência de dados das assinaturas, alertas e usuários)

---

## 📂 Estrutura de Pastas Principais

```text
lib/
├── data/
│   ├── models/         # Modelos de dados (Assinatura, Usuário)
│   └── repositories/   # Repositórios e lógica de armazenamento
└── modules/            # Ecrãs e componentes da aplicação
    ├── alertas/
    ├── assinaturas/
    ├── inicial/        # Dashboard Home
    └── perfil/
