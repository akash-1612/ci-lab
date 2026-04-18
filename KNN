import csv
import math
import random
from collections import Counter

def distance(p1, p2, r, n):
    return (sum((p1[i] - p2[i]) ** r for i in range(n))) ** (1 / r)

def min_max(data, n):
    """Return (normalized_data, mins, maxs). Each row in normalized_data keeps the class label as last element."""
    mins = [min(d[i] for d in data) for i in range(n)]
    maxs = [max(d[i] for d in data) for i in range(n)]
    norm = []
    for row in data:
        features = [
            (row[i] - mins[i]) / (maxs[i] - mins[i]) if (maxs[i] - mins[i]) != 0 else 0
            for i in range(n)
        ]
        norm.append(features + [row[n]])
    return norm, mins, maxs

def z_score(data, n):
    """Return (normalized_data, means, stds)."""
    means = [sum(d[i] for d in data) / len(data) for i in range(n)]
    stds = [
        math.sqrt(sum((d[i] - means[i]) ** 2 for d in data) / len(data))
        for i in range(n)
    ]
    norm = []
    for row in data:
        features = [
            (row[i] - means[i]) / stds[i] if stds[i] != 0 else 0
            for i in range(n)
        ]
        norm.append(features + [row[n]])
    return norm, means, stds

def normalize_unknown_minmax(unknown, mins, maxs, n):
    return [
        (unknown[i] - mins[i]) / (maxs[i] - mins[i]) if (maxs[i] - mins[i]) != 0 else 0
        for i in range(n)
    ]

def normalize_unknown_zscore(unknown, means, stds, n):
    return [
        (unknown[i] - means[i]) / stds[i] if stds[i] != 0 else 0
        for i in range(n)
    ]

def read_csv(file):
    data = []
    with open(file, 'r', newline='') as f:
        reader = csv.reader(f)
        header = next(reader, None)
        for r in reader:
            if not r:
                continue
            try:
                float_row = [float(value) for value in r]
                data.append(float_row)
            except ValueError as e:
                print(f"Skipping row due to non numeric data: {r} -> {e}")
    return data

def knn(data, unknown, r, n, original_data=None):
    table = []
    for i, row in enumerate(data):
        dist = distance(row[:n], unknown, r, n)
        if original_data is not None:
            table.append({
                'original': original_data[i][:n],
                'normalized': row[:n],
                'distance': dist,
                'class': row[n],
                'index': i
            })
        else:
            table.append({
                'original': row[:n],
                'normalized': row[:n],
                'distance': dist,
                'class': row[n],
                'index': i
            })

    # Sort by distance
    table.sort(key=lambda x: x['distance'])

    # Header - show both original and normalized values
    print("\n" + "="*100)
    print("ORIGINAL VALUES".ljust(30) + " | " + "NORMALIZED VALUES".ljust(30) + " | Distance | Class | Rank")
    print("="*100)
    for i, row in enumerate(table):
        orig_str = " ".join(f"{row['original'][j]:.3f}" for j in range(n))
        norm_str = " ".join(f"{row['normalized'][j]:.3f}" for j in range(n))
        print(f"{orig_str.ljust(30)} | {norm_str.ljust(30)} | {row['distance']:8.3f} | {int(row['class']):5} | {i+1:4}")

    k = int(input("\nEnter the k value: "))

    # Show table with Near-K column
    print("\n" + "="*110)
    print("ORIGINAL VALUES".ljust(30) + " | " + "NORMALIZED VALUES".ljust(30) + " | Distance | Rank | Class | Near-K")
    print("="*110)
    for i, row in enumerate(table):
        is_near_k = "YES" if i < k else "NO"
        orig_str = " ".join(f"{row['original'][j]:.3f}" for j in range(n))
        norm_str = " ".join(f"{row['normalized'][j]:.3f}" for j in range(n))
        print(f"{orig_str.ljust(30)} | {norm_str.ljust(30)} | {row['distance']:8.3f} | {i+1:4} | {int(row['class']):5} | {is_near_k:^6}")
    
    # Show only nearest k neighbors
    print("\n" + "="*110)
    print(f"NEAREST {k} NEIGHBORS (Near-K = YES)")
    print("="*110)
    print("ORIGINAL VALUES".ljust(30) + " | " + "NORMALIZED VALUES".ljust(30) + " | Distance | Rank | Class")
    print("="*110)
    neighbors = table[:k]
    for i, row in enumerate(neighbors):
        orig_str = " ".join(f"{row['original'][j]:.3f}" for j in range(n))
        norm_str = " ".join(f"{row['normalized'][j]:.3f}" for j in range(n))
        print(f"{orig_str.ljust(30)} | {norm_str.ljust(30)} | {row['distance']:8.3f} | {i+1:4} | {int(row['class']):5}")
    
    mode = input("\nWeighted or Unweighted (W/U): ").strip().upper()
    if mode == 'U':
        votes = Counter([neighbor['class'] for neighbor in neighbors])
        print("\n" + "="*50)
        print("UNWEIGHTED VOTING")
        print("="*50)
        print("Votes per class:", dict(votes))
        prediction = votes.most_common(1)[0][0]
    else:
        weights = {}
        for neighbor in neighbors:
            cls = neighbor['class']
            w = 1 / (neighbor['distance'] + 1e-5)  # avoid division by zero
            weights[cls] = weights.get(cls, 0) + w
        print("\n" + "="*50)
        print("WEIGHTED VOTING")
        print("="*50)
        print("Weighted values per class:")
        for c, w in sorted(weights.items()):
            print(f"  Class {int(c)}: {round(w, 4)}")
        prediction = max(weights, key=weights.get)
    
    print("="*50)
    return prediction

def main():
    file = input("Enter CSV file name: ").strip()
    
    norm = input("Apply normalization? (Y/N): ").strip().upper()
    n = int(input("Enter the number of features: ").strip())
    r = int(input("Manhattan or Euclidean r (1/2): ").strip())
    data = read_csv(file)

    if len(data) >= 250:
        data = random.sample(data, 150)
        print("Randomly selected 150 records")

    # Keep original data before normalization
    original_data = [row[:] for row in data]  # Deep copy

    # Normalization parameters (set to None if not used)
    minmax_params = None
    zscore_params = None

    if norm == 'Y':
        ntype = input("1. Min-Max  2. Z-Score : ").strip()
        if ntype == '1':
            data, mins, maxs = min_max(data, n)
            minmax_params = (mins, maxs)
        else:
            data, means, stds = z_score(data, n)
            zscore_params = (means, stds)

    unknown_raw = list(map(float, input(
        f"Enter unknown point ({', '.join(['F'+str(i+1) for i in range(n)])}): "
    ).split()))

    # If normalization was applied to training data, apply same transformation to unknown
    if norm == 'Y':
        if minmax_params is not None:
            mins, maxs = minmax_params
            unknown = normalize_unknown_minmax(unknown_raw, mins, maxs, n)
        else:
            means, stds = zscore_params
            unknown = normalize_unknown_zscore(unknown_raw, means, stds, n)
    else:
        unknown = unknown_raw
    
    # Pass original_data if normalization was applied
    if norm == 'Y':
        result = knn(data, unknown, r, n, original_data)
    else:
        result = knn(data, unknown, r, n)
    
    print("\n" + "="*50)
    print(f"FINAL PREDICTION: Class {int(result)}")
    print("="*50)

if __name__ == "__main__":
    main()
