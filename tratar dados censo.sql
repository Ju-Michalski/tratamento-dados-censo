-- 0) Filtrar para município do rio

DELETE FROM censo
 WHERE cod_mun != '3304557';

-- 1) Checando valores absurdos para idade
SELECT * 
  FROM censo
 WHERE idade < 0 
    OR idade > 100;
	
DELETE FROM censo
 WHERE idade > 100;
 
-- 2) Checando valores absurdos para rendimento e loglinearizar
SELECT * 
  FROM censo
 WHERE rendimento < 0 
    OR rendimento > 1e6; 

ALTER TABLE censo
  ADD COLUMN log_renda REAL;

UPDATE censo
	SET log_renda = CASE
		WHEN rendimento > 0 THEN LOG(rendimento)
		ELSE NULL
	END;
END

-- 3) Checando valores absurdos para educ
SELECT
  ultima_educ,
  COUNT(*) AS frequencia
FROM
  censo
GROUP BY
  ultima_educ
ORDER BY
  frequencia DESC;
  
 -- 4) Checando valores para país de origem

SELECT
  país_origem,
  COUNT(*) AS frequencia
FROM
  censo
GROUP BY
  país_origem
ORDER BY
  frequencia DESC;

 -- 5) Checando valores para sexo
 SELECT
  sexo,
  COUNT(*) AS frequencia
FROM
  censo
GROUP BY
  sexo
ORDER BY
  frequencia DESC;
  
 -- 6) Checando valores para raça
 SELECT
  raça,
  COUNT(*) AS frequencia
FROM
  censo
GROUP BY
  raça
ORDER BY
  frequencia DESC;
  
