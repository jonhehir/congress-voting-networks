from collections import Counter, defaultdict


def votes_agree(a, b):
    # out of range (includes "not a member of chamber when vote was taken")
    if min(a, b) < 1 or max(a, b) > 9:
        return False
    
    # two yeas
    if a in [1, 2, 3] and b in [1, 2, 3]:
        return True
    
    # two nay/abstain/present
    if a >= 4 and b >= 4:
        return True
    
    return False

def tally_agreements(filename):
    agreements = Counter()
    votes = defaultdict(lambda: defaultdict(list))
    
    past_headers = False
    #lines = 0

    with open(filename) as f:
        for line in f:
            # skip header line
            if not past_headers:
                past_headers = True
                continue
            
            #lines += 1
            #if lines > 100000:
                #break # just quit early for now
            
            fields = line.strip().split(",")
            session, rollcall, voter, vote = int(fields[0]), int(fields[2]), int(fields[3]), int(fields[4])
            votes[session][rollcall].append((voter, vote))
    
    for session in votes:
        for rollcall, tuples in votes[session].items():
            for i in range(len(tuples)):
                for j in range(i+1, len(tuples)):
                    if votes_agree(tuples[i][1], tuples[j][1]):
                        a = min(tuples[i][0], tuples[j][0])
                        b = max(tuples[i][0], tuples[j][0])
                        agreements[(session, a, b)] += 1
    
    return agreements


for ids, count in tally_agreements("Hall_votes.csv").items():
    print("\t".join(map(str, list(ids).append(count))))
