CREATE TABLE votes (
    congress INTEGER,
    chamber TEXT,
    rollnumber INTEGER,
    icpsr INTEGER,
    cast_code INTEGER,
    prob REAL
);

.mode csv
.import Hall_votes.csv votes

CREATE INDEX vote_idx ON votes (congress, rollnumber);

