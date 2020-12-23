.mode tabs
.out agreements.tsv

SELECT
    a.congress, a.icpsr, b.icpsr, COUNT(*)
FROM votes a
INNER JOIN votes b
ON
(
    a.congress = b.congress
    AND a.congress = 110
    AND a.rollnumber = b.rollnumber
    AND a.icpsr < b.icpsr
    AND -- votes agree
    (
        (a.cast_code IN (1, 2, 3) AND b.cast_code IN (1, 2, 3))
        OR (a.cast_code IN (4, 5, 6, 7, 8, 9) AND b.cast_code IN (4, 5, 6, 7, 8, 9))
    )
)
GROUP BY a.congress, a.icpsr, b.icpsr
