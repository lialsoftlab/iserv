USE [lial_dbistt_3213E83F5A5938281]
GO

WITH 
  ----------------------------------------------------------------------------------------------------------------------------------
  -- Ранжируем элементы по вероятному порядку создания на дату.
  AccPointStatusRanked(id, accpoint_id, [date], [status], [rank]) AS (
    SELECT 
       id
      ,accpoint_id
      ,[date]
      ,[status]
      ,RANK() OVER (PARTITION BY accpoint_id, [date] ORDER BY [id])
    FROM 
      dbo.AccPointStatus 
  ),
  NetElemStatusRanked(id, netelem_id, [date], [status], [rank]) AS (
    SELECT 
       id
      ,netelem_id
      ,[date]
      ,[status]
      ,RANK() OVER (PARTITION BY netelem_id, [date] ORDER BY [id])
    FROM 
      dbo.NetElemStatus 
  ),

  ----------------------------------------------------------------------------------------------------------------------------------
  -- Очищаем от "шума".
  AccPointStatusCleared(id, accpoint_id, [date], status) AS (
    SELECT id, accpoint_id, [date], [status]
    FROM AccPointStatusRanked
    WHERE [rank] = 1
  ),
  NetElemStatusCleared(id, netelem_id, [date], status) AS (
    SELECT id, netelem_id, [date], status
    FROM NetElemStatusRanked
    WHERE [rank] = 1
  ),

  ----------------------------------------------------------------------------------------------------------------------------------
  -- Формируем записи о интервалах действия статуса.
  AccPointStatusIntervals(id, accpoint_id, from_date, [status], to_date) AS (
    SELECT 
       id
      ,accpoint_id
      ,[date] as from_date
      ,[status]
      ,(
        SELECT TOP 1 [date] 
        FROM AccPointStatusCleared 
        WHERE 
              accpoint_id = aps.accpoint_id 
          AND [status] <> aps.[status] 
          AND [date] > aps.[date]
      ) AS to_date      
    FROM 
      AccPointStatusCleared AS aps
  ),
  NetElemStatusIntervals(id, netelem_id, from_date, [status], to_date) AS (
    SELECT 
       id
      ,netelem_id
      ,[date] as from_date
      ,[status]
      ,(
        SELECT TOP 1 [date] 
        FROM NetElemStatusCleared 
        WHERE 
              netelem_id = aps.netelem_id 
          AND status <> aps.status 
          AND [date] > aps.[date]
      ) AS to_date      
    FROM 
      NetElemStatusCleared AS aps
  ),

  ----------------------------------------------------------------------------------------------------------------------------------
  -- Очищаем от излишних идущих встык интервалов с одинаковым статусом, заменя на один общий.
  AccPointStatusDistinctIntervals(id, accpoint_id, from_date, to_date, [status]) AS (
    SELECT 
       MAX(id) AS id
      ,accpoint_id
      ,MIN(from_date) AS from_date
      ,DATEADD(DAY, -1, to_date)
      ,[status]  
    FROM 
      AccPointStatusIntervals
    GROUP BY
      accpoint_id, to_date, [status]
  ),
  NetElemStatusDistinctIntervals(id, netelem_id, from_date, to_date, [status]) AS (
    SELECT 
       MAX(id) AS id
      ,netelem_id
      ,MIN(from_date) AS from_date
      ,DATEADD(DAY, -1, to_date)
      ,[status]  
    FROM 
      NetElemStatusIntervals
    GROUP BY
      netelem_id, to_date, [status]
  ),

  ----------------------------------------------------------------------------------------------------------------------------------
  -- Формируем записи об перекрывающихся интервалах активности для связанных ТУ и ЭС.
  CommonActivityIntervals(accpoint_id, netelem_id, from_date, to_date, [status]) AS (
    SELECT 
       ap2nel.accpoint_id
      ,ap2nel.netelem_id 
      ,(SELECT MAX(x) FROM (VALUES (aps.from_date), (nes.from_date)) AS t(x)) AS from_date
      ,(SELECT MIN(x) FROM (VALUES (aps.to_date  ), (nes.to_date  )) AS t(x)) AS to_date
      ,CAST(1 AS BIT) AS [status]
    FROM 
      dbo.AccPoint2NetElementLink AS ap2nel
      JOIN AccPointStatusDistinctIntervals AS aps ON aps.accpoint_id = ap2nel.accpoint_id AND aps.status = 1
      JOIN NetElemStatusDistinctIntervals  AS nes ON nes.netelem_id  = ap2nel.netelem_id  AND nes.status = 1
    WHERE  
           (aps.from_date <= nes.from_date AND nes.from_date <= ISNULL(aps.to_date, nes.from_date))
        OR (nes.from_date <= aps.from_date AND aps.from_date <= ISNULL(nes.to_date, aps.from_date))
  ),

  ----------------------------------------------------------------------------------------------------------------------------------
  -- Формируем записи об общих интервалах неактивности для связанных ТУ и ЭС, между интервалами общей активности.
  CommonNotActivityIntervals(accpoint_id, netelem_id, from_date, to_date, [status]) AS (
    SELECT 
       accpoint_id
      ,netelem_id
      ,DATEADD(DAY, 1, to_date) AS from_date
      ,ISNULL(
        (
            SELECT TOP 1 DATEADD(DAY, -1, from_date)
            FROM CommonActivityIntervals 
            WHERE accpoint_id = cai.accpoint_id AND netelem_id = cai.netelem_id AND from_date > cai.to_date
            ORDER BY from_date
        )
        ,DATEADD(yy, DATEDIFF(yy, 0, to_date) + 1, -1)
      ) AS to_date
      ,CAST(0 AS BIT) AS [status]
    FROM 
      CommonActivityIntervals AS cai
  ),
  
  /*********************************************************************************************************************************
  --
  -- Вариант формирования общего списка интервалов, когда начальный интервал неактивности до первого активного интервала 
  -- расчитывается с минимальной даты наличия данных по ТУ или ЭС в связке. 
  -- В т.з. есть неоднозначность по этому поводу.
  --

  ----------------------------------------------------------------------------------------------------------------------------------
  -- Формируем начальные интервалы неактивности для комбинаций ТУ и ЭС, от точки с старта самого раннего интервала.
  CommonMinFromDates(accpoint_id, netelem_id, min_from_date) AS (
    SELECT 
       apned.accpoint_id
      ,apned.netelem_id
      ,(SELECT MIN(x) FROM (VALUES (aps.min_from_date), (nes.min_from_date)) AS t(x)) AS min_from_date
    FROM 
       (SELECT DISTINCT accpoint_id, netelem_id FROM CommonActivityIntervals) AS apned
       JOIN (
         SELECT accpoint_id, MIN(from_date) AS min_from_date 
         FROM AccPointStatusDistinctIntervals 
         GROUP BY accpoint_id
       ) AS aps ON aps.accpoint_id = apned.accpoint_id
       JOIN (
         SELECT netelem_id, MIN(from_date) AS min_from_date 
         FROM NetElemStatusDistinctIntervals
         GROUP BY netelem_id
       )  AS nes ON nes.netelem_id  = apned.netelem_id
  ),  
  
  ----------------------------------------------------------------------------------------------------------------------------------
  -- Формируем групповую таблицу уникальных интервалов активности и неактивности для комбинаций ТУ и ЭС.
  Intervals(accpoint_id, netelem_id, from_date, to_date, [status], yfactor) AS (
      SELECT 
         cai.accpoint_id
        ,cai.netelem_id
        ,cmd.min_from_date AS from_date
        ,DATEADD(DAY, -1, cai.min_from_date) AS to_date
        ,CAST(0 AS BIT) AS [status]
        ,YEAR(DATEADD(DAY, -1, cai.min_from_date)) - YEAR(cmd.min_from_date) AS yfactor 
      FROM 
         CommonMinFromDates AS cmd 
         INNER JOIN (
           SELECT accpoint_id, netelem_id, MIN(from_date) as min_from_date
           FROM CommonActivityIntervals
           GROUP BY accpoint_id, netelem_id
         ) AS cai ON cai.accpoint_id = cmd.accpoint_id AND cai.netelem_id = cmd.netelem_id
       WHERE
         cai.min_from_date > cmd.min_from_date
    
    UNION
    
      SELECT 
         accpoint_id
        ,netelem_id
        ,from_date
        ,to_date
        ,[status]
        ,YEAR(to_date) - YEAR(from_date) AS yfactor 
      FROM 
        CommonActivityIntervals 
    
     UNION
    
      SELECT 
         accpoint_id
        ,netelem_id
        ,from_date
        ,to_date
        ,[status]
        ,YEAR(to_date) - YEAR(from_date) AS yfactor 
      FROM 
        CommonNotActivityIntervals 
  ),
  *********************************************************************************************************************************/

  ----------------------------------------------------------------------------------------------------------------------------------
  -- Формируем групповую таблицу уникальных интервалов активности и неактивности для связок ТУ и ЭС.
  Intervals(accpoint_id, netelem_id, from_date, to_date, [status], yfactor) AS (
   -- Первый неактивный интервал от начала года до первого интервала активности.
   SELECT 
     *, YEAR(to_date) - YEAR(from_date) AS yfactor 
   FROM 
     (
       SELECT 
          accpoint_id
         ,netelem_id
         ,CAST(DATEADD(yy, DATEDIFF(yy, 0, min_from_date), 0) AS DATE) AS from_date
         ,DATEADD(DAY, -1, min_from_date) AS to_date
         ,CAST(0 AS BIT) AS [status]
       FROM 
         (
           SELECT accpoint_id, netelem_id, MIN(from_date) AS min_from_date 
           FROM CommonActivityIntervals 
           GROUP BY accpoint_id, netelem_id
         ) AS minimums
     ) AS t

   UNION

     SELECT 
        accpoint_id
       ,netelem_id
       ,from_date
       ,to_date
       ,[status]
       ,YEAR(to_date) - YEAR(from_date) AS yfactor 
     FROM 
       CommonActivityIntervals 

   UNION

     SELECT 
        accpoint_id
       ,netelem_id
       ,from_date
       ,to_date
       ,[status]
       ,YEAR(to_date) - YEAR(from_date) AS yfactor 
     FROM 
       CommonNotActivityIntervals 
  ),
  
  ----------------------------------------------------------------------------------------------------------------------------------
  -- Нарезка интервалов по границам года, если он выходит за пределы одного календарного года.
  IntervalsByYear(n, accpoint_id, netelem_id, from_date_old, to_date_old, from_date, to_date, [status], yfactor) AS (
    SELECT 
       1 AS n
      ,accpoint_id, netelem_id
      ,from_date AS from_date_old
      ,to_date AS to_date_old
      ,from_date
      ,CASE WHEN yfactor > 0 
        THEN CAST(DATEADD (dd, -1, DATEADD(yy, DATEDIFF(yy, 0, from_date) +1, 0)) AS DATE) -- обрезаем окончанием года.
        ELSE to_date 
       END AS to_date
      ,[status]
      ,yfactor 
    FROM 
      Intervals
    
    UNION ALL
    
    SELECT 
       n + 1 AS n
      ,accpoint_id
      ,netelem_id 
      ,from_date_old
      ,to_date_old
      ,CAST(DATEADD(yy, DATEDIFF(yy, 0, from_date_old) + n, 0) AS DATE) AS from_date -- cдвигаем на начало года.
      ,CASE WHEN yfactor > n
        THEN CAST(DATEADD(yy, DATEDIFF(yy, 0, from_date_old) + n + 1, -1) AS DATE) -- обрезаем окончанием года.
        ELSE to_date_old 
       END AS to_date
      ,[status], yfactor 
    FROM 
      IntervalsByYear 
    WHERE 
      yfactor >= n
  )   
SELECT 
  ap.[name], from_date, to_date, status 
FROM 
  IntervalsByYear
  JOIN AccPoint AS ap ON ap.id = accpoint_id
ORDER BY 
  accpoint_id, from_date
;
