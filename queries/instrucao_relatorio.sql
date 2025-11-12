/*
  Query: Relatório de Títulos em Aberto (exemplo técnico)
  Autor: Carlos Ribeiro
  Descrição:
    Exemplo de instrução SQL utilizada em relatórios financeiros.
    O script aplica parâmetros dinâmicos (intervalo de datas, empresa,
    situação e comprador) e retorna dados formatados para exibição.
*/

SELECT 
    T0.*, 
    TO_CHAR(:DT_INICIO, 'DD/MM/YYYY') AS DATA_INICIAL,
    TO_CHAR(:DT_FIM, 'DD/MM/YYYY') AS DATA_FINAL,
    CASE 
        WHEN :SITUACAO = 'A' THEN 'ABERTO'
        WHEN :SITUACAO = 'Q' THEN 'QUITADO'
        ELSE 'ABERTO E QUITADO'
    END AS STATUS_FILTRADO, 
    :EMPRESA AS EMPRESA_FILTRADA,
    CASE
        WHEN :COMPRADOR = 'TODOS' THEN 'TODOS'
        ELSE UPPER(:COMPRADOR)
    END AS COMPRADOR_FILTRADO,
    TO_CHAR(SYSDATE, 'DD/MM/YYYY HH24:MI:SS') AS DATA_HORA_GERACAO,

    (SELECT SUM(T1.VALOR_ORIGINAL)
     FROM VW_TITULOS_COMPRADOR T1
     WHERE T1.CONTA = T0.CONTA
       AND T1.DATA_PROGRAMADA BETWEEN :DT_INICIO AND :DT_FIM
    ) AS TOTAL_VALOR,

    :SUPRIMIR AS FLAG_SUPRESSAO

FROM VW_TITULOS_COMPRADOR T0
WHERE 
    T0.DATA_PROGRAMADA BETWEEN :DT_INICIO AND :DT_FIM
    AND T0.EMPRESA = CASE 
                        WHEN :EMPRESA = 'TODAS' THEN T0.EMPRESA 
                        ELSE :EMPRESA 
                     END
    AND T0.STATUS = CASE 
                        WHEN :SITUACAO IN ('A', 'Q') THEN :SITUACAO 
                        ELSE T0.STATUS 
                    END
    AND T0.COMPRADOR = CASE 
                          WHEN :COMPRADOR = 'TODOS' THEN T0.COMPRADOR 
                          ELSE :COMPRADOR 
                       END;
