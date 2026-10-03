# App Compras — Supabase + Cloudflare Pages

PWA mobile-first para criação e acompanhamento de listas de compras. Esta versão não usa Google Sheets nem Apps Script.

## Arquitetura

- Frontend: HTML, CSS e JavaScript
- Hospedagem: Cloudflare Pages (repositório GitHub)
- Banco/API: Supabase PostgreSQL + Data API
- Offline/cache: localStorage + Service Worker
- Sincronização: ao abrir, manual pelo botão ↻ e automaticamente a cada 30 minutos enquanto o app estiver ativo

## 1. Criar o banco no Supabase

1. Crie um projeto no Supabase.
2. Abra **SQL Editor**.
3. Copie todo o conteúdo de `supabase/schema.sql`.
4. Execute o SQL.

O SQL cria `listas`, `itens_lista`, `itens` e `tipos_lista`, índices e políticas RLS.

### Segurança desta versão

O SQL entregue está configurado para **protótipo sem login**. As políticas permitem operações com a chave pública `anon`. Isso é adequado somente para teste/uso controlado: qualquer pessoa que obtenha a URL e a chave pública poderá acessar os dados pela API. Para disponibilizar o app a usuários independentes, implemente Supabase Auth e políticas RLS por `user_id`. Nunca coloque `service_role`, secret key ou senha no frontend.

## 2. Configurar o frontend

Abra `config.js` e informe:

- `SUPABASE_URL`: Project URL do Supabase.
- `SUPABASE_PUBLISHABLE_KEY`: chave pública `sb_publishable_...`.

Não altere `app.js` para configurar credenciais.

## 3. Testar

Sirva a pasta por HTTP/HTTPS (não abra apenas como `file://`). Na primeira sincronização, se o Supabase estiver vazio, a biblioteca padrão e os tipos existentes no armazenamento local são enviados ao banco.

## 4. Publicar no Cloudflare Pages

1. Suba o conteúdo desta pasta para um repositório GitHub.
2. No Cloudflare, abra **Workers & Pages > Create > Pages > Connect to Git**.
3. Selecione o repositório.
4. Como é um site estático, não há comando de build.
5. Use a raiz do projeto como diretório de saída.
6. Faça o deploy e abra o endereço `*.pages.dev`.

O `manifest.json` e `sw.js` permitem instalar o app como PWA.

## Sincronização

As ações são aplicadas imediatamente no dispositivo e marcadas como alterações locais. O app sincroniza com o Supabase ao abrir, pelo botão ↻ e a cada 30 minutos enquanto estiver ativo. Esta versão preserva a estratégia local-first do protótipo anterior.

## Edição no celular

No modo Editar, a alça ☰ fica à esquerda. Os controles à direita são apenas ícones de lápis e lixeira. A reordenação funciona com drag-and-drop no desktop e gesto pela alça em telas touch.

## Arquivos principais

- `index.html` — interface
- `styles.css` — layout responsivo
- `app.js` — regras e sincronização
- `config.js` — URL e Publishable Key do Supabase
- `supabase/schema.sql` — banco e RLS
- `manifest.json`, `sw.js`, `icons/` — PWA

## Sincronização sequencial (v3)

As alterações da interface são gravadas localmente de imediato. Cada ação marca uma nova geração local pendente. Existe apenas um processador de sincronização com o Supabase por vez: se novas ações ocorrerem durante um envio, elas não são descartadas nem bloqueadas; ao terminar o envio atual, o processador envia novamente o estado local mais recente. A pendência é persistida no localStorage para sobreviver a recarregamentos e falhas de conexão.

A sincronização automática disparada por ações faz somente o envio das pendências, evitando que um download remoto sobrescreva uma ação recém-feita. O botão Atualizar e as sincronizações periódicas enviam primeiro todas as pendências e somente depois consultam o estado remoto.
