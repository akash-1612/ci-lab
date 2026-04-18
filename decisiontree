import pandas as pd
import numpy as np
import math
from collections import Counter

def load_dataset(file_path):
    
    try:
        data = pd.read_csv(file_path)
        print(f"Dataset loaded successfully with {len(data)} records")
        return data
    except Exception as e:
        print(f"Error loading dataset: {e}")
        return None

def get_random_samples(data, n=50):
   
    if len(data) < n:
        print(f"Warning: Dataset has only {len(data)} records. Using all records.")
        return data
    
    random_sample = data.sample(n=n, random_state=42)
    print(f"Selected {n} random samples from dataset")
    return random_sample

def calculate_entropy_before_split(data, target_column):
    
    target_values = data[target_column]
    
    # Count occurrences of each class
    class_counts = Counter(target_values)
    total_samples = len(target_values)
    
    # Calculate entropy
    entropy = 0.0
    for count in class_counts.values():
        if count > 0:
            probability = count / total_samples
            entropy -= probability * math.log2(probability)
    
    return entropy

def calculate_entropy_after_split(data, attribute, target_column):
    
    total_samples = len(data)
    weighted_entropy = 0.0
    
    # Get unique values of the attribute
    attribute_values = data[attribute].unique()
    
    # Calculate weighted entropy for each attribute value
    for value in attribute_values:
        # Get subset of data for this attribute value
        subset = data[data[attribute] == value]
        subset_size = len(subset)
        
        # Calculate weight
        weight = subset_size / total_samples
        
        # Calculate entropy for this subset
        subset_target = subset[target_column]
        class_counts = Counter(subset_target)
        
        subset_entropy = 0.0
        for count in class_counts.values():
            if count > 0:
                probability = count / subset_size
                subset_entropy -= probability * math.log2(probability)
        
        # Add weighted entropy
        weighted_entropy += weight * subset_entropy
    
    return weighted_entropy

def calculate_information_gain(data, attribute, target_column):
    
    entropy_before = calculate_entropy_before_split(data, target_column)
    entropy_after = calculate_entropy_after_split(data, attribute, target_column)
    
    information_gain = entropy_before - entropy_after
    
    return information_gain

def find_root_node(data, target_column):
    
    attributes = [col for col in data.columns if col != target_column]
    
    # Calculate information gain for each attribute
    info_gains = {}
    
    print("\n" + "="*70)
    print("CALCULATING INFORMATION GAIN FOR EACH ATTRIBUTE")
    print("="*70)
    
    for attribute in attributes:
        try:
            ig = calculate_information_gain(data, attribute, target_column)
            info_gains[attribute] = ig
            
            # Display detailed calculations
            entropy_before = calculate_entropy_before_split(data, target_column)
            entropy_after = calculate_entropy_after_split(data, attribute, target_column)
            
            print(f"\nAttribute: {attribute}")
            print(f"  Entropy (before split): {entropy_before:.4f}")
            print(f"  Entropy (after split):  {entropy_after:.4f}")
            print(f"  Information Gain:       {ig:.4f}")
            
        except Exception as e:
            print(f"  Error calculating for {attribute}: {e}")
            info_gains[attribute] = 0
    
    # Find attribute with maximum information gain
    best_attribute = max(info_gains, key=info_gains.get)
    max_info_gain = info_gains[best_attribute]
    
    return best_attribute, max_info_gain, info_gains

def main():
   
    print("="*70)
    print("DECISION TREE - ROOT NODE SELECTION")
    print("="*70)
    
    # Get CSV file path from user
    file_path = input("\nEnter the path to your CSV file: ").strip()
    
    # Load dataset
    data = load_dataset(file_path)
    if data is None:
        return
    
    # Display dataset info
    print(f"\nDataset shape: {data.shape}")
    print(f"Columns: {list(data.columns)}")
    print("\nFirst few rows:")
    print(data.head())
    
    # Get target column name
    print(f"\nAvailable columns: {list(data.columns)}")
    target_column = input("Enter the name of the target/class column: ").strip()
    
    if target_column not in data.columns:
        print(f"Error: Column '{target_column}' not found in dataset")
        return
    
    # Get 50 random samples
    sample_data = get_random_samples(data, n=50)
    
    print("\n" + "="*70)
    print("WORKING WITH 50 RANDOM SAMPLES")
    print("="*70)
    print(f"Sample shape: {sample_data.shape}")
    
    # Find root node
    best_attribute, max_info_gain, all_gains = find_root_node(sample_data, target_column)
    
    # Display results
    print("\n" + "="*70)
    print("RESULTS - ROOT NODE SELECTION")
    print("="*70)
    print(f"\nRoot Node Selected: {best_attribute}")
    print(f"Maximum Information Gain: {max_info_gain:.4f}")
    
    print("\n" + "-"*70)
    print("Information Gain Summary (Sorted):")
    print("-"*70)
    sorted_gains = sorted(all_gains.items(), key=lambda x: x[1], reverse=True)
    for i, (attr, gain) in enumerate(sorted_gains, 1):
        marker = " ← ROOT NODE" if attr == best_attribute else ""
        print(f"{i}. {attr:20s} : {gain:.4f}{marker}")
    
    print("\n" + "="*70)

if __name__ == "__main__":
    main()
