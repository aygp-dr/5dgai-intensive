#!/usr/bin/env python
"""
Simple test for Google API embeddings with French verbs
Designed for direct execution without complex dependencies
"""

import os
import sys
import json
import time
from pathlib import Path
import dotenv

# Load environment variables
dotenv.load_dotenv()
API_KEY = os.getenv("AI_STUDIO_API_KEY") or os.getenv("GOOGLE_API_KEY")

if not API_KEY:
    print("❌ Error: No API key found! Set AI_STUDIO_API_KEY in .env file")
    sys.exit(1)

# Check if we can import google-genai
try:
    import google.generativeai as genai
    print("✓ Successfully imported google.generativeai")
except ImportError:
    print("❌ Error: Failed to import google.generativeai")
    print("Try: pip install google-generativeai==0.8.0")
    sys.exit(1)

def load_verbs(filepath, max_verbs=None):
    """Load verbs from a text file"""
    with open(filepath, 'r', encoding='utf-8') as f:
        verbs = [line.strip() for line in f if line.strip()]
    
    if max_verbs and max_verbs < len(verbs):
        print(f"Limiting to {max_verbs} verbs out of {len(verbs)}")
        return verbs[:max_verbs]
    return verbs

def get_embedding(text, model_name="embedding-001"):
    """Get embedding for a single text using Gemini API"""
    try:
        # Configure the API
        genai.configure(api_key=API_KEY)
        
        # Get embedding model
        embedding_model = genai.get_model(model_name)
        
        # Generate embedding
        result = embedding_model.embed_content(text)
        
        # Return values
        return result.embedding.values
    except Exception as e:
        print(f"Error getting embedding for '{text}': {e}")
        return None

def get_cached_embedding(verb, cache_dir):
    """Get embedding from cache if exists, otherwise from API"""
    # Create safe filename
    safe_verb = verb.replace(" ", "_")
    cache_path = Path(cache_dir) / f"{safe_verb}.json"
    
    # Check if cache exists
    if cache_path.exists():
        print(f"  Loading cached embedding for '{verb}'")
        with open(cache_path, 'r', encoding='utf-8') as f:
            return json.load(f)
    
    # Get from API
    print(f"  Getting new embedding for '{verb}'")
    embedding = get_embedding(verb)
    
    if embedding:
        # Save to cache
        cache_path.parent.mkdir(parents=True, exist_ok=True)
        with open(cache_path, 'w', encoding='utf-8') as f:
            json.dump(embedding, f)
        
        # Add small delay to avoid rate limits
        time.sleep(1)
        
        return embedding
    else:
        print(f"  Failed to get embedding for '{verb}'")
        return None

def main():
    """Main function"""
    print("\n🇫🇷 French Verb Embedding Test 🇫🇷")
    print("==================================")
    
    # Get repo root and file paths
    repo_root = Path(__file__).parent.parent.parent
    verbs_file = repo_root / "resources" / "verbs" / "test_french_verbs.txt"
    output_dir = repo_root / "data" / "embeddings"
    cache_dir = output_dir / "cache"
    
    # Create output directory
    output_dir.mkdir(parents=True, exist_ok=True)
    cache_dir.mkdir(parents=True, exist_ok=True)
    
    # Load verbs - limit to 10 for testing
    max_verbs = 10
    verbs = load_verbs(verbs_file, max_verbs=max_verbs)
    print(f"Loaded {len(verbs)} French verbs:")
    print(", ".join(verbs))
    
    # Check if API is working
    print("\nTesting Google API connectivity...")
    test_verb = "être"
    test_embedding = get_embedding(test_verb)
    
    if test_embedding:
        print("✓ API test successful!")
        print(f"  Embedding dimensions: {len(test_embedding)}")
        print(f"  First 5 values: {test_embedding[:5]}")
    else:
        print("❌ API test failed!")
        return
    
    # Process all verbs
    print("\nProcessing all verbs...")
    embeddings = {}
    
    for i, verb in enumerate(verbs):
        print(f"\nVerb {i+1}/{len(verbs)}: {verb}")
        embedding = get_cached_embedding(verb, cache_dir)
        
        if embedding:
            embeddings[verb] = embedding
            if i == 0:  # First one only
                print(f"  Sample dimensions: {len(embedding)}")
                print(f"  First 5 values: {embedding[:5]}")
    
    # Save all embeddings
    if embeddings:
        output_file = output_dir / "test_french_verb_embeddings.json"
        with open(output_file, 'w', encoding='utf-8') as f:
            json.dump(embeddings, f, indent=2)
        print(f"\n✓ Saved embeddings to: {output_file}")
        
        # Print a summary
        print("\nSummary:")
        print(f"  Processed {len(embeddings)}/{len(verbs)} verbs")
        print(f"  Embedding dimensions: {len(list(embeddings.values())[0])}")
        print(f"  Output file: {output_file}")
    else:
        print("\n❌ No embeddings were generated!")
    
    print("\n✓ Done!")

if __name__ == "__main__":
    main()