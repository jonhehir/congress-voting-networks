from collections import Counter, defaultdict
import logging
import multiprocessing


def translate_vote(code):
    if code in [1, 2, 3]:
        return True # yea
    if code in [4, 5, 6, 7, 8, 9]:
        return False # nay
    return None # doesn't count

def read_votes(filename):
    # session => Tuple[rollcall, vote] => List[voters]
    votes = defaultdict(lambda: defaultdict(list))
    
    past_headers = False
    
    with open(filename) as f:
        for line in f:
            # skip header line
            if not past_headers:
                past_headers = True
                continue
            
            fields = line.strip().split(",")
            session, rollcall, voter, vote = int(fields[0]), int(fields[2]), int(fields[3]), int(fields[4])
            vote = translate_vote(vote)
            if vote is not None:
                votes[session][(rollcall, vote)].append(voter)
    
    return dict(votes) # don't care about defaultdict anymore, causes pickling problems

def tally_agreements(votes, session):
    agreements = Counter()
    
    for voters in votes[session].values():
        for i in range(len(voters)):
            for j in range(i+1, len(voters)):
                a, b = min(voters[i], voters[j]), max(voters[i], voters[j])
                agreements[(session, a, b)] += 1
    
    return agreements
    
def print_agreements(l):
    for agreements in l:
        for ids, count in agreements.items():
            print("\t".join(map(str, list(ids) + [count])))

def print_error(e):
    print(e)


if __name__ == "__main__":
    # read in votes (takes a bit, ~500 MB)
    votes = read_votes("Sall_votes.csv")

    # tally and print agreements (also takes a bit)
    multiprocessing.log_to_stderr()
    logger = multiprocessing.get_logger()
    logger.setLevel(logging.INFO)
    pool = multiprocessing.Pool()
    pool.starmap_async(tally_agreements, [(votes, k) for k in votes.keys()], callback=print_agreements, error_callback=print_error)
    pool.close()
    pool.join()
