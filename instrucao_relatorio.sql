/*
  Query: Instrução de relatório financeiro
  Autor: Carlos Ribeiro
  Descrição:
    Essa instrução é a query executada pelo gerador de relatórios da aplicação.
    Ela consome a view `PASV_TITULOS_EM_ABERTO_COMPRADOR`, aplicando parâmetros
    dinâmicos (intervalo de datas, empresa, situação e comprador) e retornando
    os dados formatados para exibição.
*/


SELECT 
    T0.*, 
    TO_CHAR(:DT1, 'DD/MM/YYYY') AS INICIO,
    TO_CHAR(:DT2, 'DD/MM/YYYY') AS FIM,    
    CASE 
        WHEN :LS3 = 'A' THEN 'ABERTO'
        WHEN :LS3 = 'Q' THEN 'QUITADO'
        ELSE 'ABERTO E QUITADO'
    END AS SITUACAO_ESCOLHIDA, 
    :LS1 AS ESCOLHA_EMPRESA,
    CASE
        WHEN :LS4 = 'TODOS' THEN 'TODOS'
        ELSE UPPER(:LS4)
    END AS ESCOLHA_COMPRADOR,
    TO_CHAR(SYSDATE, 'DD/MM/YYYY HH24:MI:SS') AS DATA_HORA_IMPRESSAO,  
        
    (SELECT 
         SUM(T1.VLRORIGINAL) 
     FROM PASV_TITULOS_EM_ABERTO_COMPRADOR T1
     WHERE T1.CONTA_CORRENTE = T0.CONTA_CORRENTE
       AND T1.DTAPROGRAMADA BETWEEN :DT1 AND :DT2
    ) AS TOTAL_VALOR_ORIGINAL,
    :NR2 as SUPRIMIR

FROM PASV_TITULOS_EM_ABERTO_COMPRADOR T0
WHERE 
    T0.DTAPROGRAMADA BETWEEN :DT1 AND :DT2
    AND T0.EMPRESA = CASE 
                        WHEN :LS1 = 'TODAS' THEN T0.EMPRESA 
                        ELSE :LS1 
                     END
    AND T0.EXC_ESPECIES = CASE 
                              WHEN :LS2 = 'TODAS' THEN T0.EXC_ESPECIES 
                              ELSE '1' 
                          END
    AND (
        (:LS3 = 'A' AND T0.ABERTOQUITADO = 'A') OR
        (:LS3 = 'Q' AND T0.ABERTOQUITADO = 'Q') OR
        (:LS3 NOT IN ('A', 'Q')) 
    )
    AND T0.COMPRADOR = CASE 
                          WHEN :LS4 = 'TODOS' THEN T0.COMPRADOR 
                          ELSE :LS4 
                       END
    AND (
        (:NR1 = 1 AND T0.DTAPROGRAMADA = T0.DATAINCLPROG)
        OR (:NR1 != 1 AND T0.DATAINCLPROG <> T0.DTAPROGRAMADA)
    )
;
