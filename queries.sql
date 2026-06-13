-- foul differences per season (positive means away team fouled more)
SELECT
    season,
    era,
    ROUND(AVG(af - hf), 3) AS avg_foul_delta,
    COUNT(*) AS matches
FROM matches
GROUP BY season, era
ORDER BY season;


-- how often the home team wins across different eras
SELECT
    era,
    ROUND(AVG(CASE WHEN ftr = 'H' THEN 1 ELSE 0 END) * 100, 1) AS home_win_pct,
    COUNT(*) AS matches
FROM matches
GROUP BY era
ORDER BY
    CASE era
        WHEN 'Pre-VAR'    THEN 1
        WHEN 'VAR Intro'  THEN 2
        WHEN 'Ghost Game' THEN 3
        WHEN 'Post-VAR'   THEN 4
    END;


-- checking yellow card differences by era. positive means away team got booked more.
SELECT
    era,
    ROUND(AVG(ay - hy), 3) AS avg_yellow_delta,
    COUNT(*) AS matches
FROM matches
GROUP BY era
ORDER BY
    CASE era
        WHEN 'Pre-VAR'    THEN 1
        WHEN 'VAR Intro'  THEN 2
        WHEN 'Ghost Game' THEN 3
        WHEN 'Post-VAR'   THEN 4
    END;


-- ref breakdown (only keeping those with a decent sample size of 20+ games)
SELECT
    referee,
    ROUND(AVG(ay - hy), 3)                                      AS avg_yellow_delta,
    COUNT(*)                                                     AS matches_refereed,
    ROUND(AVG(CASE WHEN ftr = 'H' THEN 1 ELSE 0 END) * 100, 1) AS home_win_pct,
    ROUND(AVG(af - hf), 3)                                      AS avg_foul_delta
FROM matches
GROUP BY referee
HAVING COUNT(*) >= 20
ORDER BY avg_foul_delta DESC;


-- looking at the pandemic games to see how lack of crowds impacted things
SELECT
    season,
    era,
    ROUND(AVG(ay - hy), 3)                                      AS avg_yellow_delta,
    COUNT(*)                                                     AS matches,
    ROUND(AVG(CASE WHEN ftr = 'H' THEN 1 ELSE 0 END) * 100, 1) AS home_win_pct,
    ROUND(AVG(af - hf), 3)                                      AS avg_foul_delta
FROM matches
WHERE season IN ('2019/20', '2020/21', '2021/22')
GROUP BY season, era
ORDER BY season;