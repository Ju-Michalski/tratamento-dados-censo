Censo RJ — Pipeline (R + SQLite) 🚀
Pequeno guia do repositório com o fluxo para baixar, importar, renomear e limpar microdados do Censo (RJ).

🔧 Requisitos
R 4.x + pacotes: lodown, SAScii, readr, dplyr, stringr, fs, DBI, RSQLite, censobr (e opcional arrow, pak)

DB Browser for SQLite (opcional) para inspeção

🧭 Visão geral do fluxo
Catálogo & download ⬇️
Usa lodown para baixar Censo 2010 – RJ (pessoas / amostra) e respectivos layouts SAS.

Importação seletiva 📥
Lê o TXT de largura fixa com readr::read_fwf() usando o layout do SAScii. Só carrega um subconjunto de variáveis definido no script.

Renomeação ✍️
Mapeia códigos (ex.: v0002, v0601…) para nomes legíveis (ex.: cod_mun, sexo, idade, rendimento etc.).
⚠️ Dica: evite acentos em nomes de colunas para facilitar o SQL (ex.: raca, pais_origem), apesar de não ser o que eu faço.

Persistência 💾
Exporta o data.frame para SQLite (censo_rj.db) via DBI + RSQLite.

🧹 Limpeza (SQL) — DB Browser
Filtro RJ: mantém apenas o município do Rio (código IBGE 3304557), mas filtre para o munícipio que quiser.

Idade: remove valores fora de faixa (ex.: <0 ou >100).

Renda (diagnóstico + log): checa outliers e cria log_renda.
⚠️ SQLite “puro” não tem LOG()/LN() — calcule no R ou carregue extensão matemática.

Frequências: consultas rápidas de ultima_educ, pais_origem, sexo, raca (adicione para as variáveis que lhe interessam, apenas para achar valores absurdos e eliminar).
